
#fixed variables
$variables = . "./variables.ps1"
$rollbackfile = ".\files\rollbackdata.csv" 
$rollback = @()

foreach($a in $accounts){
    $account = $a.Account
    $connections = $a.connections
    
    #Switch to applicable Account    
    Write-Host "  ----------------"
    Write-Host "Processing $account" -f white -b magenta 
    Write-Host "  ----------------"
    Switch-RoleAlias $account admin 
    Write-Host ""
    $routeTables = (Get-EC2RouteTable -region $region)
    
    $rollbackstatus = $true
    if($rollbackstatus -eq $true){
        # Resets routes to previous configuration based on the rollbackdata.csv
        $lines = Import-CSV $rollbackfile
        Write-Host "Rolling back changes." -f yellow
        foreach($l in $lines){

        $acc = $l.Account
        $Rt = $l.RouteTable
        $r = $l.route
        $c = $l.connection
        if($acc -eq $account){
            #do stuff
            #configure command to reconfigure route to original here.
            Write-Host "Rolling back $r" -f magenta
            try {
                    #Write-Host "Updating Route for $route" -f green ; 
                    if ($c -like 'vgw*'){
                        Write-Host "Matched $c "}
                        #Set-EC2Route -DestinationCidrBlock $r -RouteTableId $rt -GatewayId $c -Region $Region ; continue}
                    if ($c -like "pcx*"){
                        Write-Host "Matched $c"}
                        #Set-EC2Route -DestinationCidrBlock $r -RouteTableId $rt -VpcPeeringConnectionId $c -Region $Region }
                    
                } catch { 
                    Write-Host "Route set failure for $route" -f red 
                    } 
            }
            }
        }
    Write-Host ""
    }

    if($rollbackstatus -eq $true){exit}    # terminate script early if rolling back otherwise exports file will be overwritten with null values.
    foreach($rT in $routeTables){
        $routes = $rT.Routes
        $routeTable = $rT.RouteTableID
        Write-Host "Route Table:" -f black -b cyan -nonewline ; Write-Host "$routeTable" -f black -b white
        foreach($r in $routes){
            $match = 0
            $cidr = $r.DestinationCidrBlock
            if($cidr -eq $null){continue}
            $gatewayID = $r.gatewayID
            $peeringconnection = $r.VpcPeeringConnectionId  
            $route = $r.DestinationCidrBlock
            foreach($c in $connections){
                if($c -eq $gatewayID){ $match = 1 ; break }  
                if($c -eq $peeringconnection){ $match = 1 ; break }
                }
            # Update Route 
            if($match -eq 1){
                try {
                    Write-Host "Matched $route to $c" -f yellow ; 
                    #generate rollback array here
                    $obj = [PSCustomObject]@{
                        Account = "$account"
                        RouteTable = "$routeTable"
                        Route = "$route"
                        Connection = "$c"
                        }
                    $rollback += $obj
                    #Write-Host "Updating Route for $route" -f green ; 
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
    $rollback | Export-CSV $rollbackfile -force
    #Create Rollback CSV file from Hash Table
    Write-Host "Exporting Rollback Data to CSV" -f white -b magenta
    $rollback 

