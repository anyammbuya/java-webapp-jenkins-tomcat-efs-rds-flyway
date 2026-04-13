output "efs_dns_name" {
  value = aws_efs_file_system.zeus_efs.dns_name
}

output "efs_id" {
  value = aws_efs_file_system.zeus_efs.id
}

output "efs_access_point_id" {
  value = aws_efs_access_point.zeus_ap.id
}


