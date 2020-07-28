# infra-aws-vpc-routing-lkj192
## About
Updates a matched route in a AWS route table, searches recursively through all route tables per account specified.

## Pre-requsities
+ PSCore 6.0
+ AWS PSTools
+ OFX Build Tools (for Authentication)

## To Configure:
1) Update Variables.ps1
2) Update "$connections" to what needs to be matched against. (can match against multiple connections per account)
3) Update "$destinationID" with appropriate ID to replace a matched connection i.e: "tgw-067fc30b039641df1"

## To Test:
Update $deploy variable in Vairables.ps1 to value: "$false" 

## To Deploy:
Update $deploy variable in Variables.ps1 to value: "$true"

## To Rollback:
Update $rollback variable in Variables.ps1 to value "$true"