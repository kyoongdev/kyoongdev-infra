/* resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.database_subnet[*].id

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "database_instance" {
  engine                 = "mysql"
  identifier             = var.rds_name
  allocated_storage      = 20
  engine_version         = "8.0.32"
  instance_class         = "db.t2.micro"
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = aws_db_parameter_group.default.name
  vpc_security_group_ids = ["${aws_security_group.database_sg.id}"]
  db_subnet_group_name = aws_db_subnet_group.default.name
  skip_final_snapshot    = true
  publicly_accessible    = false
} */