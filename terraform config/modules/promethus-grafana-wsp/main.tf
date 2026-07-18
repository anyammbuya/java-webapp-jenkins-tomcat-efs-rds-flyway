
# ==============================================================
#           AMAZON MANAGED PROMETHEUS WORKSPACE
# ==============================================================

resource "aws_prometheus_workspace" "zeus_amp" {
  alias = "zeus-tomcat-metrics"
}


# ==============================================================
#           AMAZON MANAGED GRAFANA WORKSPACE
# ==============================================================

resource "aws_grafana_workspace" "zeus_grafana" {
  name                     = "zeus-tomcat-dashboard"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"] # Uses AWS IAM Identity Center for user login
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = var.grafana_workspace_roleArn

  # Automatically registers Amazon Managed Prometheus as an available data source type
  data_sources = ["PROMETHEUS"]
}