# aws-poc
## Deployment
### Pre-requisites
1. Installed Terraform CLI and AWS CLI.
2. AWS Credentials (IAM User or Role) to the account where the resources will be deployed.

### Deployment Steps
The templates are separated into two stages.

1. Deploy stage `01-base-vpcs` by running the following commands:
```
cd 01-base-vpcs
terraform init
terraform apply
```

2. Deploy stage `02-vpc2-lambda` by running the following commands:
```
cd 02-vpc2-lambda
terraform init
terraform apply
```

## Testing
- locate the vpc2_test_lambda function from Lambda console
- run test and verify if the request from Lambda in VPC2 to the NLB in VPC1 is successful.

# References

https://aws.amazon.com/blogs/networking-and-content-delivery/building-an-egress-vpc-with-aws-transit-gateway-and-the-aws-cdk/