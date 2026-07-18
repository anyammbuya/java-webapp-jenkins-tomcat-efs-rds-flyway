

output "log_group_name" {
    value = aws_cloudwatch_log_group.tomcat_app_logs.name
}