resource "aws_db_instance" "default" {
  identifier                = "wordpress"
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = "db.t2.micro"
  storage_type              = "gp2"
  allocated_storage         = 20
  port                      = "3306"
  db_name                   = "My_DB"
  username                  = var.username
  password                  = var.password
  db_subnet_group_name      = aws_db_subnet_group.default.name
  availability_zone         = data.aws_availability_zones.available.names[0]
  publicly_accessible       = true
  final_snapshot_identifier = "BDfinalsnimok"
  vpc_security_group_ids    = [aws_security_group.DB.id]
  parameter_group_name      = aws_db_parameter_group.default.name
  //deletion_protection     = true
  tags = {
    Name    = "MySQL RDS instance"
    Owner   = var.common_tags["Owner"]
    Project = var.common_tags["Project"]
  }
}
resource "aws_db_parameter_group" "default" {
  name   = "my-rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
