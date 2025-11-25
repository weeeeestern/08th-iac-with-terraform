
## 조건식

### code

```bash
variable "environment" {
  default = "dev"
}

locals {
  instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"
}
```

### result

```
environment = "prod" → instance_type = "t3.large"
environment = "dev"  → instance_type = "t2.micro"
```

### lesson

- terraform의 조건식은 `조건 ? 참일때값 : 거짓일때값` 형태의 삼항 연산자
- if-else 문은 없고, 삼항 연산자만 제공

## 조건에 따라 리소스 생성/미생성

### code

```bash
# 변수 선언
variable "enable_file" {
  default = true
}

resource "local_file" "foo" {
  count    = var.enable_file ? 1 : 0 # 조건식으로 개수 결정
  content  = "foo"
  filename = "${path.module}/foo.bar"
}

# 리소스가 생성되었을 때만 content 참조 아니면 ""
output "content" {
  value = var.enable_file ? local_file.foo[0].content : ""
}
```

### result
```
Changes to Outputs:
  + content   = "foo"
```

### lesson
- 여기서 `count`는 생성할 리소스의 개수를 나타낸다.

