resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "statusnest-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS CPU & Memory"
          region = "us-east-1"
          period = 300
          stat   = "Average"
          view   = "timeSeries"
          yAxis  = { left = { min = 0, max = 100 } }
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Requests & 5xx Errors"
          region = "us-east-1"
          period = 300
          view   = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum", label = "Requests" }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum", label = "ELB 5xx" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { stat = "Sum", label = "Target 5xx" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Target Health & Latency"
          region = "us-east-1"
          period = 60
          view   = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { stat = "Maximum", label = "Unhealthy Hosts" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "p99", label = "p99 Latency" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "RDS CPU & Connections"
          region = "us-east-1"
          period = 300
          view   = "timeSeries"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_identifier, { stat = "Average", label = "CPU %" }],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.db_instance_identifier, { stat = "Average", label = "Connections" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "Redis CPU & Memory"
          region = "us-east-1"
          period = 300
          view   = "timeSeries"
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", var.redis_cluster_id, { stat = "Average", label = "CPU %" }],
            ["AWS/ElastiCache", "FreeableMemory", "CacheClusterId", var.redis_cluster_id, { stat = "Average", label = "Free Memory" }]
          ]
        }
      },
      {
        type   = "alarm"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title = "Alarm Status"
          alarms = [
            "arn:aws:cloudwatch:us-east-1:026243800492:alarm:statusnest-${var.environment}-ecs-cpu-high",
            "arn:aws:cloudwatch:us-east-1:026243800492:alarm:statusnest-${var.environment}-ecs-memory-high",
            "arn:aws:cloudwatch:us-east-1:026243800492:alarm:statusnest-${var.environment}-alb-5xx-high",
            "arn:aws:cloudwatch:us-east-1:026243800492:alarm:statusnest-${var.environment}-unhealthy-hosts",
            "arn:aws:cloudwatch:us-east-1:026243800492:alarm:statusnest-${var.environment}-rds-cpu-high",
            "arn:aws:cloudwatch:us-east-1:026243800492:alarm:statusnest-${var.environment}-redis-cpu-high"
          ]
        }
      }
    ]
  })
}
