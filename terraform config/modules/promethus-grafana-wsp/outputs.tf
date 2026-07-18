output "prometheus_workspace_id" {
  description = "promethus workspace id"
  value       = aws_prometheus_workspace.zeus_amp.id
}

output "grafana_workspace_id" {
  description = "grafana workspace id"
  value       = aws_grafana_workspace.zeus_grafana.id
}

