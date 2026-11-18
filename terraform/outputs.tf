output "ecr_repository_url" {
  description = "ECR repository the pipeline pushes images to"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "github_actions_role_arn" {
  description = "Save this as the AWS_ROLE_ARN secret in GitHub"
  value       = aws_iam_role.github_actions.arn
}

output "log_group_name" {
  description = "CloudWatch log group for the container"
  value       = aws_cloudwatch_log_group.app.name
}
