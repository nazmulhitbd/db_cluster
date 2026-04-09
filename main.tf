terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}

# Database Variable Definition
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# 1. Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds_postgresql_sg"
  description = "Allow inbound traffic"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For testing. Narrow this down later for security.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. RDS Instance (Free Tier)
resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  db_name                = "postgres_db"
  engine                 = "postgres"
  engine_version         = "16.2"
  instance_class         = "db.t3.micro" # Free Tier
  username               = "dbadmin"
  password               = var.db_password
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  storage_type           = "gp2"
}

# Output the endpoint so you can connect to it later
output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}