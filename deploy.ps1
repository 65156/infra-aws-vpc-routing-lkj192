
#fixed variables
$variables = . "./variables.ps1"
$rollbackfile = ".\files\rollbackdata.csv" 
$rollback = @()

foreach($a in $accounts){
    $account = $a.Account
    $connections = $a.connections
    
    #Switch to applicable Account
    Switch-RoleAlias $account admin 
    Write-Host "Processing $account" -f white -b magenta 
    $routeTables = (Get-EC2RouteTable -region $region)
    
    
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
                        #Write-Host "Route set failure for $route" -f red 
                        } 
                }
            if($match -eq 0){Write-Host "No Match in $route"}
            # Clear loop variables
            $cidr = $null ; $gatewayID = $null ; $peeringconnection = $null
            } 
            Write-Host ""
        }
        Write-Host ""
    }

    #Create Rollback CSV file from Hash Table
    Write-Host "Rollback Data" -f white -b magenta
    $rollback 
    Write-Host "Exporting to CSV." -f yellow
    $rollback | Export-CSV $rollbackfile -force
    