
## 함수 구성

### code

```bash
variable "name" {
  default = "hello world"
}

locals {
                   # 함수이름(인자1, 인자2, ...)
  uppercase_name = upper(var.name)
}

output "result" {
  value = local.uppercase_name
}
```

### result

```bash
$ terraform apply

Outputs:
result = "HELLO WORLD"
```

### lesson

- 함수는 `함수이름(인자)` 형태로 사용
- terraform은 사용자 정의 함수를 만들 수 없고, 내장 함수만 사용 가능
- 함수는 주로 locals, output, resource 속성 안에서 사용