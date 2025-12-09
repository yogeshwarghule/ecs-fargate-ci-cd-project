# Quick Command Reference

## 🚀 Deploy (First Time)
```bash
cd terraform/environments/prod
terraform init
terraform apply
```

## 🗑️ Destroy (End of Day)
```bash
cd terraform/environments/prod
terraform destroy
```

## 🔄 Re-Deploy (Next Day)
```bash
cd terraform/environments/prod
terraform apply -auto-approve
aws ecs update-service --cluster assignment-prod-cluster --service assignment-prod-service --force-new-deployment --region ap-south-1 --profile terraform-mcp
```

## ✅ Check Status
```bash
# Get ALB URL
terraform output alb_dns_name

# Check ECS tasks
aws ecs describe-services --cluster assignment-prod-cluster --services assignment-prod-service --region ap-south-1 --profile terraform-mcp --query "services[0].[runningCount,desiredCount]" --output table

# Test application
curl http://$(terraform output -raw alb_dns_name)/health
curl http://$(terraform output -raw alb_dns_name)/predict
```

## 🐳 Manual Docker Deploy
```bash
# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login
aws ecr get-login-password --region ap-south-1 --profile terraform-mcp | docker login --username AWS --password-stdin ${ECR_URL%/*}

# Build & Push
cd application
docker build -t assignment-prod:latest .
docker tag assignment-prod:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Deploy
aws ecs update-service --cluster assignment-prod-cluster --service assignment-prod-service --force-new-deployment --region ap-south-1 --profile terraform-mcp
```

## 📊 Monitoring
```bash
# View logs
aws logs tail /ecs/assignment-prod --follow --region ap-south-1 --profile terraform-mcp

# Check CloudWatch dashboard
# Go to: AWS Console → CloudWatch → Dashboards → assignment-prod-dashboard
```

## 🔧 Troubleshooting
```bash
# Service events
aws ecs describe-services --cluster assignment-prod-cluster --services assignment-prod-service --region ap-south-1 --profile terraform-mcp --query "services[0].events[0:5]"

# Target health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn) --region ap-south-1 --profile terraform-mcp

# Force delete service (if destroy stuck)
aws ecs delete-service --cluster assignment-prod-cluster --service assignment-prod-service --force --region ap-south-1 --profile terraform-mcp
```
