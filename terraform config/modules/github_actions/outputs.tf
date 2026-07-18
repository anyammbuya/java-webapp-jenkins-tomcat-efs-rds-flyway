output "github_actions_s3_role_arn" {
  value       = aws_iam_role.github_actions_s3_role.arn
  description = "ARN for the GitHub Actions S3 sync role to put in your workflow YML"
}