# Provider 설정
provider "aws" {
  region = "ap-northeast-2"
}


# Public Hosted Zone 생성
resource "aws_route53_zone" "test_zone" {
  name = "example.local"    # 실제 등록된 도메인일 필요 없음
  comment = "Local Route53 test zone"
}

# A 레코드 (IP 주소 매핑)
resource "aws_route53_record" "a_record" {
  zone_id = aws_route53_zone.test_zone.zone_id
  name    = "www.example.local"
  type    = "A"
  ttl     = 300
  records = ["192.168.0.100"]
}

# CNAME 레코드
resource "aws_route53_record" "cname_record" {
  zone_id = aws_route53_zone.test_zone.zone_id
  name    = "api.example.local"
  type    = "CNAME"
  ttl     = 300
  records = ["www.example.local"]
}

# Weighted Routing Policy 예시 (트래픽 80/20)
resource "aws_route53_record" "blue" {
  zone_id        = aws_route53_zone.test_zone.zone_id
  name           = "app.example.local"
  type           = "A"
  set_identifier = "blue"
  ttl            = 300
  records        = ["10.0.1.10"]

  weighted_routing_policy {
    weight = 80
  }
}

resource "aws_route53_record" "green" {
  zone_id        = aws_route53_zone.test_zone.zone_id
  name           = "app.example.local"
  type           = "A"
  set_identifier = "green"
  ttl            = 300
  records        = ["10.0.1.20"]

  weighted_routing_policy {
    weight = 20
  }
}