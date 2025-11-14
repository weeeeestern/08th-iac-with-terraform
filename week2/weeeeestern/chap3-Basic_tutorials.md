# [Chapter 3] 기본 사용법

154

테라폼 설치 , 환경변수 설정 후 실습 진행

# 1. Terraform 주요 커맨드

## terraform init

**루트 모듈**에서 테라폼 구성 파일이 있는 작업 디렉토리 초기화

![image.png](image/image.png)

`terraform init` 을 먼저 실행하지 않으면, `terraform plan` 실행 계획을 생성할 수 없다

프로바이더, 모듈, 백엔드 구성이 변경될 때도 init 명령어를 수행해야 한다.

- 다른 리모트 환경에서 init을 수행하면, 작업자 로컬과 다른 버전의 모듈이 설치될 수 있으므로 `.terraform.lock.hcl` 파일로 버전을 명시할 수 있다.
- 명시된 버전을 의도적으로 변경하려면 `terraform init -upgrade`

## terraform validate

디렉터리에 있는 테라폼 **구성 파일**의 유효성 확인

![image.png](image/image%201.png)

### validate 관련 옵션

- `-no-color` : 로컬이 아닌 외부 환경 (github actions 등) 에서 색상 표기문자(←[0m←[1m) 가 표기될 수 있다. 쟤네 없이 출력하기
- `-json` : 실행결과를 JSON 형식으로 출력하기

## terraform plan

인프라의 변경 사항에 대한 실행 **계획 생성**

![image.png](image/image%202.png)

### plan 관련 옵션

- `-detailed-exitcode` : **0**(변경사항 없는 성공), **1**(오류 있음), **2**(변경사항 있는 성공)
- `terraform plan -out=<파일명>` : 실행 계획 파일을 별도 작성- 플랜 만들기

![image.png](image/image%203.png)

## terraform apply

생성된 plan을 기반으로 **작업 실행** 

 terraform plan과 동일한 동작 수행 후, 해당 플랜을 적용할 것인가 묻는 과정 有

![image.png](image/image%204.png)

### apply 관련 옵션

- `terraform apply <파일명>` - 프로비저닝이 완료됐으므로 (실행 계획이 있으므로) 즉시 적용

![image.png](image/image%205.png)

### 멱등성

원하는 상태를 적어놓고 (선언)
그 상태와 다르면 맞추고, 같으면 아무것도 안 한다. (**멱등성**)

- 새 resource 추가 후, 변경하기 전의 실행 계획 적용 시 에러 발생 
ㅡ 변경 이후, 이전 계획은 더 사용할 수 없다

![image.png](image/image%206.png)

- 변경사항을 제거하는 동작을 한 후, 이전 계획 apply 가능

![image.png](image/image%207.png)

### plan, apply 둘 다 사용가능한 옵션

- `-replace=<대상 리소스 주소>` : 대상을 삭제 후 생성하는 계획 적용

![image.png](image/image%208.png)

※ 일반적으로 `terraform apply` 명령으로만 리소스를 생성한다. 
하지만 외부 실행환경을 로컬에서 구성할 때, `terraform validate`와 `terraform plan`을 실행하여 변경사항 적용 이전에 검증하고 승인하는 단계를 거치는 것이 좋다.

## terraform destroy

테라폼 구성파일에서 관리하는 **모든** resource 지우기

![image.png](image/image%209.png)

부분적으로 지우려면 코드에서 해당하는 일부 리소스 제거 후 apply

### destroy 관련 옵션

- `-auto-approve` : destroy 계획이 없으면 계획에 추가하고, 따로 승인(yes/no) 없이 destroy 실행됨

## terraform fmt

테라폼 구성파일을 표준 스타일로 적용 (코드 정렬, 빈칸, 내려쓰기 등의 규칙)

### fmt 관련 옵션

- `-recursive`: 하위 디렉토리에 있는 모든 테라폼 구성 파일에도 fmt 적용

# 2. HCL 언어

테라폼의 코드는 HCL 언어 사용!

AWS의 CloudFormation은 JSON 사용 

HCL은 JSON보다

- 더 간결하고 읽기 쉽다
- function 제공
    - 주석 표시 가능
    - 변수 정의 가능

# 3. 테라폼의 블록 종류

테라폼의 구성을 명시한다 ㅡ 특히 타인과 협업할 때는 명시적인게 좋다

| 블록 | 역할 | 예시 |
| --- | --- | --- |
| **terraform** | 테라폼 전역 설정 (버전, 백엔드 등) | `terraform { required_version = ">=1.0.0" }` |
| **provider** | AWS, Azure, GCP 같은 클라우드 API 연결 정의 | `provider "aws" { region = "ap-northeast-2" }` |
| **resource** | 실제 생성되는 인프라(EC2, S3 등) 정의 | `resource "aws_s3_bucket" "mybucket" { bucket = "demo" }` |
| **variable** | 입력값 정의 (모듈 재사용용) | `variable "region" { default = "ap-northeast-2" }` |
| **output** | 실행 후 출력값 표시 | `output "bucket_id" { value = aws_s3_bucket.mybucket.id }` |
| **module** | 코드 재사용을 위한 하위 구성 호출 | `module "vpc" { source = "./modules/vpc" }` |
| **data** | 이미 존재하는 리소스 조회(읽기 전용) | `data "aws_ami" "ubuntu" { most_recent = true }` |
| **locals** | 내부 계산용 변수 | `locals { env = "dev" }` |

## 테라폼 블록

깃허브의 테라폼 공식 레지스트리 - Changelog

- 테라폼 블록에 지정된 버전과 실행 환경의 테라폼 버전을 맞춰야 한다!

![image.png](image/image%2010.png)

![image.png](image/image%2011.png)

### Provider 버전 정의

- terraform 블록 안의 `required_providers` {…} 에 정의
- 테라폼 공식 레지스트리 페이지에서도 Provider 마다의 샘플 코드 확인 가능

## 백엔드 블록

State (상태 파일)의 저장 위치 선언

**하나의 백엔드만 허용** 

- 상태 저장 파일을 공유할 수 있는 외부 백엔드 저장소

### State

패스워드, 인증서 같은 민감한 데이터 有 → 접근 제어 필요

기본 백엔드 디폴트값은 local 

- 로컬 backend: 같은 PC에서 State 파일을 동시에 사용할 수 없도록 잠금 파일(`.lock.hcl`)이 생성됨
- ex. S3 backend: 따로 Dynamo DB 락 기능을 설정하여 State 파일 동시실행 막기

### 백엔드 설정 변경

백엔드가 설정되면 `terraform init` 명령어를 재수행해서 State 위치를 재설정해야 한다.

| 명령 | 이전 백엔드 설정 | 상태 마이그레이션 (테라폼 상태파일(tfstate)을 A 백엔드에서 B 백엔드로 옮기기) |
| --- | --- | --- |
| `terraform init` | 존중(재사용) | 변경 감지 시 묻고 진행(또는 `-migrate-state`) |
| `terraform init -reconfigure` | **무시** | **안 함**(오직 재설정만) |

## 리소스 블록

- 리소스 이름 : <Provider 이름>_<리소스 유형>
    - local_file
- `resource “리소스 이름” “식별자”`
    - `resource “local_file” “abc” { … }`

![image.png](image/image%2012.png)

### 종속성

테라폼의 종속성 : resource, module 블럭으로 프로비저닝되는 각 요소들의 생성 순서 구분

두 리소스 구성에 종속성이 있는 경우

![image.png](image/image%2013.png)

![image.png](image/image%2014.png)

- **Graphviz**로 시각화하기 (`terraform graph` 실행 결과를를 [graph.dot](http://graph.dot) 파일로 만들기)

속성을 주입하지 않아도 두 리소스 간에 종속성이 필요한 경우

![image.png](image/image%2015.png)

- `depends_on` 선언

### 리소스 속성 참조

![image.png](image/image%2016.png)

인수(Arguments): 리소스 생성 시 사용자가 설정하는 값

속성(Attributes): 사용자가 설정 불가능, 리소스 **생성 이후**로 확인할 수 있는 고유값

### 수명주기

메타인수 **`lifecycle`**  

- **`create_before_destroy` : 리소스를 수정해야 할 때**
    
    기본적으로 Terraform은 기존 거 삭제 후→ 새로 생성 순
    
    `create_before_destroy = true` 라면 **새로 생성 후→ 기존 거 삭제**
    
    ex. 리소스를 업데이트할 때 발생하는 서비스 중단 시간(downtime)을 최소화
    
    ※주의: 하드코딩된 name을 명시적으로 선언할 때
    
    ```c
    resource "aws_instance" "web" {
      name = "my-server"  # 사용자 지정 이름 (고정)
     
        lifecycle {
            create_before_destroy = true   # 만약 수정한다면 생성 후 삭제
        }
    }
    ```
    
    새 리소스가 고정된 이름(=이미 있는 이름)으로 또 만들려 하기 때문에 생성 실패  ⇒ 
    tags의 Name (`tags = {Name = "my-web-server"}`) 사용하기! 해당 값은 고유할 필요 없다
    
    ※주의: 하드코딩된 종속성을 선언할 때
    
    ```c
    resource "aws_instance" "web" {
        # ...       
        lifecycle {
      create_before_destroy = true
        }
    } # 생성된 web의 public_ip 가 1.2.3.4 속성값을 가질 때
    
    resource "aws_route53_record" "www" {
      # ...
      records = ["1.2.3.4"] # web의 IP 속성값을 하드코딩
    }
    ```
    
    생성되는 새 리소스의 ip값이 달라졌는데, aws_route53_record.www 는 이미 삭제된 ip를 가리키고 있게 됨 ⇒리소스 간의 의존성을 명확하게 참조 (=VM 리소스의 속성을 동적으로 표시)
    
    ```c
    resource "aws_instance" "web" {
      # ...
        lifecycle {
      create_before_destroy = true
        }
    }
    
    resource "aws_route53_record" "www" {
      # ...
      records = [aws_instance.web.public_ip] # VM 리소스의 public_ip 속성을 **동적 참조**
    }
    ```
    

- **`prevent_destroy`** : **해당 리소스를 삭제할 때 명시적으로 거부하라**
    
    `terraform apply`나 `terraform destroy`로부터 리소스가 삭제되는 것을 막고 오류를 발생시킴
    
    ex. 운영 DB 보호
    
- **`ignore_changes = [...]`** : **인수 변경 사항을 무시하라**
    
    `terraform plan` 또는 `apply` 시 변경을 감지해도 변경을 반영하지 않고 무시시킴
    
    ex. 다른 시스템이 자동으로 바꾸는 태그
    

## 데이터 소스 블록

Resource 블록 정의와 유사하지만…

but **`data` 블록**은 리소스를 '관리(생성/수정/삭제)'하는 것이 아니라, 

이미 존재하는 리소스를 '**읽어오는(Read**)' 용도

### 수명주기

**`lifecycle`**의 제한적인 사용 - `data` 소스는 Terraform이 '생성'하거나 '파괴'하는 대상이 아니다.

- **`precondition` : 시작하기 전 조건을 검증**
    
    `terraform plan` 단계에서, 사용자가 코드에 입력한 **인수(arguments)값** 올바른지 확인
    
    리소스 생성 이전의 조건을 precondition {…} 에 선언
    
    ex. 잘못된 값(예: 정책에 어긋나는 이름, 너무 작은 디스크 크기)이 입력되는 것을 사전에 차단
    

- **`postcondition` : 작업이 끝난 후 조건을 검증**
    
    `terraform apply` 실행 직후, 리소스가 생성된 후, **속성(attributes)값** 올바른지 확인
    
    리소스 생성 이후의 조건을 postcondition {…}에 선언
    
    ex. 원했던 상태(예: 암호화가 활성화됨, 특정 IP가 할당됨)가 맞는지 최종적으로 확인
    

### 데이터 소스 속성 참조

![image.png](image/image%2017.png)

인수(Arguments): 데이터 소스를 가져오기 위한 조건

속성(Attributes): 가져온 데이터 소스의 내용

ex. `my-script.sh`라는 **이미 있는 파일의 내용을 읽어서** `aws_instance`에 전달하기

```c
# 1. "my-script.sh" 파일을 읽어오라고 data 소스 정의
**data** "local_file" "init_script" {
  filename = "${path.module}/my-script.sh"
}

# 2. 다른 리소스에서 ".content" 속성으로 파일 내용을 참조
**resource** "aws_instance" "web" {
  ami           = "ami-0abcdef123"
  instance_type = "t2.micro"

  # data 소스의 "content" 속성을 사용
  user_data = data.local_file.init_script.content
}
```

**`resource** "local_file"`로 `my-script.sh`를 지정하면, 테라폼은 그 파일을 읽는 게 아니라, 생성하고 관리하려고 시도할 것이다. 따라서 이 상황에서 resource 블럭은 적절하지 않음

## 입력 변수 블록

`terraform plan` 수행 시, 외부에서 값을 주입받기 위한 파라미터 정의

코드를 재사용하기 쉬워짐

- ex. 똑같은 서버(VM)를 개발 환경과 운영 환경에 따로 만들 때, 서버 이름이나 사양을 변수로 빼두면 편리

`variable` 블록은 보통 `variables.tf` 파일에 모아서 선언한다.

### 입력 변수 속성 참조

![image.png](image/image%2018.png)

var.<이름>

![image.png](image/image%2019.png)

- type = list(string)
    - 순서가 있고, 중복이 허용되며, **인덱스**로 참조함
    - tuple 타입 - list 같이 배열이지만, 여러 타입을 섞어서 선언 가능
    
    ```c
    variable "subnet_ids" {
      type        = list(string)
      description = "배치할 서브넷 ID 목록 (순서대로)"
      default     = ["subnet-c", "subnet-a", "subnet-b"]
      # list는 이 순서("c", "a", "b")를 그대로 유지합니다.
    }
    
    # --- 사용 예시 (output) ---
    output "first_subnet" {
      # list는 0부터 시작하는 숫자인 "인덱스"로 값을 참조합니다.
      value = "첫 번째 서브넷은 ${**var.subnet_ids[0]**} 입니다." # "subnet-c"
    }
    ```
    
- type = set(string)
    - 순서가 없고, 중복이 자동 제거되며, **set 타입의 변수 블럭 자체**로 참조함함
    
    ```c
    variable "allowed_ips" {
      type        = set(string)
      description = "방화벽에 허용할 고유 IP 목록"
      default     = ["192.168.0.1", "10.0.0.1", "192.168.0.1"] # 중복된 값
    }
    
    # --- 사용 예시 (output) ---
    output "processed_ips" {
      # 1. "192.168.0.1" (중복)이 자동으로 제거됩니다.
      # 2. "10.0.0.1", "192.168.0.1"이 알파벳순으로 자동 정렬됩니다.
      #    결과: ["10.0.0.1", "192.168.0.1"]
      value = **var.allowed_ips**
    }
    
    output "cannot_access_by_index" {
      # value = var.allowed_ips[0] # <--- 이 코드는 에러를 발생시킵니다!
      value = "set은 인덱스로 참조할 수 없습니다."
    }
    ```
    
- type = map(string)
    - `key-value` 쌍. `key`는 고유해야 한다, **key** 값으로 참조
    - object 타입 - map 처럼 key-value 쌍이지만 여러 타입을 섞어서 선언 가능
    
    ```c
    variable "server_tags" {
      type        = map(string)
      description = "서버에 적용할 태그 맵"
      default = {
        # 순서를 뒤죽박죽 선언: Name, Environment, Owner
        "Name"        = "my-server"
        "Environment" = "production"
        "Owner"       = "admin"
      }
    }
    
    # --- 사용 예시 (output) ---
    output "get_environment_tag" {
      # map은 "키" 이름으로 값을 참조합니다.
      value = "이 서버의 환경은 ${**var.server_tags["Environment"]**} 입니다." 
    }
    
    output "sorted_map" {
      # 선언은 N, E, O 순으로 했지만,
      # 키(key) 기준 알파벳순으로 자동 정렬됩니다.
      # 결과: Environment, Name, Owner 순서
      value = var.server_tags
    }
    ```
    

### 유효성 검사

`validation` 블록 안에서 조건인 `condition` 값의 결과는 boolean 

```c
variable "instance_count" {
  type        = number
  description = "생성할 인스턴스 개수"
  default     = 1

  validation {
    # 1개 이상 5개 이하만 허용
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "인스턴스 개수는 1에서 5 사이여야 합니다."
  }
}
```

### 민감한 변수 취급

`sensitive = true`

- **계획(Plan) 단계**: `terraform plan`을 실행하면, `local_file`의 `content`가 `"password"`라는 실제 값 대신 `(sensitive)`라고 표시됨
- **실행(Apply) 단계**: 리소스는 실제 값(`"password"`)을 정상적으로 전달받아 `abc.txt` 파일을 생성함
- **상태(State) 파일**: `terraform.tfstate` 파일 안에는 `local_file` 리소스의 `content` 속성이 `"password"`라고 평문(plaintext)으로 그대로 저장

```c
variable "my_password" {
  default   = "password"
  sensitive = true
}

resource "local_file" "abc" {
  content  = var.my_password
  filename = "${path.module}/abc.txt"
}
```

※ 따라서 **`tfstate` 파일**은 비밀번호, API 키 등과 동일하게 취급하여 절대로 Git 같은 곳에 커밋하면 안 된다!

### 입력 변수 우선순위

입력 변수 목적 : 코드 내용을 직접 수정하지 않고, 외부에서 값을 "주입"받아 **코드의 재사용성을 높이기**

변수 선언 우선순위를 이용하여 로컬 환경과 빌드 서버의 설정을 다르게 적용시킬 수 있다.

| **우선순위** | **방식** | **설명** |
| --- | --- | --- |
| **🥇 1 (최고)** | `-var="name=value"` | **CLI 플래그:** `apply` 시점에 직접 값을 주입합니다. (가장 강력함) |
| **🥈 2** | `*.auto.tfvars` | **자동 변수 파일:** `terraform.tfvars`보다 나중에 로드되어 값을 덮어씁니다. (환경별 오버라이드용) |
| **🥉 3** | `terraform.tfvars` | **표준 변수 파일:** 해당 디렉터리의 공통 변수 값을 정의합니다. (프로젝트 공통값) |
| **4** | `TF_VAR_<name>` | **환경 변수:** 셸(터미널)에 설정된 변수입니다. (CI/CD 파이프라인에서 유용) |
| **5 (최저)** | `default = "..."` | **기본값:** `variables.tf` 파일에 선언된 `default` 값입니다. |
| **(해당 없음)** | `Enter a value` 프롬프트 | **최후의 수단:** 1~5순위의 값이 **모두 없을 때만** 사용자에게 직접 입력을 요청하는 동작입니다. |

## 로컬 블럭

`variable`이 외부에서 값을 주입받는 '입력(Input)'이라면, `locals`는 코드 **내부**에서 값을 가공하거나 조합해서 사용하는 중간 계산 값

- 반복 제거**:** 코드 여기저기서 반복적으로 사용되는 값(예: 공통 태그, 이름 짓기 규칙)을 `locals`로 한곳에 정의해두면, 나중에 수정할 때 그 한 곳만 바꾸면 됨
- 가독성 향상
- 값 가공 : variable 그대로 쓰지 않고, if문이나 함수를 이용해서 값을 가공할 때 유용함
- **`variable`과 차이점:** `locals` 블록 안에서 정의된 값은 `terraform apply`를 실행할 때 외부에서 `-var` 등으로 덮어쓸 수 없습니다. 오직 코드 내부에서만 사용된다.

### 로컬 속성 참조

서로 다른 파일에 선언된 local이여도, 참조할 수 있다. → 하지만 값이 파편화되어 유지보수가 어려워질 수 있으므로 로컬 파일 하나에 전부 모아두는 게 좋은 구조라고 한다

```c
**locals** {
  # "prod-web"이라는 값을 "prefix"라는 별명으로 저장
  prefix = "prod-web"
}
```

```c
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"

  tags = {
    # local.prefix 별명을 가져와서 "-vm"을 붙임
    # 결과: "prod-web-vm"
    Name = "${**local.**prefix}-vm"
  }
}
```

## 출력 블럭

모듈 내부에서 생성된 리소스의 속성 값을 외부(다른 모듈, 터미널)에서 읽어가거나 참조할 수 있게 함 → 캡슐화 역할을 하는 것이 java의 getter와 비슷

Terraform `apply`가 성공적으로 다 끝나고 나면, `outputs` 블록에 정의한 값들이 최종적으로 계산

## 반복문

### count

리소스나 모듈을 반복적으로 생성할 때, 정의를 복붙하지 않고 관리할 수 있게 해주는 메타인수

- 동작 방식: `count`에 정수(integer) 값을 지정하면, Terraform은 해당 리소스(또는 모듈)를 그 숫자만큼 복제하여 생성
- 인덱스 참조: 생성된 각 리소스는 `count.index`라는 특별한 참조 변수를 갖게 됩니다. 이 인덱스는 0부터 시작하여 1씩 증가
- 리소스 주소: `count`로 생성된 특정 리소스는 `리소스타입.이름[인덱스번호]` (예: `local_file.abc[0]`) 형식으로 참조

```c
variable "names" {
  default = ["a", "b", "c"]
}

resource "local_file" "abc" {
  count    = length(var.names) # count는 3이 됨
  content  = "abc"

  # var.names[count.index]로 리스트 요소에 직접 접근
  filename = "${path.module}/abc-${var.names[count.index]}.txt"
}
```

※`count`는 리스트의 중간 값이 변경되거나 삭제될 경우,
 해당 요소 뒤의 모든 리소스가 **불필요하게 파괴(destroy)되고 재생성(add)**되는 문제를 유발한다!

ex. `["a", "b", "c"]` 리스트(count=3)를 기반으로 3개의 리소스(`[0]`, `[1]`, `[2]`)를 생성

리스트의 중간 요소인 "b"를 삭제하여 `["a", "c"]` (count=2)로 변경

→ count는 2가 됐고, count는 index에 의존하므로 
맨 마지막 c를 삭제함. index = 1 의 값이 b에서 c로 변경됐다고 생각하고 c를 새로 생성 
ㅡ `Plan: 2 to add, 4 to destroy`

### for each

`count`가 숫자(인덱스)를 기반으로 반복하는 반면, 

`for_each`는 **`map` 또는 `set`**의 **고유한 키(key)**를 기반으로 반복

```c
resource "local_file" "abc" {
  # 이 map의 key ("a", "b")의 개수만큼 (즉, 2개) 리소스가 생성됩니다.
  for_each = {
    a = "content a"
    b = "content b"
  }

  # 'each' 객체를 사용하여 각 항목의 key와 value에 접근
  content  = each.value   # "content a" 또는 "content b"
  filename = "${path.module}/${each.key}.txt" # "a.txt" 또는 "b.txt"
}
```

- `each.key`: `map`의 **key** 값 (예: "a", "b")
- `each.value`: `map`의 **value** 값 (예: "content a", "content b")

### for

`for` 표현식은 `list`, `map`, `set` 같은 컬렉션 데이터를 변환하거나 필터링

```c
value = [for v in var.names: upper(v)]
```

- **`for_each` (Meta-Argument):**
    - **리소스/모듈 블록** 자체에 사용됩니다.
    - **리소스/모듈을 여러 개 복제**할 때 사용합니다. (예: 5개의 VM 인스턴스 생성)
    - `resource "aws_instance" "example" { for_each = ... }`
- **`for` (Expression):**
    - `value`, `content`, `tags` 등 **인수(argument)의 값**으로 사용됩니다.
    - **데이터(값) 자체를 변형**할 때 사용합니다. (예: 리스트의 모든 값을 대문자로 변경)
    - `tags = { for k, v in var.tags: upper(k) => v }`

### dynamic

`dynamic` 블록은 단일 리소스 **내부에** 중첩되는 `ingress`, `egress`, `setting` 같은 **구성 블록**을 동적으로 반복 생성하기 위해 사용됩니다.

- **문제점 (코드 3-60):** `aws_security_group` 리소스 하나에 여러 `ingress` (인바운드 규칙) 블록을 정의하려면, 코드를 수동으로 복사하여 붙여넣어야 합니다. (유지보수 어려움)
- **해결책 (`dynamic`):** `count`나 `for_each`가 **리소스 전체**를 복제하는 것과 달리, `dynamic`은 리소스 **내부의 특정 부분**(예: `ingress` 규칙)만 `map`이나 `list` 같은 변수를 기반으로 동적으로 생성해줍니다.

```c
# 1. 동적으로 사용할 포트 리스트 정의
variable "ingress_ports" {
  type    = list(number)
  default = [80, 443, 22] # 이 리스트의 개수만큼 ingress 블록이 생성됨
}

# 2. 보안 그룹 리소스
resource "aws_security_group" "web_sg" {
  name = "web-server-sg"

  # 3. 'ingress' 블록을 동적으로 반복 생성
  **dynamic "ingress"** {
    # 'ingress_ports' 리스트를 set(집합)으로 변환하여 반복
    for_each = toset(var.ingress_ports)

    # 4. 'content'가 실제 생성될 ingress 블록의 내용
    content {
      protocol    = "tcp"
      # ingress.value는 현재 반복 중인 값 (80, 443, 22)
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
```

## 조건식

- `조건 ? true일_때_반환할_값 : false일_때_반환할_값`

```c
output "content" {
  # 리소스가 생성되었을 때(true)만 [0] 인덱스로 접근하고,
  # 아니면(false) 빈 문자열("")을 반환하여 오류를 방지합니다.
  value = var.enable_file ? local_file.foo[0].content : ""
}
```

## 함수

Terraform에는 프로그래밍 언어처럼 다양한 내장함수가 있다.

- 문자열 조작(예: `upper`), 숫자 계산(예: `max`), 타입 변환, 날짜/시간 처리, 컬렉션/IP 주소 다루기 등.

## 프로비저너

프로비저너는 Terraform 리소스가 생성된 직후에, 해당 리소스(예: VM)나 로컬 머신에서 특정 작업(스크립트 실행, 파일 복사 등)을 수행하기 위해 사용됨

선언된 리소스 블록의 작업이 종료되고나서, 프로비저너 작업 수행

ex. 클라우드에 리눅스 VM 설치하기 +a (특정 패키지 설치 or 특정 파일 생성 …)

- 테라폼의 구성과 별개로 동작
- 프로비저너로 실행된 결과는 테라폼의 상태파일에 동기화되지 않는다 ㅡ 앵간하면 쓰지마

### local-exec

- 리소스가 생성된 후, Terraform을 실행하는 로컬 머신에서 명령어를 실행합니다.
- (예: VM의 IP 주소를 로컬의 `inventory` 파일에 기록)

### remote-exec

- 리소스가 생성된 후, 새로 생성된 원격 리소스(VM)에 SSH 등으로 접속하여 명령어를 실행합니다.
    - `file`과 `remote-exec` 프로비저너는 원격 서버에 접속해야 하므로,
     **`resource`** 블록 내에 **`connection`** 블록이 **필수**
    - bastion host를 이용하는 경우에도 관련인수를 제공함
    
    ```c
    (인스턴스) 1대 생성
    resource "aws_instance" "web_server" {
      ami           = "ami-04b762b4289fba92b" # 예: Amazon Linux 2 AMI
      instance_type = "t2.micro"
    
      # 2. SSH 접속 정보 (file, remote-exec가 사용)
      connection {
        type        = "ssh"
        user        = "ec2-user" # Amazon Linux의 기본 사용자
        private_key = file("~/.ssh/my-key.pem") # 본인의 .pem 키 경로
        host        = self.public_ip
      }
    ...
    }
    ```
    
- **`inline`**
    - 실행할 **명령어**들을 리스트(`[ ]`) 형식으로 코드에 직접 작성합니다.
    - 간단한 한두 줄의 명령에 적합합니다.
    - 예: `inline = ["sudo yum update -y", "sudo yum install -y httpd"]`
- **`script`**
    - 실행할 **하나의 로컬 셸 스크립트 파일** 경로를 지정합니다.
    - Terraform이 이 스크립트 파일을 원격 서버에 자동으로 복사한 뒤 실행시킵니다.
    - 예: `script = "scripts/setup.sh"`
- **`scripts`**
    - 실행할 **여러 개의 로컬 셸 스크립트 파일** 경로를 리스트(`[ ]`)로 지정합니다.
    - `script`와 마찬가지로 파일들이 원격 서버에 복사되며, 리스트에 나열된 순서대로 실행됩니다.
    - 예: `scripts = ["scripts/common.sh", "scripts/install_app.sh"]`

### file

- Terraform이 실행되는 로컬 머신의 파일을 새로 생성된 리소스(VM)로 **복사**합니다.
- (예: 로컬의 `nginx.conf` 파일을 VM의 `/etc/nginx/` 경로로 복사)

## null_resource

아무 작업도 하지 않는 가상의 리소스. 주로 **`provisioner` (프로비저너)를 담는** 역할

예: `aws_instance`에 프로비저너를 직접 연결할 때 발생하는 **순환 의존성 문제**를 해결하기 위해

문제:

1. `aws_instance` ("foo")는 프로비저너를 실행하기 위해 `aws_eip` ("bar")의 **공개 IP 주소**(`aws_eip.bar.public_ip`)가 필요합니다.
2. `aws_eip` ("bar")는 `aws_instance`에 연결되기 위해 `aws_instance`의 **ID**(`aws_instance.foo.id`)가 필요합니다.

`foo`는 `bar`를 기다리고, `bar`는 `foo`를 기다리는 닭과 달걀 문제가 발생. 이로 인해 `terraform plan` 실행 시 `Error: Cycle` (순환 오류)가 발생.

해결 방법:

- `aws_instance` ("foo")에서 `provisioner` 블록을 **제거**합니다.
- `aws_eip` ("bar")가 `aws_instance` ("foo")에 정상적으로 의존하여 생성/연결되도록 둡니다.
- `null_resource` ("barz")를 새로 정의하고, `provisioner` 블록을 이 리소스로 옮깁니다.
- 이 `null_resource`의 `connection` 블록이 `aws_eip.bar.public_ip`를 참조하게 합니다.

**`trigger`**: `null_resource` 강제 재실행

- `null_resource`는 실제 속성이 없기 때문에, 한 번 생성되면 Terraform은 `apply`를 다시 해도 "변경된 사항이 없음"으로 간주하여 프로비저너를 다시 실행하지 않는다.
- `trigger`는 `map` 형식의 인수로, **이 블록 안의 값이 변경되면** Terraform이 `null_resource`를 "변경됨"으로 인식하여 **강제로 파괴(destroy)하고 재생성한다**.
- 리소스가 재생성되므로 `provisioner`도 다시 실행된다.

## terraform_data

`null_resource`처럼 그 자체로 아무 작업도 수행하지 않지만, **데이터를 저장**하거나 다른 리소스의 **변경을 감지하여 동작을 트리거**하는 용도

```c
# 1. AWS 인스턴스 (VM) 생성
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # 예: Amazon Linux 2
  instance_type = "t2.micro"
}

# 2. terraform_data (트리거 감지기)
# 이 리소스는 'aws_instance.example'의 변경을 감지합니다.
resource "**terraform_data**" "vm_trigger" {
  
  # [triggers_replace]
  # 'aws_instance.example.id' 값이 바뀌면 (즉, VM이 교체되면) 'terraform_data.vm_trigger' 리소스도 교체됩니다.
  **triggers_replace** = [
    aws_instance.example.id
  ]
}

# 3. null_resource (프로비저너 실행기)
# 'terraform_data' 리소스의 변경을 받아 실제 스크립트를 실행합니다.
resource "**null_resource**" "run_setup_script" {
  
  # 'null_resource'의 'triggers' (map{} 형식)
  # 'terraform_data.vm_trigger.id'가 바뀌면 이 'null_resource'도 교체됩니다.
  **triggers** = **{**
    trigger_id = terraform_data.vm_trigger.id
  **}**

  # 리소스가 교체될 때마다 'provisioner'가 다시 실행됩니다.
  provisioner "local-exec" {
    command = "echo 'VM이 ${aws_instance.example.id}로 교체되었습니다. 스크립트를 다시 실행합니다.'"
  }
}

# [output]
# 'terraform_data'의 output은 다른 리소스에서 참조할 수 있습니다.
output "instance_id_from_data_output" {
  # 'input'을 정의하지 않았지만 'output'은 항상 존재합니다.
  # (이 경우 'triggers_replace'의 값을 참조하는 것이 더 명확할 수 있습니다.)
  value = "Triggered by change in instance: ${aws_instance.example.id}"

  # 'output' 속성 자체를 참조할 수도 있습니다.
  # (input이 없으면 'null'을 반환)
  # value = terraform_data.vm_trigger.output 
}
```

| **구분** | **trigger** | **triggers_replace** |
| --- | --- | --- |
| **주 사용처** | `null_resource` (구버전 방식) | `terraform_data` (최신 방식), **`lifecycle`** |
| **형식** | **`map`** `{ key = value }` | **`list`** `[ value1, value2 ]` |
| **동작** | 값 변경 시 리소스 **교체(Replace)** | 값 변경 시 리소스 **교체(Replace)** |

## moved 블록

테라폼의 State에 기록되는 리소스 주소의 **이름**이 변경되면

 기존 리소스는 삭제되고 새로운 리소스가 생성된다.

Terraform 코드에서 리소스의 주소(이름)를 변경할 때, 

기존 인프라를 파괴하지 않고 안전하게 이름만 바꿔주는 **moved**

- Status 파일에 접근권한이 없는 사용자라도 리소스 변경없이 주소 변경 가능해짐

```c
# 1. 리소스 이름을 "web"에서 "app"으로 변경
resource "aws_instance" "app" {
  # ... (기존 "web"의 설정과 동일)
}

# 2. "주소 이전 신고" 블록 추가
moved {
  from = aws_instance.web # 예전 주소
  to   = aws_instance.app # 새 주소
}
```

- **단순 리소스 이름 변경 시**
    - `aws_instance.web` → `aws_instance.app`
- **`count`를 `for_each`로 변경 시**
    - 리소스 주소가 `aws_instance.web[0]`에서 `aws_instance.web["key"]` 같은 형식으로 완전히 바뀌기 때문
- **리소스를 모듈(Module) 안으로 이동시킬 때**
    - 주소가 `aws_instance.web`에서 `module.my_module.aws_instance.web`으로 바뀌기 때문

## 시스템 환경 변수

| **환경 변수** | **설 명** | **사용 예시** |
| --- | --- | --- |
| **`TF_LOG`** | Terraform 실행 시 **로그 레벨**을 설정합니다. (디버깅 시 필수) | `TF_LOG=DEBUG` 
 (사용 가능: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`) |
| **`TF_INPUT`** | 사용자 입력(prompt)을 받을지 여부를 설정합니다.
 CI/CD 파이프라인에서 자동화를 위해 **`false`**로 설정합니다. | `TF_INPUT=false` |
| **`TF_VAR_name`** | 코드 내 `variable "name"` 변수에 **값을 주입**합니다. (가장 많이 사용됨) | `TF_VAR_region="us-east-1"`
 (`variable "region"`에 값이 들어감) |
| **`TF_CLI_ARGS`** | `terraform` 명령어(plan, apply 등) 실행 시 **항상 포함될 인수를 지정**합니다. | `TF_CLI_ARGS="-auto-approve"`
 (모든 `apply`가 자동 승인됨) |
| **`TF_DATA_DIR`** | 프로바이더 플러그인 등이 설치되는 **`.terraform` 디렉터리의 경로를 변경**합니다. | `TF_DATA_DIR=/tmp/my-tf-data` |