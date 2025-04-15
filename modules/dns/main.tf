terraform {
  backend "s3" {}
}


resource "aws_route53_zone" "hosted_zone" {
  name = "cloudservicescity.com"
}


resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "jenkins.cloudservicescity.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.jenkins.dns_name]
}