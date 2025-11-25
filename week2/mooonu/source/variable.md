
## 변수 선언

### code
```bash
variable "<이름>" {
	<인수> = <값> 
 }
 
variable "image_id" {
	type = string
}
```

### lesson
- 데이터 타입
	- 기본 유형: string, number, bool, any
	- 집합 유형: list, map, set, object, tuple

## 변수 내 유효성 검사

### code

- 포트 번호 검사
```bash
variable "app_port" {
  type        = number
  description = "애플리케이션 포트"
  default     = 8080

  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "포트 번호는 1에서 65535 사이여야 합니다."
  }
}
```

### lesson

- `var.`은 변수를 참조할 때 사용하는 접두사
	- `app_port`라는 변수를 정의했고 이를 참조하려면 `var.app_port`
- `validation` 블록을 사용하면 변수 값의 범위나 형식을 검증하여 잘못된 설정을 사전 방지

## 변수 활용 파일 생성

### code

```bash
variable "my_password" {
	type = string
	default = "hi"
	sensitive = true
}

resource "local_file" "abc" {
	content = var.my_password # value: hiyo! 입력
	filename = "${path.module}/abc.txt"
}

# terraform init
# terraform plan
# terraform apply
```

### result

```bash
# abc.txt
hiyo!
```

### lesson

- 변수로 선언한 값이 참조되어 파일 내에 값이 추가되는 실행 계획과 결과를 확인
- variable 블록에서는 `content`가 아닌 `default`를 사용하여 기본값 설정
- `sensitive = true` 옵션을 추가하면 테라폼의 계획 출력에서 변수 값이 감춰진다.
- 변수에 값을 할당하는 방법
	- `default` (코드 내)
	- `terraform.tfvars` (파일)
	- `-var`  (CLI 옵션)