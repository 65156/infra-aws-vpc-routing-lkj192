
## Fixed Variables ##
$variables = . ".\variables.ps1" # List of variables used for script
$date = Get-Date -Format dd-MM-yy_hh-mm-ss
$rollbackfile = ".\files\rollbackdata_$date.csv" # Rollback file generated from hash table
$rollbackhash = @() # Rollback hash table

foreach($a in $accounts){
    $account = $a.Account
    $connections = $a.connections
    
    # Switch to applicable account    
    Write-Host "  ----------------"
    Write-Host "Processing $account" -f white -b magenta 
    Write-Host "  ----------------"
    Switch-RoleAlias $account admin 
    Write-Host ""
    $routeTables = (Get-EC2RouteTable -region $region)
    
    if($rollback -eq $true){
        # Resets routes to previous configuration based on the rollbackdata.csv
        $lines = Import-CSV $rollbackfile
        Write-Host "Rolling back changes." -f yellow
        foreach($l in $lines){

        $acc = $l.Account
        $rt = $l.RouteTable
        $r = $l.route
        $c = $l.connection
        if($acc -eq $account){
            #configure command to reconfigure route to original here.
            Write-Host "SetEC2-Route: " -nonewline ; Write-Host $rt -nonewline -f white -b magenta ; Write-Host " $r" -NoNewLine -f magenta
            try {
                    #Write-Host "Updating Route for $route" -f green ; 
                    if ($c -like 'vgw*'){
                        Write-Host " $c " 
                        #Set-EC2Route -DestinationCidrBlock $r -RouteTableId $rt -GatewayId $c -Region $Region ; continue
                        }
                    if ($c -like "pcx*"){
                        Write-Host " $c " 
                        #Set-EC2Route -DestinationCidrBlock $r -RouteTableId $rt -VpcPeeringConnectionId $c -Region $region
                        }                   
                } catch { 
                    Write-Host "Route set failure for $route" -f red 
                    } 
            }
            }
        }
    Write-Host ""
    if($rollback -eq $true){continue} # skip loop iteration
    
    # Loop through each route table in standard mode
    foreach($rT in $routeTables){
        $routes = $rT.Routes
        $routeTable = $rT.RouteTableID
        Write-Host "Route Table:" -f black -b cyan -nonewline ; Write-Host " $routeTable" -f black -b white
        # Loop through each route entry
        foreach($r in $routes){
            $match = 0
            $cidr = $r.DestinationCidrBlock
            if(!$cidr){continue} # skip loop iteration if $cidr has no value i.e $null
            $gatewayID = $r.gatewayID
            $peeringconnection = $r.VpcPeeringConnectionId  
            $route = $r.DestinationCidrBlock
            # Check if gateway for route matches gateway id or peering connection
            foreach($c in $connections){
                if($c -eq $gatewayID){ $match = 1 ; break }  # if match, break out of foreach loop.
                if($c -eq $peeringconnection){ $match = 1 ; break } # if match, break out of foreach loop.
                }
            # Update Route 
            if($match -eq 1){
                try {
                    Write-Host "Matched $route" -f green -nonewline ;
                    # Generate rollback pscustom object 
                    $obj = [PSCustomObject]@{
                        Account = "$account"
                        RouteTable = "$routeTable"
                        Route = "$route"
                        Connection = "$c"
                        }
                    $rollbackhash += $obj # Add custom object to rollback array
                    Write-Host " :: " -nonewline ; Write-Host "updating $transitgatewayid " -f cyan ; 
                    #Set-EC2Route -DestinationCidrBlock $cidr -RouteTableId $routeTable -TransitGatewayId $transitgatewayID -Region $Region 
                    } catch { 
                        Write-Host "Route set failure for $route" -f red 
                        } 
                }
            if($match -eq 0){Write-Host "No Match in $route"}
            # Clear loop variables
            $cidr = $null ; $gatewayID = $null ; $peeringconnection = $null
            } 
        Write-Host ""
        }
    }

    # Terminate script if rolling back
    if($rollback -eq $true){
        Write-Host " --------------- "
        Write-Host "Rollback Complete" -f white -b magenta
        Write-Host " --------------- "        
        exit}    

    # Create rollback CSV file from $rollback hash table
    $rollbackhash | Export-CSV $rollbackfile -force
    Write-Host "Exporting Rollback Data to CSV" -f white -b magenta
    $rollbackhash 

