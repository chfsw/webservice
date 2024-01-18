data "aws_route53_zone" "my_zone" {
  name = "weisongtest.com"
}

resource "aws_route53_record" "my_record" {
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "weisongtest.com"
  type    = "A"

  alias {
    name                   = aws_lb.my_lb.dns_name
    zone_id                = aws_lb.my_lb.zone_id
    evaluate_target_health = true
  }
  
}
resource "aws_acm_certificate" "my_certificate" {
  domain_name       = "weisongtest.com"
  validation_method = "DNS"
}

# Define a CNAME record
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.my_certificate.domain_validation_options: dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.my_zone.zone_id
    }
  }

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
  zone_id = each.value.zone_id
}
