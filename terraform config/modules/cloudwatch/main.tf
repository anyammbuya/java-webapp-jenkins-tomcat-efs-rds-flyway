resource "aws_cloudwatch_log_group" "tomcat_app_logs" {
  name              = "zeus-tomcat-application-logs"
  retention_in_days = 7

  # Optional: Add tags to track resource ownership
  tags = var.tags
}