# The EFS File System
resource "aws_efs_file_system" "zeus_efs" {
  creation_token = "zeus-efs"
  encrypted      = true
  kms_key_id     = var.kms_key_id

  tags = merge(var.tags, {
    Name = "zeus-shared-storage"
  })
}

# Mount Targets (One for each private subnet)
resource "aws_efs_mount_target" "zeus_mount" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.zeus_efs.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [var.efs_sg_id]
}

# Access Point 
resource "aws_efs_access_point" "zeus_ap" {
  file_system_id = aws_efs_file_system.zeus_efs.id

  posix_user {
    uid = 1002 # Match this to your Tomcat user ID
    gid = 1002
  }

  root_directory {
    path = "/webapps"   #path to be mounted

    creation_info {
      owner_uid   = 1002
      owner_gid   = 1002
      permissions = "755"
    }
  }
}