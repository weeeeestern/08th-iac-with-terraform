
## version

### code

- main.tf
```bash
terraform {
	required_version = "< 1.0.0"
}

resource "local_file" "abc" {
	content = "abs!"
	filename = "${path.module}/abc.txt"
}
```

- version 확인
`terraform version`

### 만약 명시된 version과 다르다면?

- `terraform init`
```bash
terraform init   
Initializing the backend...
╷
│ Error: Unsupported Terraform Core version
│ 
│   on main.tf line 2, in terraform:
│    2:   required_version = "< 1.0.0"
│ 
│ This configuration does not support Terraform version 1.13.5. To proceed, either choose
│ another supported Terraform version or update this version constraint. Version
│ constraints are normally set for good reason, so updating the constraint may lead to
│ other errors or unexpected behavior.
```

### 버전 제약 구문 연산자

- `1.0.0`: v1.0.0만을 허용
- `>= 1.0.0`: v1.0.0 이상의 모든 버전 허용
- `~> 1.2.3`: 1.2까지는 고정, 1.2.x 허용 / 1.3.x(x)
	- `~> 1.2`: 1까지 고정, 1.x 허용 / 2.0.0(x), 2.1.0(x)
	- `~> 1`: `~> 1.0`과 동일

## cloud block

### code

```bash
terraform {
	cloud {
		<cloud-configuration>
	}
	# . . .
}
```

### lesson

- `cloud` 블록 사용 시, terraform의 상태 파일을 terraform cloud에 저장
	- 기본적으로 `terraform.tfstate`를 로컬에 저장

## backend block

### code

```bash
terraform {
	backend "<TYPE>" {
		<backend-configuration>
	}
	# . . .
}
```

### lesson

- 테라폼 실행 시 저장되는 state(상태 파일)의 저장 위치를 결정하는 설정
	- default: local
- `cloud` 블록과 동시에 사용할 수 없다
	- `cloud` 블록은 상태 파일을 terraform cloud에 원격 저장
- 공유되는 백엔드에 state가 관리되면 테라폼이 실행되는 동안 `.terraform.tfstate.lock.info` 파일이 생성되어 해당 state를 동시에 사용하지 못하도록 잠금처리를 한다. (`terraform apply`)
- 백엔드가 바뀌면 init 명령어를 수행해 state의 위치를 재설정해야함
	- `terraform init -migrate-state`: 기존 state를 새 백엔드로 복사/이동
	- `terraform init -reconfigure`: 기존 state 무시하고 새 백엔드로 재구성