# EFS File System
resource "aws_efs_file_system" "wordpress" {
  creation_token = "${var.owner}-wordpress-efs"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-efs"
  }
}

# EFS Mount Target in private subnet A
resource "aws_efs_mount_target" "private_a" {
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = aws_subnet.private_a.id
  security_groups = [aws_security_group.efs_sg.id]
}

# EFS Mount Target in private subnet B
resource "aws_efs_mount_target" "private_b" {
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = aws_subnet.private_b.id
  security_groups = [aws_security_group.efs_sg.id]
}
