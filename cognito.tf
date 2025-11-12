# Cognito User Pool
resource "aws_cognito_user_pool" "wordpress" {
  name = "${var.owner}-wordpress-user-pool"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-user-pool"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "wordpress" {
  name = "${var.owner}-wordpress-app"

  user_pool_id    = aws_cognito_user_pool.wordpress.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  callback_urls = ["https://${var.domain_name}/wp-admin/"]
  logout_urls   = ["https://${var.domain_name}/"]

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-app"
  }
}
