# Production Environment - Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS Name - Access your application here"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = module.ecs.service_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group"
  value       = module.ecs.log_group_name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch Dashboard Name"
  value       = module.cloudwatch.dashboard_name
}

output "secrets_manager_arn" {
  description = "AWS Secrets Manager ARN"
  value       = module.iam.secrets_manager_arn
}
