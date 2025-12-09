# AWS ECS Fargate Infrastructure with Terraform

Production-ready AWS infrastructure for deploying containerized applications on ECS Fargate with Application Load Balancer and CloudWatch monitoring.

## Architecture

- **VPC**: Multi-AZ setup with public and private subnets
- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer**: HTTP load balancing with health checks
- **ECR**: Container image registry
- **CloudWatch**: Monitoring dashboard and alarms
- **IAM**: Least privilege roles for ECS tasks

## Project Structure

```
.
├── application/          # Node.js application
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
├── terraform/
│   ├── modules/         # Reusable Terraform modules
│   │   ├── vpc/
│   │   ├── ecr/
│   │   ├── iam/
│   │   ├── alb/
│   │   ├── ecs/
│   │   └── cloudwatch/
│   └── environments/
│       └── prod/        # Production environment
└── aa_ref_01/          # Architecture documentation
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with profile `terraform-mcp`
- Docker (for building application image)

## Deployment

### 1. Initialize Terraform

```bash
cd terraform/environments/prod
terraform init
```

### 2. Review Plan

```bash
terraform plan
```

### 3. Apply Infrastructure

```bash
terraform apply
```

### 4. Build and Push Docker Image

```bash
# Get ECR login
aws ecr get-login-password --region ap-south-1 --profile terraform-mcp | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

# Build image
cd application
docker build -t assignment-prod-ecr:latest .

# Tag image
docker tag assignment-prod-ecr:latest <account-id>.dkr.ecr.ap-south-1.amazonaws.com/assignment-prod-ecr:latest

# Push image
docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/assignment-prod-ecr:latest
```

### 5. Access Application

Get the ALB DNS name from Terraform outputs:
```bash
terraform output alb_dns_name
```

Access endpoints:
- Health check: `http://<alb-dns-name>/health`
- Predict API: `http://<alb-dns-name>/predict`

## Monitoring

CloudWatch dashboard: `assignment-prod-dashboard`

Alarms configured for:
- ECS CPU utilization > 80%
- ECS Memory utilization > 80%
- Unhealthy target hosts > 0

## Configuration

Key variables in `terraform/environments/prod/main.tf`:
- Project: `assignment`
- Environment: `prod`
- Region: `ap-south-1`
- VPC CIDR: `10.30.0.0/16`

## Security

- Private subnets for ECS tasks
- Security groups with least privilege
- IAM roles with minimal permissions
- ECR image scanning enabled

## Cleanup

```bash
cd terraform/environments/prod
terraform destroy
```

## License

MIT
