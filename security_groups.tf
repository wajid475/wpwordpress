data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Security Group para ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.owner}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-alb-sg"
  }
}

# Security Group para ECS
resource "aws_security_group" "ecs_sg" {
  name        = "${var.owner}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "From ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-ecs-sg"
  }
}

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.owner}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-rds-sg"
  }
}

# Security Group para EFS
resource "aws_security_group" "efs_sg" {
  name        = "${var.owner}-efs-sg"
  description = "Security group for EFS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "NFS from ECS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-efs-sg"
  }
}

# Security Group original (para SSH)
resource "aws_security_group" "sg" {
  name        = "${var.owner}-sg"
  description = "Allow inbound traffic via SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "My public IP"
    protocol    = var.sg_ingress_proto
    from_port   = var.sg_ingress_ssh
    to_port     = var.sg_ingress_ssh
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    description      = "All traffic"
    protocol         = var.sg_egress_proto
    from_port        = var.sg_egress_all
    to_port          = var.sg_egress_all
    cidr_blocks      = [var.sg_egress_cidr_block]
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-sg"
  }
}
