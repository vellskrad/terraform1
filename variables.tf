
variable "region" {
  description = "Please Enter AWS Region to deploy Server"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "allow_ports" {
  description = "List of Ports to open for server"
  type        = list
  default     = ["80", "443", "22", "8080"]
}

variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map
  default = {
    Owner       = "Yaroslav"
    Project     = "Pilot project"
    CostCenter  = "12345"
    base        = "SecurityGroup"
  }
}
variable "vpc_cidr" {
  description = "Cidr block for my VPC"
  default     = "10.0.0.0/16"
}