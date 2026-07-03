variable "environment" {
  type = string
}
variable "sns_topic_arn" {
  type = string
}
variable "ecs_cluster_name" {
  type = string
}
variable "ecs_service_name" {
  type = string
}
variable "alb_arn_suffix" {
  type = string
}
variable "target_group_arn_suffix" {
  type = string
}
variable "db_instance_identifier" {
  type = string
}
variable "redis_cluster_id" {
  type = string
}
