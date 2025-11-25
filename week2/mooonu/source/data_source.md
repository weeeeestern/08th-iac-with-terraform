
## 데이터 소스 구성

### code

```bash
data "<리소스 유형>" "<이름>" {
	<인수> = <값>
}

data "local_file" "abc" {
	filename = "${path.module}/abc.txt"
}
```

### lesson

- `resource`가 인프라를 생성하고 관리하는 쓰기 작업이라면 `data`는 이미 존재하는 정보를 읽어오는 읽기 전용 작업

## 데이터 소스 속성 참조

### code

```bash
data "aws_vpc" "selected_vpc" {
	filter {
		name = "tag:Name"
		values = ["main-vpc"]
	}
}

resource "aws_subnet" "selected_vpc" {
	vpc_id = data.aws_vpc.selected_vpc
}
```

### lesson

- 데이터 소스로 읽은 대상을 참조하려면 값 앞에 `data`가 붙음
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

## 실습

### code

```bash
#1
resource "local_file" "abc" {
	content = "abc"
	filename = "${path.module}/abc.txt"
}

#2
data "local_file" "abc" {
	# 어느 파일을 읽어올지 지정
	filename = local_file.abc.filename
}

#3
resource "local_file" "def" {
	content = data.local_file.abc.content
	filename = "${path.module}/def.txt"
}
```

### lesson

- #1 local_file.abc 리소스 생성
- #2 데이터 소스로 파일 읽기
	- abc.txt를 읽음. 읽어온 내용은 `data.local_file.abc.content`로 참조 가능
- #3 local_file.def 리소스 생성
	- def.txt 파일을 생성하고 읽어온 내용을 저장