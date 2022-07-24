output "my_instance_id" {
  description = "InstanceID of our WebSite"
  value       = aws_launch_configuration.my_webserver.id
}

output "my_instance_arn" {
  description = "InstanceARN of our WebSite"
  value       = aws_launch_configuration.my_webserver.arn
}

output "my_sg_id" {
  description = "SecurityGroup of our WebSite"
  value       = aws_security_group.my_sg.id
}

output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.latest_amazon_linux.name
}

