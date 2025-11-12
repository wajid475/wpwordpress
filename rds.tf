# RDS Subnet Group
resource "aws_db_subnet_group" "wordpress" {
  name       = "${var.owner}-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-db-subnet-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "wordpress" {
  identifier              = "${var.owner}-wordpress-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  skip_final_snapshot    = true
  multi_az               = true
  backup_retention_period = 7

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-db"
  }
}
