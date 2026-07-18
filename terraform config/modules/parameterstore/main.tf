
resource "aws_ssm_parameter" "cw_agent_config" {
  name        = "/zeus/tomcat/cloudwatch-agent-config"
  type        = "String"
  description = "Centralized CloudWatch Agent config routing JVM to AMP"

  value = jsonencode({
    agent = {
      metrics_collection_interval = 60
      run_as_user                 = "root"
    }
    metrics = {
      # This points the prometheus data pipeline directly to your AMP Workspace
      metrics_destinations = {
        amp = {
          workspace_id = var.prometheus_workspace_id
        }
      }
      metrics_collected = {
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 60
        }
        prometheus = {
          prometheus_config_path = "/opt/aws/amazon-cloudwatch-agent/bin/prometheus.yaml"
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path         = "/opt/tomcat/logs/catalina.out"
              log_group_name    = var.log_group_name
              log_stream_name   = "{instance_id}-catalina"
            }
          ]
        }
      }
    }
  })
}