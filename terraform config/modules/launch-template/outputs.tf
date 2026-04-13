# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "jenkins_launch_template_id" {
  value       = aws_launch_template.jenkins-LT.id
}

output "tomcat_launch_template_id" {
  value       = aws_launch_template.tomcat-LT.id
}

output "launch_template_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.jenkins-LT.latest_version
}