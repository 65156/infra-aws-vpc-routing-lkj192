$region = "ap-southeast-2"
$accounts = @( 
    # accounts are dependant on account names configured in PS-AWS-SSO-AUTH.psm1
    #[PSCustomObject]@{Account="PipelineProd"; connections=@("vgw-e6ccfefb","pcx-0518b26c","pcx-08423361","pcx-689e3701","pcx-a0b325c9","pcx-aa6cd9c3","pcx-d56cd9bc")},
    #[PSCustomObject]@{Account="PipelineDev"; connections=@("vgw-a52615b8","pcx-08423361","pcx-c47ebdad","pcx-d96cd9b0")},
    #[PSCustomObject]@{Account="LegacyProd"; connections=@("vgw-e72615fa","vgw-e62615fb","pcx-a86cd9c1","pcx-aa6cd9c3","pcx-c47ebdad","pcx-cf70bda6","pcx-d26cd9bb","pcx-d56cd9bc","pcx-689e3701","pcx-689e3701")}
    #[PSCustomObject]@{Account="LegacyDev"; connections=@("vgw-a52615b8","pcx-08423361","pcx-c47ebdad","pcx-d96cd9b0")},
    [PSCustomObject]@{Account="SandboxD3"; connections=@("pcx-0aeae2dd703bc4755")}
    ) 


$transitgatewayID = "tgw-0f5a6a47f6a25f9f9"
$routeTables = (Get-EC2RouteTable -region $region)
foreach($a in $accounts){
    $account = $a.Account
    $connections = $a.connections
    
    #Switch to applicable Account
    Switch-RoleAlias $account admin 
    Write-Host "Processing $account" -f white -b magenta 
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
                if($c -eq $gatewayID){ $match = 1 ; Write-Host "Matched $route to $c" ; break }
                if($c -eq $peeringconnection){ $match = 1 ; Write-Host "Matched $route to $c" ; break }
                }
            # Update Route 
            if($match -eq 1){
                try {Write-Host "Updating Route for $route" -f green ; #Set-EC2Route -DestinationCidrBlock $cidr -RouteTableId $routeTable -TransitGatewayId $transitgatewayID -Region $Region 
                    } catch {} }
            if($match -eq 0){Write-Host "No Match in $route" -f yellow }
            # Clear loop variables
            $cidr = $null ; $gatewayID = $null ; $peeringconnection = $null
            } 
            Write-Host ""
        }
        Write-Host ""
    }