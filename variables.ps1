$rollbackfile = ./files/rollbackdata.csv
$region = "ap-southeast-2"
$transitgatewayID = "tgw-0f5a6a47f6a25f9f9"
$accounts = @( 
    # accounts are dependant on account names configured in PS-AWS-SSO-AUTH.psm1
    #[PSCustomObject]@{Account="PipelineProd"; connections=@("vgw-e6ccfefb","pcx-0518b26c","pcx-08423361","pcx-689e3701","pcx-a0b325c9","pcx-aa6cd9c3","pcx-d56cd9bc")},
    #[PSCustomObject]@{Account="PipelineDev"; connections=@("vgw-a52615b8","pcx-08423361","pcx-c47ebdad","pcx-d96cd9b0")},
    #[PSCustomObject]@{Account="LegacyProd"; connections=@("vgw-e72615fa","vgw-e62615fb","pcx-a86cd9c1","pcx-aa6cd9c3","pcx-c47ebdad","pcx-cf70bda6","pcx-d26cd9bb","pcx-d56cd9bc","pcx-689e3701","pcx-689e3701")}
    #[PSCustomObject]@{Account="LegacyDev"; connections=@("vgw-a52615b8","pcx-08423361","pcx-c47ebdad","pcx-d96cd9b0")},
    [PSCustomObject]@{Account="SandboxD3"; connections=@("pcx-0aeae2dd703bc4755")}
    ) 