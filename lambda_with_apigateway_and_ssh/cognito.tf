resource "aws_cognito_user_pool" "pool" {
  name = "mypool"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client"
  allowed_oauth_flows_user_pool_client = true
  generate_secret = false
  allowed_oauth_scopes = ["aws.cognito.signin.user.admin","email", "openid", "profile"]
  allowed_oauth_flows = ["implicit", "code"] /*code:
Allows the Authorization Code Flow, where the client will receive an authorization code and later exchange it for tokens (access token, refresh token, etc.). This flow is typically used for server-side applications.

implicit:
Allows the Implicit Flow, where the client directly receives the access token (and optionally ID token) without exchanging an authorization code. This is commonly used in client-side applications (like single-page apps or mobile apps).

client_credentials:
Allows the Client Credentials Flow, where the client itself can authenticate directly and obtain an access token to call APIs on behalf of the application, without involving any user interaction. This flow is typically used in machine-to-machine communication.

refresh_token:
Allows the Refresh Token Flow, where the client can use a valid refresh token to obtain new access tokens or ID tokens without requiring the user to log in again.*/
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  supported_identity_providers = ["COGNITO"]

  user_pool_id = aws_cognito_user_pool.pool.id
  callback_urls = ["https://example.com"] #he Callback URL (also called Redirect URI) is the endpoint in your application to which the user is redirected after a successful login (or authentication) process.
  logout_urls = ["https://sumeet.life"] #the Logout URL is the endpoint in your application that is responsible for logging the user out of the application, and sometimes also logging them out from the OAuth 2.0 provider (the identity provider, such as Cognito, Google, etc.).
                                        #After the user has logged out, they are often redirected to this URL as part of the logout process.
}

resource "aws_cognito_user" "example" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username = "sumeet.n"
  password = "Test@123"
}