
## 리소스 구성

### code

```bash
resource "<리소스 유형>" "<이름>" {
  <인수> = <값>
}

resource "local_file" "drf" {
	content = "drf!"
	filename = "${path.module}/drf.txt"
}
```

### lesson

- 리소스 이름은 첫 `_`를 기준으로 앞은 프로바이더 이름, 뒤는 프로바이더에서 제공하는 리소스의 유형
	- 예) `local_file`: local 프로바이더에 속한 리소스 유형

## aws resouce 추가하기

### code

```bash
resource "aws_instance" "web-server" {
	ami           = "ami-abcd1234"
	instance_type = "t3.micro"
}
```

### result

- `init`
```bash
terraform init
Initializing the backend...
Initializing provider plugins...
. . .
- Installing hashicorp/aws v6.20.0...
- Installed hashicorp/aws v6.20.0 (signed by HashiCorp)
. . .
```

### lesson

- 특정 프로바이더의 유형만 추가해도 `init`을 수행하면 해당 프로바이더를 설치함
	- 예시에서는 `aws_instance`

