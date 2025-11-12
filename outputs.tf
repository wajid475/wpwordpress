output "instance_id" {
  description = "ID of the EC2 instance"
  value       = try(aws_instance.instance.id, "")
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = try(aws_instance.instance.public_ip, "")
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.wordpress.dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.wordpress.endpoint
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.wordpress.id
}

output "cognito_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.wordpress.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.wordpress_cluster.name
}

output "wordpress_url" {
  description = "URL of the WordPress site"
  value       = "http://${aws_lb.wordpress.dns_name}"
}

output "domain_name" {
  description = "Domain name for DuckDNS"
  value       = var.domain_name
}

# Instrucciones para configurar DuckDNS
output "duckdns_instructions" {
  description = "Instructions to configure DuckDNS"
  value       = "Configure your DuckDNS domain '${var.domain_name}' to point to the ALB DNS: ${aws_lb.wordpress.dns_name}. You can do this by setting a CNAME record in your DuckDNS configuration."
}

# Instrucciones para configurar miniOrange OAuth
output "cognito_config_instructions" {
  description = "Instructions to configure miniOrange OAuth with Cognito"
  value       = <<EOT
Configure miniOrange OAuth in WordPress with the following settings:
- Client ID: ${aws_cognito_user_pool_client.wordpress.id}
- Client Secret: (none, since generate_secret is false)
- Authorization Endpoint: https://${aws_cognito_user_pool.wordpress.id}.auth.${var.aws_region}.amazoncognito.com/oauth2/authorize
- Token Endpoint: https://${aws_cognito_user_pool.wordpress.id}.auth.${var.aws_region}.amazoncognito.com/oauth2/token
- User Info Endpoint: https://${aws_cognito_user_pool.wordpress.id}.auth.${var.aws_region}.amazoncognito.com/oauth2/userInfo
- Scope: openid email
EOT
}
