###########################################
# Launch Template Resource for Jenkins
###########################################

resource "aws_launch_template" "jenkins-LT" {
  
  name          = "jenkins-LT"
  description   = "Launch Template for jenkins server"
  image_id      = "ami-01102c5e8ab69fb75"
  instance_type = "t2.small"

  vpc_security_group_ids = var.security_group_ids
  
  //key_name = var.key_name 
  
  #user_data = filebase64("${path.module}/jenkinssetup_tomcat.sh")
  user_data         = base64encode(templatefile("${path.module}/jenkinssetup_tomcat.sh",{
    efs_id          = var.efs_id
    efs_accesspt_id = var.efs_accesspt_id
  }))


  iam_instance_profile {
    arn = var.instance_profile_arn[0]
  }

  
  //ebs_optimized = true
  
  #default_version = 1

  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10     
      delete_on_termination = true
      volume_type = "gp3" # default is gp3
     }
  }
  monitoring {
    enabled = true
  }

  tag_specifications {
  resource_type = "instance"
  tags = merge(
    {
      Name = "Jenkins"
    },
    var.tags
  )
}
}

##########################################################
# Launch template resource for tomcat
#######################################################

resource "aws_launch_template" "tomcat-LT" {
  
  name          = "tomcat-LT"
  description   = "Launch Template for tomcat server"
  image_id      = "ami-07b2b18045edffe90"
  instance_type = "t4g.nano"

  vpc_security_group_ids = var.security_group_ids
  
  //key_name = var.key_name 
  
  #user_data = filebase64("${path.module}/tomcat_userdata.sh")
   user_data = base64encode(templatefile("${path.module}/tomcat_userdata.sh",{
    efs_id          = var.efs_id
    efs_accesspt_id = var.efs_accesspt_id
  }))

  iam_instance_profile {
    arn = var.instance_profile_arn[1]
   }

  
  //ebs_optimized = true
  
  #default_version = 1

  update_default_version = true
 
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "tomcat"
    }
  }
}