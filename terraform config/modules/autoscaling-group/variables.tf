variable "subnet_ids" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable "jenkins_launch_template_id" {
  description = "ID of launch template"
  type        = string
}

variable "tomcat_launch_template_id" {
  description = "ID of launch template"
  type        = string
}

/*
variable "launch_template_version" {
  description = "version of launch template"
  type        = string
}
*/