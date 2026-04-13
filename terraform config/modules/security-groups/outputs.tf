output "lbsg_id" {
  description = "load balancer security group"
  value       = aws_security_group.lbsg.id
}

output "jksg_id" {
  description = "Jenkins instance security group"
  value       = aws_security_group.jenkins_sg.id
}

output "natsg_id" {
  description = "Jenkins instance security group"
  value       = aws_security_group.nat_sg.id
}

output "endptsg_id" {
  description = "Jenkins instance security group"
  value       = aws_security_group.secretsmanager_endpoint_sg.id
}

output "efs_sg_id" {
  description = "EFS endpoint security group"
  value       = aws_security_group.efs_sg.id
}

output "rds_sg_id" {
  description = "db instance security group"
  value       = aws_security_group.rds_sg.id
}
