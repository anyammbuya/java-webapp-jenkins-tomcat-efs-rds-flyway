
output "ec2iamrole_jenkins" {
  description = "IAM role name"
  value       = aws_iam_role.jenkins.name
}

output "ec2iamrole_tomcat" {
  description = "IAM role name"
  value       = aws_iam_role.tomcat.name
}

output "ec2profileARN_jenkins" {
  description = "ec2 instance arn"
  value       = aws_iam_instance_profile.jenkins.arn
}

output "ec2profileARN_tomcat" {
  description = "ec2 instance arn"
  value       = aws_iam_instance_profile.tomcat.arn
}



