
## output 선언 및 활용

### code

```bash
output "instance_ip" {
  value       = aws_instance.web.public_ip
  description = "웹 서버의 공개 IP 주소"
}

output "instance_id" {
  value = aws_instance.web.id
}

# terraform plan
```

### result
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-0abcd1234efgh5678"
instance_ip = "54.123.456.789"
```

### lesson

- terraform 실행 후 확인하고 싶은 값을 출력할 수 있다
- `value`는 필수 속성이며, `description`은 선택



