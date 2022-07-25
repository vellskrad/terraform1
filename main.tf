#----------------------------------------------------------
# My Terraform
# Прекрасный код с ужасным описанием.
# Made by Yaroslav
#----------------------------------------------------------
terraform {
  required_providers {
    nginx = {
      source = "getstackhead/nginx"
      version = "1.3.2"
    }
  }
}
provider "nginx" {
}
provider "aws" {
 region = var.region
}
#-------------------------------------------------------------
data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" { 
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}
#-------------------------------------------------------------
resource "aws_launch_configuration" "my_webserver" {
  name_prefix                 = "WebServer-Highly-Available-LC-"
  image_id                    = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.my_sg.id]
  key_name                    = "00ead9ea8f0092c1d" #aws_key_pair.deployer.key_name
  associate_public_ip_address = false
  user_data                   = file("user_data.sh")
  #Создает новый ресурс прежде чем убивать старый
  lifecycle {
    create_before_destroy = true
  }
}
#resource "aws_key_pair" "deployer" {
#  key_name   = "deployer-key"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
#}
#------------------------Security Group----------------------------------
resource "aws_security_group" "my_sg" {
  name   = "Base Security Group"
  vpc_id = aws_vpc.vpc1.id
  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] #[var.vpc_cidr]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "${var.common_tags["base"]} for general" })
}
resource "aws_security_group" "NFS_sg" {
  name   = "Security Group for EFS"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    }

  tags = merge(var.common_tags, { Name = "${var.common_tags["base"]} for EFS" })
}
resource "aws_security_group" "DB" {
  name   = "Security Group for DB"
  vpc_id = aws_vpc.vpc1.id
 
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    }

  tags = merge(var.common_tags, { Name = "${var.common_tags["base"]} for EFS" })
}
#----------------------------------------------------------
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name    = "VPC_1"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_db_subnet_group" "default" {
  name       = "my_sub-gr"
  subnet_ids = [aws_subnet.public_az1.id, aws_subnet.private_az2.id]

  tags = {
    Name    = "My DB subnet group"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_subnet" "public_az1" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.main]
  tags = {
    Name    = "public subnet in az1"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_subnet" "public_az2" {
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.main]
  tags = {
    Name    = "public subnet in az2"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_subnet" "private_az1" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.3.0/24"
  tags = {
    Name    = "private subnet in az1"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_subnet" "private_az2" {
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.4.0/24"
  tags = {
    Name    = "private subnet in az2"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name    = "My_internet_gateway"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.bar.id
  subnet_id     = aws_subnet.private_az1.id
  tags = {
    Name    = "my_NAT_gateway"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }  
  depends_on = [aws_internet_gateway.main]
}
#----------------------------------------------------------
#resource "aws_placement_group" "test" {
#  name     = "test"
#  strategy = "spread"
#}
resource "aws_autoscaling_group" "my_webserver" {
  name                 = "ASG-${aws_launch_configuration.my_webserver.name}"
  launch_configuration = aws_launch_configuration.my_webserver.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "EC2"
#  placement_group      = aws_placement_group.test.id
  vpc_zone_identifier  = [aws_subnet.public_az1.id, aws_subnet.private_az2.id]

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      Owner  = "Yaroslav"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

#--------------Настройки файловой системы----------------------
resource "aws_efs_file_system" "EFS1" {
  creation_token = "my-product"
  depends_on = [aws_autoscaling_group.my_webserver]
  tags = {
    Name    = "My_EFS1"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_efs_mount_target" "efs_mount" {
  file_system_id  = aws_efs_file_system.EFS1.id
  subnet_id       = aws_subnet.private_az2.id
  security_groups = [aws_security_group.NFS_sg.id]
}
resource "aws_efs_access_point" "EFS_AP" {
  file_system_id = aws_efs_file_system.EFS1.id
  tags = {
    Name    = "My_EFS_AP"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"] 
  }
}
#---------------------------------------------------------------
resource "aws_eip" "bar" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.16"
  depends_on                = [aws_internet_gateway.main]
  
  tags = {
    Name    = "my elastic IP"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.public_az1.id
  private_ips = ["10.0.0.16"]

  tags = {
    Name    = "primary_network_interface"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
