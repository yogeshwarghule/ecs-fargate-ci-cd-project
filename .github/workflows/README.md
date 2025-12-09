# GitHub Actions CI/CD Pipeline

## Overview

This pipeline automatically builds and deploys the application to AWS ECS Fargate when changes are pushed to the `main` branch.

## Pipeline Stages

1. **Checkout** - Get the latest code
2. **Configure AWS** - Authenticate with AWS using secrets
3. **Login to ECR** - Authenticate Docker with Amazon ECR
4. **Build Image** - Build Docker image from application/
5. **Push to ECR** - Push image with commit SHA and latest tags
6. **Deploy to ECS** - Force new deployment on ECS service
7. **Wait for Deployment** - Wait until service is stable

## Required GitHub Secrets

Add these secrets in your GitHub repository settings:

1. Go to: `Settings` → `Secrets and variables` → `Actions`
2. Add the following secrets:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Create IAM user with ECR + ECS permissions |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | From IAM user creation |

## IAM Permissions Required

The AWS user needs these permissions:
- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:GetDownloadUrlForLayer`
- `ecr:PutImage`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`
- `ecs:UpdateService`
- `ecs:DescribeServices`

## Trigger Options

- **Automatic**: Push to `main` branch with changes in `application/` folder
- **Manual**: Go to Actions tab → Deploy to ECS → Run workflow

## Testing the Pipeline

1. Make a change to `application/index.js`
2. Commit and push to main branch
3. Go to GitHub Actions tab to watch the deployment
4. Check ECS service for new task deployment

## Deployment Flow

```
Code Push → Build Docker Image → Push to ECR → Update ECS Service → Wait for Stable
```

## Troubleshooting

- **Authentication Failed**: Check AWS credentials in secrets
- **ECR Push Failed**: Verify ECR repository exists and permissions
- **ECS Update Failed**: Ensure ECS cluster and service names are correct
- **Deployment Timeout**: Check ECS task logs in CloudWatch
