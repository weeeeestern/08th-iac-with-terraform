variable "domain_name" {
  description = "Route 53 테스트용 도메인 이름"
  type        = string
  default     = "example.local"
}

variable "ip_main" {
  description = "A 레코드용 테스트 IP"
  type        = string
  default     = "192.168.0.100"
}
