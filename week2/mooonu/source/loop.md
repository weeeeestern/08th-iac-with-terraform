
## count

### code

- 고정된 개수의 리소스 생성
```bash
variable "instance_count" {
  type    = number
  default = 3
}

resource "aws_instance" "server" {
  count         = var.instance_count
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "server-${count.index}"
  }
}
```

### result

```bash
server-0
server-1
server-2
```

### lesson

- `count`는 동일한 리소스를 고정된 개수만큼 생성할 때 사용한다.
- `count.index`로 각 인스턴스를 숫자 인덱스(0부터 시작)로 참조한다.
- 리소스는 `aws_instance.server[0]`, `aws_instance.server[1]` 형태로 state에 저장된다.

## for_each

### code

- set 기반 리소스 생성
```bash
variable "user_names" {
  type    = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "users" {
  for_each = var.user_names
  name     = each.value
  
  tags = {
    Role = "Developer"
  }
}
```

### result
```
aws_iam_user.users["alice"]
aws_iam_user.users["bob"]
aws_iam_user.users["charlie"]
```

### lesson

- `for_each`는 map이나 set을 받아서 각 요소마다 리소스를 생성한다
	- 각 리소스가 다른 설정값을 가질 때 유용
- `each.key`와 `each.value`로 현재 항목의 키와 값을 참조한다
- 리스트를 사용하려면 `toset()` 함수로 set으로 변환해야 한다.

## for

### code

- 조건부 필터링
```bash
variable "ports" {
  type    = list(number)
  default = [22, 80, 443, 3306, 8080]
}

locals {
  web_ports = [for port in var.ports : port if port < 1000]
}

output "web_ports" {
  value = local.web_ports
}
```

### result
```
web_ports = [22, 80, 443]
```

### lesson

- `if` 조건을 추가하여 특정 조건을 만족하는 항목만 포함할 수 있다
- 복잡한 데이터 구조를 단순화하거나 필터링할 때 유용

## dynamic

### code

- 보안 그룹 규칙 동적 생성
```bash
variable "ingress_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
	 # 첫 번째 규칙
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # 두 번째 규칙
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  # 총 두 개의 object가 리스트에 있는 것
}

resource "aws_security_group" "web" {
  name = "web-sg"
  
  # ingress 블록을 변수 기반으로 동적 생성
  dynamic "ingress" {
    for_each = var.ingress_rules # 리스트 순회 (object1, object2)
    content { # 각 항목마다 실제 블록 내용 정의
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### result
```
보안 그룹에 2개의 ingress 규칙이 생성됨:
- 포트 80 (HTTP)
- 포트 443 (HTTPS)
```

### lesson

- `dynamic` 블록은 **리소스 내부의 중첩 블록을 반복 생성**
- `for_each`로 반복하고, `content` 블록에서 실제 설정을 정의
- `블록이름.value`로 현재 항목을 참조
