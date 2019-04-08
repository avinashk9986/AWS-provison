variable "region" {}
variable "vpc" {}
variable "aws_subnet1" {}
variable "aws_subnet2" {}
variable "security_group" {}
variable "ami" {}

provider "aws" {
 access_key=***
 secret_key=***
  region     = "${var.region}"
}


resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}



resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*","ecr:*","cloudtrail:LookupEvents","ec2:*","elasticloadbalancing:*","cloudwatch:*","autoscaling:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}



resource "aws_instance" "master" {
  ami           = "${var.ami}"
  instance_type = "t2.medium"
  key_name = "login"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  subnet_id = "${var.aws_subnet1}"
  vpc_security_group_ids  = ["${var.security_group}"]
 tags {
    "Name" = "KUBE_MASTER"
    "kubernetes.io/cluster/test" = "owned"
  }
}



resource "aws_instance" "slave" {
  ami           = "${var.ami}"
  instance_type = "m5.xlarge"
  key_name = "login"
iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  subnet_id = "${var.aws_subnet2}"
  vpc_security_group_ids  = ["${var.security_group}"]
 tags {
    "Name" = "KUBE_SLAVE1"
    "kubernetes.io/cluster/test" = "owned"
  }
}


resource "aws_key_pair" "login" {
  key_name = "login"
  public_key = "${file("login.pub")}"
}


