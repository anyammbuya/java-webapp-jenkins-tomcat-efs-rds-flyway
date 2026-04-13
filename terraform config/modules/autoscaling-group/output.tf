
# Autoscaling Outputs

output "jenkins_autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.project_zeus_asg["jenkins"].name 
}

output "tomcat_autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.project_zeus_asg["tomcat"].name 
}