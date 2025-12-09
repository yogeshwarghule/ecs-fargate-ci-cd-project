# VPC Networking Layer - Testing Instructions

## Prerequisites
- AWS CLI configured with credentials
- Terraform >= 1.0 installed
- S3 bucket and DynamoDB table for state backend (or comment out backend.tf for local testing)

## Architecture
- **VPC CIDR**: 10.30.0.0/16
- **Public Subnets**: 10.30.0.0/24, 10.30.1.0/24 (across 2 AZs)
- **Private App Subnets**: 10.30.10.0/24, 10.30.11.0/24 (across 2 AZs)
- **Private DB Subnets**: 10.30.20.0/24, 10.30.21.0/24 (across 2 AZs)

## Testing Steps

### Option 1: Local State (Quick Test)
```bash
# Navigate to prod environment
cd terraform/environments/prod

# Comment out or rename backend.tf temporarily
mv backend.tf backend.tf.bak

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan the deployment
terraform plan

# Apply (if plan looks good)
terraform apply

# View outputs
terraform output
```

### Option 2: S3 Backend (Production)
```bash
# Create S3 bucket and DynamoDB table first
aws s3 mb s3://assignment-prod-terraform-state --region ap-south-1
aws dynamodb create-table \
  --table-name assignment-prod-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

# Initialize with backend
terraform init

# Plan and apply
terraform plan
terraform apply
```

## Expected Outputs
- vpc_id
- vpc_cidr
- public_subnet_ids (2 subnets)
- private_app_subnet_ids (2 subnets)
- private_db_subnet_ids (2 subnets)
- internet_gateway_id

## Cleanup
```bash
terraform destroy
```
