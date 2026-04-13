
#############################################################################################
# -----------------------------------------
# IAM Role trust policy (assume role)
# -----------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# -----------------------------------------
# Jenkins IAM Role, Policy, and Instance Profile
# -----------------------------------------
resource "aws_iam_role" "jenkins" {
  name               = "ec2role-jenkins"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "jenkins" {
  name        = "ec2-jenkins-policy"
  description = "Allowed actions for Jenkins EC2 instance"
  policy      = jsonencode(var.jenkins_policy)
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins.arn
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-ec2-profile"
  role = aws_iam_role.jenkins.name

  depends_on = [aws_iam_role_policy_attachment.jenkins_attach]
}

# -----------------------------------------
# Tomcat IAM Role, Policy, and Instance Profile
# -----------------------------------------
resource "aws_iam_role" "tomcat" {
  name               = "ec2role-tomcat"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "tomcat" {
  name        = "ec2-tomcat-policy"
  description = "Allowed actions for Tomcat EC2 instance"
  policy      = jsonencode(var.tomcat_policy)
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "tomcat_attach" {
  role       = aws_iam_role.tomcat.name
  policy_arn = aws_iam_policy.tomcat.arn
}

resource "aws_iam_instance_profile" "tomcat" {
  name = "tomcat-ec2-profile"
  role = aws_iam_role.tomcat.name

  depends_on = [aws_iam_role_policy_attachment.tomcat_attach]
}









