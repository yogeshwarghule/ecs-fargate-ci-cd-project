output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
}

output "memory_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ecs_memory_high.arn
}

output "unhealthy_hosts_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
}
