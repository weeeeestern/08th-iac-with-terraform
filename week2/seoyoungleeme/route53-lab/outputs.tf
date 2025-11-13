output "zone_id" {
  description = "생성된 Route53 Hosted Zone ID"
  value       = aws_route53_zone.test_zone.zone_id
}

output "nameservers" {
  description = "Hosted Zone의 네임서버 목록"
  value       = aws_route53_zone.test_zone.name_servers
}