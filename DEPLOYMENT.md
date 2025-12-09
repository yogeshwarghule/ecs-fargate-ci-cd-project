# Deployment Guide

## 🚀 Deploy Infrastructure (Day 1)

### Step 1: Initialize Terraform
```bash
cd terraform/environments/prod
terraform init
```

### Step 2: Plan Infrastructure
```bash
terraform plan
```

### Step 3: Deploy Infrastructure
```bash
terraform apply
```
**Expected**: 35 resources created (VPC, ECR, IAM, ALB, ECS, CloudWatch, VPC Endpoints)

### Step 4: Note Outputs
```bash
terraform output
```
Save these values:
- `alb_dns_name` - Your application URL
- `ecr_repository_url` - Docker image repository

---

## 🐳 Deploy Application (First Time)

### Option A: Via GitHub Actions (Recommended)

1. **Add GitHub Secrets**:
   - Go to: Settings → Secrets → Actions
   - Add: `AWS_ACCESS_KEY_ID`
   - Add: `AWS_SECRET_ACCESS_KEY`

2. **Trigger Deployment**:
   - Go to: Actions → Deploy to ECS → Run workflow
   - OR push changes to `application/` folder

### Option B: Manual Docker Push

```bash
# Login to ECR
aws ecr get-login-password --region ap-south-1 --profile terraform-mcp | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

# Build image
cd application
docker build -t assignment-prod:latest .

# Tag image
docker tag assignment-prod:latest <ecr-repository-url>:latest

# Push image
docker push <ecr-repository-url>:latest

# Force ECS deployment
aws ecs update-service --cluster assignment-prod-cluster --service assignment-prod-service --force-new-deployment --region ap-south-1 --profile terraform-mcp
```

---

## ✅ Verify Deployment

```bash
# Check ECS service status
aws ecs describe-services --cluster assignment-prod-cluster --services assignment-prod-service --region ap-south-1 --profile terraform-mcp --query "services[0].[runningCount,desiredCount]" --output table

# Test application
curl http://<alb-dns-name>/health
curl http://<alb-dns-name>/predict
```

Expected responses:
- `/health` → `{"status":"ok"}`
- `/predict` → `{"score":0.75}`

---

## 🗑️ Destroy Infrastructure (End of Day)

### Step 1: Stop ECS Tasks (Optional - saves time)
```bash
aws ecs update-service --cluster assignment-prod-cluster --service assignment-prod-service --desired-count 0 --region ap-south-1 --profile terraform-mcp
```

### Step 2: Destroy All Resources
```bash
cd terraform/environments/prod
terraform destroy
```
**Confirm**: Type `yes` when prompted

### Step 3: Verify Cleanup
```bash
# Check if resources are deleted
aws ecs list-clusters --region ap-south-1 --profile terraform-mcp
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=assignment-prod-vpc" --region ap-south-1 --profile terraform-mcp
```

---

## 🔄 Re-Deploy Next Day

### Quick Start (5 minutes)
```bash
# 1. Deploy infrastructure
cd terraform/environments/prod
terraform init
terraform apply -auto-approve

# 2. Deploy application (if image exists in ECR)
aws ecs update-service --cluster assignment-prod-cluster --service assignment-prod-service --force-new-deployment --region ap-south-1 --profile terraform-mcp

# 3. Wait for deployment
aws ecs wait services-stable --cluster assignment-prod-cluster --services assignment-prod-service --region ap-south-1 --profile terraform-mcp

# 4. Get ALB URL
terraform output alb_dns_name

# 5. Test
curl http://$(terraform output -raw alb_dns_name)/health
```

### If ECR Image Was Deleted
```bash
# Rebuild and push Docker image (see "Deploy Application" section above)
# Then force ECS deployment
```

---

## 💰 Cost Optimization

### Daily Destroy Saves:
- **ECS Fargate**: ~$0.04/hour × 2 tasks = $0.08/hour
- **ALB**: ~$0.025/hour = $0.025/hour
- **VPC Endpoints**: ~$0.01/hour × 3 = $0.03/hour
- **Total**: ~$0.135/hour = **$3.24/day**

### What Persists (No Cost):
- ECR repository (free tier: 500MB)
- Docker images in ECR
- Terraform state (local)
- GitHub repository

### Monthly Cost if Running 24/7:
- **With daily destroy**: ~$0 (only during work hours)
- **Without destroy**: ~$100/month

---

## 📝 Important Notes

1. **ECR Images**: Docker images remain in ECR after destroy (no extra cost if < 500MB)
2. **Terraform State**: Stored locally in `terraform.tfstate` - don't delete!
3. **GitHub Actions**: Will fail if infrastructure is destroyed
4. **VPC Endpoints**: Required for ECS tasks to pull from ECR
5. **First Deploy**: Takes ~5-7 minutes
6. **Re-Deploy**: Takes ~3-5 minutes

---

## 🔧 Troubleshooting

### ECS Tasks Not Starting
```bash
# Check task logs
aws logs tail /ecs/assignment-prod --follow --region ap-south-1 --profile terraform-mcp

# Check service events
aws ecs describe-services --cluster assignment-prod-cluster --services assignment-prod-service --region ap-south-1 --profile terraform-mcp --query "services[0].events[0:5]"
```

### ALB Health Check Failing
```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn> --region ap-south-1 --profile terraform-mcp
```

### Terraform Destroy Stuck
```bash
# Force delete ECS service first
aws ecs delete-service --cluster assignment-prod-cluster --service assignment-prod-service --force --region ap-south-1 --profile terraform-mcp

# Then retry destroy
terraform destroy
```

---

## 📊 Resource Summary

| Resource | Count | Purpose |
|----------|-------|---------|
| VPC | 1 | Network isolation |
| Subnets | 6 | 2 public, 2 private app, 2 private DB |
| Security Groups | 3 | ALB, ECS, VPC endpoints |
| VPC Endpoints | 4 | ECR API, ECR DKR, S3, CloudWatch |
| ALB | 1 | Load balancing |
| Target Group | 1 | ECS task routing |
| ECS Cluster | 1 | Container orchestration |
| ECS Service | 1 | Task management |
| ECS Tasks | 2 | Application containers |
| ECR Repository | 1 | Docker images |
| IAM Roles | 2 | Task execution, task role |
| CloudWatch Dashboard | 1 | Monitoring |
| CloudWatch Alarms | 3 | CPU, Memory, Health |

**Total**: 35 resources
