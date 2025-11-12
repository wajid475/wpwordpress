# CloudWatch Log Group for WordPress
resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/ecs/${var.owner}-wordpress"
  retention_in_days = 30

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-log-group"
  }
}
