output "cluster_id" {
  value = aws_ecs_cluster.main.id
}
output "cluster_name" {
  value = aws_ecs_cluster.main.name
}
output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}
output "task_definition_arn" {
  value = aws_ecs_task_definition.auth.arn
}
output "execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}
output "task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}
output "service_name" {
  value = aws_ecs_service.auth.name
}
