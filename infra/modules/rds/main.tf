resource "aws_security_group" "rds" {
  name   = "laptopai-${var.env}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]
  }

  tags = {
    Name = "laptopai-${var.env}-rds-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "laptopai-${var.env}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "laptopai-${var.env}-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "laptopai-${var.env}"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "laptopai"
  username = "postgres"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7

  tags = {
    Name = "laptopai-${var.env}"
  }
}