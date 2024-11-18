# resource "aws_acm_certificate" "my_api_cert" {
#   domain_name = "*.rinku.in.net"
# #   provider = aws.aws_useast1 # needs to be in US East 1 region
#   subject_alternative_names = ["*.rinku.in.net"] # Your custom domain
#   validation_method = "DNS"
# }