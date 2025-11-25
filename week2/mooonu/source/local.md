
## local 선언

### code

```bash
locals {
  service_name = "my-app"
  environment  = "production"
  common_tags = {
    Service     = "my-app"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
  instance_count = 3
}
```

### lesson

- 변수와 다르게 `type`, `default` 키워드 없이 `이름 = 값`형식으로 선언한다.
- `locals` 블록을 사용하여 여러 개의 지역 값을 한 번에 정의할 수 있다.
- 선언된 모듈 내에서만 접근 가능하고, 변수처럼 실행 시 입력받을 수 있다
	- **모듈 = 같은 폴더 안의 모든 `.tf` 파일들**

## local 참조

### code

```bash
variable "project" {
  type    = string
  default = "myproject"
}

locals {
  environment = "dev"
  full_name   = "${var.project}-${local.environment}"
  server_name = "${local.full_name}-server"
}

resource "local_file" "example" {
  content  = local.server_name
  filename = "${path.module}/output.txt"
}
```

### result

```bash
# output.txt
myproject-dev-server
```

### lesson

- local 값을 참조할 때는 `local.이름` 형식을 사용한다.