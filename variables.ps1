$region = "ap-southeast-2"
$destinationID = "tgw-673473284646748324"
$rollback = $false
$deploy = $false
$accounts = @( 
    # accounts are dependant on account names configured in PS-AWS-SSO-AUTH.psm1
    [PSCustomObject]@{Account="PipelineProd"; connections=@("pcx-0518b26c","pcx-08423361","pcx-689e3701","pcx-a0b325c9","pcx-aa6cd9c3","pcx-d56cd9bc")},
    [PSCustomObject]@{Account="PipelineDev"; connections=@("vpc-e818128d","pcx-a0b325c9","pcx-a86cd9c1","pcx-d26cd9bb","pcx-d96cd9b0")},
    [PSCustomObject]@{Account="LegacyProd"; connections=@("pcx-a86cd9c1","pcx-aa6cd9c3","pcx-c47ebdad","pcx-cf70bda6","pcx-d26cd9bb","pcx-d56cd9bc","pcx-689e3701")}
    [PSCustomObject]@{Account="LegacyDev"; connections=@("pcx-08423361","pcx-c47ebdad","pcx-d96cd9b0")},
    [PSCustomObject]@{Account="SandboxD3"; connections=@("")},
    [PSCustomObject]@{Account="SandboxICE"; connections=@("")}
    ) 