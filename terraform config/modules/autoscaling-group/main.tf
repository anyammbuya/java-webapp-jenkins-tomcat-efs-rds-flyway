locals {
  asg_configs = {
    jenkins = {
      name_prefix        = "jenkins-"
      launch_template_id = var.jenkins_launch_template_id # Unique LT ID
    }
    tomcat = {
      name_prefix        = "tomcat-"
      launch_template_id = var.tomcat_launch_template_id # Unique LT ID
    }
  }
}

# Autoscaling Group Resource for jenkins/tomcat

resource "aws_autoscaling_group" "project_zeus_asg" {

  for_each = local.asg_configs

  name_prefix = each.value.name_prefix
  desired_capacity   = 0
  max_size           = 0
  min_size           = 0

  lifecycle {
    ignore_changes = [
      min_size,
      max_size,
      desired_capacity,
    ]
  }
  
  vpc_zone_identifier  = var.subnet_ids
  
  health_check_type = "ELB"
  health_check_grace_period = 300 

  
  # Launch Template
  launch_template {
    id      = each.value.launch_template_id
    version = "$Latest"
  } 

  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup = 300 
      min_healthy_percentage = 50
    } 
  }  
   tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true
  }  
  tag {
    key                 = "asg"
    value               = each.key
    propagate_at_launch = true
  }  
  force_delete  = true
}


# Create Autoscaling policy


resource "aws_autoscaling_policy" "avg_cpu_utilization" {

  for_each               = local.asg_configs

  name                   = "avg_cpu_utilization-${each.key}"

# Provide a scaling policy type either "SimpleScaling", "StepScaling" or
# "TargetTrackingScaling". AWS will default to to "SimpleScaling if 
# this value is not provided

  policy_type = "TargetTrackingScaling"  

  autoscaling_group_name = aws_autoscaling_group.project_zeus_asg[each.key].name

  estimated_instance_warmup = 300  # 300 secs is default anyway

  # CPU Utilization is above 50

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }  

}
