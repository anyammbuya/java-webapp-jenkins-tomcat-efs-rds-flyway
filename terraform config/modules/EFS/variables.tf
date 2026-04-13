variable "subnet_ids" {
  type        = list(string)
  description = "Private subnets where EFS mount targets will be created"
}

variable "efs_sg_id" {
  type        = string
  description = "Security group ID allowing port 2049 from Jenkins/Tomcat"
}

variable "kms_key_id" {
  type = string
}

variable "tags" {
  type = map(string)
}