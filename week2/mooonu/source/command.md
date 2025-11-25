
## init
### code

- main.tf
```bash
resource "local_file" "abc" {
	content = "abs!"
	filename = "${path.module}/abc.txt"
}
```

- init
```bash
terraform init
```

### result

```bash
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/local...
- Installing hashicorp/local v2.5.3...
- Installed hashicorp/local v2.5.3 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### lesson

- `terraform init` 명령은 테라폼 구성 파일이 있는 작업 디렉토리를 초기화하는 데 사용된다. 
(이 작업을 실행하는 디렉터리를 루트 모듈이라고 부름)
프로바이더, 모듈 등의 지정된 버전에 맞춰 루트 모듈을 구성하는 역할을 수행한다.
- `terraform init -upgrade` 명령으로 프로바이더나 모듈의 버전을 최신 버전으로 업그레이드 가능

## validate

### code
- main.tf
```bash
resource "local_file" "abc" {
	content = "abs!"
	#filename = "${path.module}/abc.txt"
}
```

- validate
```bash
terraform validate
```

### result

```bash
Error: Missing required argument
│ 
│   on main.tf line 1, in resource "local_file" "abc":
│    1: resource "local_file" "abc" {
│ 
│ The argument "filename" is required, but no definition was found.
```

### lesson

- 디렉터리에 있는 테라폼 구성 파일의 유효성을 확인
	- 코드적인 유효성만 검토함 (api 작업x)
- `terraform validate -json` 명령을 통해 실행 결과를 JSON 형식으로 출력할 수 있음

## plan

### code
- main.tf
```bash
resource "local_file" "abc" {
	content = "abs!"
	filename = "${path.module}/abc.txt"
}
```

- plan
```bash
terraform plan
```

### result

```bash
Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.abc will be created
  + resource "local_file" "abc" {
      + content              = "abs!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./abc.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to
take exactly these actions if you run "terraform apply" now.
```

### lesson
- 테라폼으로 적용할 인프라의 변경 사항에 관한 실행 계획을 생성하는 동작
	- 실행 이전의 상태와 비교해 현재 상태가 최신화 되었는지 확인
	- 적용하고자 하는 구성을 현재 상태와 비교하고 변경점 확인
	- 구성이 적용될 경우 대상이 테라폼 구성에 어떻게 반영되는지 확인

- 출력되는 결과를 통해 어떤 변경이 적용될지 미리 검토할 수 있음

- `terraform plan -out=tfplan` 명령으로 실행 계획을 바이너리 형태의 파일로 생성하며 tfplan은 파일명이므로 수정가능
	- 해당 계획 파일은 일회성임, 계획 파일 생성 후 변경사항이 생기면 오류가 발생함

## apply

### code

- main.tf
```bash
resource "local_file" "abc" {
	content = "abs!"
	filename = "${path.module}/abc.txt"
}
```

- apply
```bash
terraform apply
```

### result

```bash
... # plan과 동일

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

### lesson

- plan 기반으로 작업을 실행하며 'yes' 입력으로 적용
	- `terraform plan -out=tfplan` 명령으로 실행 계획 파일을 생성한 뒤
	- `terraform apply tfplan` 명령으로 확인 단계 없이 즉시 적용 가능
 
## destroy

### code

- destroy
```bash
terraform destroy
```

### result

```bash
local_file.abc: Refreshing state... [id=db49e328884aa8d753d51e108a4837c070c2eabe]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # local_file.abc will be destroyed
  - resource "local_file" "abc" {
      - content              = "abs!" -> null
      - content_base64sha256 = "EXPMGxvySj+qV+ziIWLWqBvS6AGHoHKCt1si+3sgzU0=" -> null
      - content_base64sha512 = "xBI1kIzUR5qscJTrK0mCU8LFURXYyc4s2vy2BAw/y4i51Bh7FrvYXEyxDTMZa1jbDBdWV025Mq8B66O/umOd6g==" -> null
      - content_md5          = "c802e70ea6df6999104c11d91fe5bdc2" -> null
      - content_sha1         = "db49e328884aa8d753d51e108a4837c070c2eabe" -> null
      - content_sha256       = "1173cc1b1bf24a3faa57ece22162d6a81bd2e80187a07282b75b22fb7b20cd4d" -> null
      - content_sha512       = "c41235908cd4479aac7094eb2b498253c2c55115d8c9ce2cdafcb6040c3fcb88b9d4187b16bbd85c4cb10d33196b58db0c1756574db932af01eba3bfba639dea" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = "./abc.txt" -> null
      - id                   = "db49e328884aa8d753d51e108a4837c070c2eabe" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.
```

### lesson
- 테라폼 구성에서 관리하는 **모든 개체를** 제거하는 명령
	- `terraform apply -destroy`와 같다
- plan과 apply의 관계처럼 실행 계획이 필요함
	- `terraform plan -destroy`
- 일부만 제거하려면 항목을 코드에서 지우고 다시 `terraform apply` 실행하는 방안이 있음

## fmt

### code

- fmt
```bash
terraform fmt
```

### result

```bash
# before
resource "local_file" "abc" {
content = "abs!"
filename = "${path.module}/abc.txt"
}

# after
resource "local_file" "abc" {
	content = "abs!"
	filename = "${path.module}/abc.txt"
}
```

### lesson

- 테라폼 코드의 가독성과 스타일을 맞출 때 사용함