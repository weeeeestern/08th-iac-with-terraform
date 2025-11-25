# 주제

- 테라폼 모듈
- 유틸리티 모듈 만들기
- 모듈을 직접 만드는 이유와 만드는 방법

# 요약

- 학습 내용을 간단하게 요약해 주세요.

# 학습 내용

## 모듈 사용

### 모듈의 종류

- 루트 모듈: 테라폼 명령을 실행할 수 있는 작업 디렉터리
- 하위 모듈: 루트 모듈이 호출하는 모듈
- 커스텀 모듈: 사용자가 직접 작성한 다른 루트 모듈
- 공개 모듈: 테라폼 레지스트리에 공개된 모듈

### 기본적인 모듈 호출

- 어떤 모듈을 호출 또는 사용한다는 것의 의미는 모듈에서 정의한 변수의 값을 입력하여 그 값에 따라 조정된 모듈의 리소스를 루트 모듈에 포함하는 것이다.
- `source` 메타인수를 사용하여 어떤 경로에 있는 모듈을 사용할 것인지 지정한다.
- 만약 모듈이 깃허브이 저장소에 존재한다면 `source`을 아래와 같이 변경할 수 있다.

```hcl
module "instances" {
  source = "./ec2-asg"
  # source = "github.com/example-user/terraform-module-ec2-asg"

  minimum_count = 3
  desired_count = 3
  maximum_count = 10
  instance_type = "t3.medium"
}
```

### 공개 모듈

- 테라폼 레지스트리에 발행된 공개 레지스트리를 호출할 수 있다.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "example"
  cidr = "10.0.0.0/16"
}

# 비관적 제약 조건
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"
}
```

### providers 메타인수 사용

- `providers` 메타인수는 테라폼 프로바이더 설정을 하위 모듈로 넘겨주는 역할을 한다.

```hcl
provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

module "example" {
  source = "./example"
  providers = {
    aws.main = aws.seoul
    aws.sub  = aws.tokyo
  }
}
```

## 모듈 작성의 기본 구조

### 엔트리 포인트 정의(main.tf)

- 테라폼 모듈 작성 시에 리소스 생성의 엔트리 포인트로서 `main.tf` 파일을 생성하는 것을 권장한다. `main.tf`로 이름을 짓지 않는다거나 `main.tf`라는 파일이 모듈에 없다고 해서 오류가 발생하지는 않는다.

```hcl
# main.tf
provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "bucket_seoul" {
  provider = aws.seoul
  bucket   = "${var.bucket_prefix}-seoul"
}

resource "aws_s3_bucket" "bucket_tokyo" {
  provider = aws.tokyo
  bucket   = "${var.bucket_prefix}-tokyo"
}
```

### 변수 정의(variables.tf)

- 모듈의 설정값으로 입력할 변수를 `variables.tf` 파일에 모아서 관리하는 것 또한 관습적인 구조다.

```hcl
# variables.tf
variable "bucket_prefix" {
  type        = string
  description = "버킷의 접두사"
}
```

### 출력값 정의(outputs.tf)

- 출력 블록을 `outputs.tf` 파일에 모아놓는 것 또한 모듈 작성의 기본적인 구조다 .

```hcl
# outputs.tf
output "bucket_seoul_id" {
  value       = aws_s3_bucket.bucket_seoul.id
  description = "서울 버킷의 아이디"
}

output "bucket_tokyo_id" {
  value       = aws_s3_bucket.bucket_tokyo.id
  description = "도쿄 버킷의 아이디"
}
```

### 로컬 변수값 정의(locals.tf)

- 모듈 바깥으로 출력되지 않지만 모듈 안 여러 곳에서 재사용할 값들을 로컬 블록을 통해 로컬 변수로 정의한다.

```hcl
# locals.tf
locals {
  bucket_prefix = "terraform-s3"
}

# main.tf
provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "bucket_seoul" {
  provider = aws.seoul
  bucket   = "${local.bucket_prefix}-seoul"
}

resource "aws_s3_bucket" "bucket_tokyo" {
  provider = aws.tokyo
  bucket   = "${local.bucket_prefix}-tokyo"
}
```

### 중첩 모듈

- 모듈 안에 서브 디렉터리로서 모듈을 또 정의하여 사용할 수 있다.
- 중첩 모듈은 많은 종류의 리소스를 반복적으로 만들어야 할 때 빛을 반한다.
- 중첩 모듈은 테라폼의 공식 컨벤션상 `/modules` 서브 디렉터리에 두는 것이 일반적이다.

## 유틸리티 모듈 만들기

- 인프라 리소스가 반환값이나 사이드 이펙트의 대상이 아닌 모듈을 유틸리티 모듈이라고 한다.
- 유틸리티 모듈을 활용하면, 반복되는 패턴과 공통 기능의 중복을 최소화할 수 있다.

### AWS의 메타데이터 가져오기

```hcl
# /get_aws_metadata/main.tf

# 데이터 블록 정의
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_account_alias" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# 출력값
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "account_alias" {
  value = data.aws_iam_account_alias.current.account_alias
}

output "region_name" {
  value = data.aws_region.current.name
}

output "region_code" {
  value = split("-", data.aws_availability_zones.available.zone_ids[0])[0]
}

output "az_names" {
  value = data.aws_availability_zones.available.names
}
```

```hcl
# 모듈 호출 후 사용
module "current" {
  source = "../modules/utils/get_aws_metadata"
}

locals {
  account_id    = module.current.account_id
  account_alias = module.current.account_alias
  region        = module.current.region_name
  region_code   = module.current.region_code
  az_names      = module.current.az_names
}
```

### 두 AWS 프로바이더가 동일한지 체크하기

```hcl
# /check_aws_cross_provider/main.tf

# 프로바이더 a
data "aws_caller_identity" "a" {
  provider = aws.a
}
data "aws_region" "a" {
  provider = aws.a
}

# 프로바이더 b
data "aws_caller_identity" "b" {
  provider = aws.b
}
data "aws_region" "b" {
  provider = aws.b
}

locals {
  a_account_id = data.aws_caller_identity.a.account_id
  b_account_id = data.aws_caller_identity.b.account_id

  a_region = data.aws_region.a.name
  b_region = data.aws_region.b.name
}

# 출력값
output "is_cross_account" {
  value = local.a_account_id != local.b_account_id
}

output "is_cross_region" {
  value = local.a_region != local.b_region
}

# 추가 출력값
output "a_account_id" {
  value = local.a_account_id
}

output "b_account_id" {
  value = local.b_account_id
}

output "a_region" {
  value = local.a_region
}

output "b_region" {
  value = local.b_region
}

```

```hcl
# 모듈 호출 후 사용
module "check_cross" {
  source = "../modules/utils/check_aws_cross_provider"
  providers = {
    aws.a = aws.requester
    aws.b = aws.accepter
  }
}


locals {
  is_cross_account = module.check_cross.is_cross_account
  is_cross_region  = module.check_cross.is_cross_region

  need_accepter = local.is_cross_account || local.is_cross_region
}


# VPC Peering 생성
resource "aws_vpc_peering_connection" "this" {
  peer_owner_id = local.is_cross_account ? local.accepter_account : null  # 교차 계정이면, 상대 계정
  peer_region   = local.is_cross_region ? local.accepter_region : null  # 교차 리전이면, 상대 리전

  auto_accept = local.need_accepter ? false : true  # 교차 계정 또는 교차 리전이면, 자동 승인 불가

  dynamic "requester" {
    for_each = local.need_accepter ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }

  dynamic "accepter" {
    for_each = local.need_accepter ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }
  # ...
}
```

### 리스트 내의 맵 합치기

```hcl
# merge_map_in_list/main.tf

# 변환할 리스트 또는 맵 입력으로 받기
variable "input" {
  description = "list(map()) or map(map())"
}

# 변환 진행
locals {
  keys   = flatten([for item in var.input : keys(item)])
  values = flatten([for item in var.input : values(item)])

  output = zipmap(local.keys, local.values)
}

# 변환된 맵을 출력
output "output" {
  value = local.output
}
```

```hcl
locals {
  vpc_list = [
    {
      vpc1 = "1234"
      vpc2 = "5678"
    },
    {
      vpc3 = "9876"
    },
  ]
}

module "merge_vpc_list" {
  source = "../modules/utils/merge_map_in_list"
  input  = local.vpc_list
}

locals {
  merged_vpc_list = module.merge_vpc_list.output
}
```

## 공개 모듈 vs 직접 만든 모듈

- 공개 모듈을 사용하는 방식의 제일 큰 장점은 시간과 인력 등 초기 비용 투자의 필요성이 절대적으로 줄어든다는 점이다.
- 그러나 만약 조금이라도 여유가 있다면 직접 모듈을 만드는 것을 권장한다.

### 공개 모듈의 한계

1. 범용적인 사례를 포괄할 수 있도록 만들어야 하기 때문에 모듈 내부가 상당히 복잡한 편이다.
2. 공개 모듈 오픈소스 프로젝트들이 잘 관리되고 있다고 말하기는 조금 어렵다.

### 맞춤형 설계 및 유지 관리 용이성

- 직접 만든 모듈은 사내 보안 정책, 네트워크 설계, 태그 정책 등 조직의 요구사항을 100% 반영할 수 있다.
- 공개 모듈의 경우 업데이트를 기다려야 하고, 업데이트가 되지 않으면 직접 그 모듈을 해석하고 개선해서 사용해야 한다.

### 재사용성 및 표준화

- 직접 설계한 모듈은 일관된 패턴과 표준을 적용하여 재사용할 수 있다.

## 모듈을 쉽게 만드는 방법

### 1. 요구사항 정리 및 입력값 정하기

- 테라폼은 그저 도구일 뿐이고 정말 중요한 것은 테라폼으로 만들고 관리하는 리소스이다.
- 이 리소스를 어떻게 만들고 관리할 것인지에 대한 요구사항은 반드시 정리해야 하며, 운영 시 어떤 입력값을 사용해서 리소스의 상태를 변경하거나 생성할 수 있는지도 결정해야 한다.

### 2. 입력값을 모듈에 전달할 방법 정하기

- 해당 파일을 어떤 방식으로 모듈에 전달할 것인지를 고민해야 한다.

### 3. 모듈 만들기

1. 변수 임시 설정
2. 모듈 속 공통 태그 설정
3. 실제 리소스 블록 선언

### 4. 유효성 검사

1. 변수 타입 유효성
2. 입력갑 유효성

### 5. 모듈 출력 설정

- 레디스 캐시의 아이디나 DNS 주소 등을 모듈 밖에서 참조하기 위해서는 출력 블록을 선언해야 한다.
- 웬만하면, 생성된 아이디 정도는 출력값으로 설정해 두는 게 미래에 편할 것이다.

# 추가

## VPC 피어링

VPC 피어링 연결은 프라이빗 IPv4 주소 또는 IPv6 주소를 사용하여 두 VPC 간에 트래픽을 라우팅할 수 있도록 하기 위한 두 VPC 사이의 네트워킹 연결입니다.

서로 다른 AWS 리전에 위치한 VPC 사이에 피어링 관계를 설정하는 경우 상이한 AWS 리전의 VPC에 있는 리소스에서 게이트웨이, VPN 연결 또는 네트워크 어플라이언스를 사용하지 않고 프라이빗 IP 주소를 사용하여 서로 통신할 수 있습니다. 트래픽은 프라이빗 IP 주소 공간 안에서 유지됩니다. 모든 리전 간 트래픽은 암호화되며 단일 장애 지점 또는 대역폭 제한이 없습니다. 트래픽은 항상 글로벌 AWS 백본에서만 유지되고 절대로 퍼블릭 인터넷을 통과하지 않으므로 일반적인 취약점 공격과 DDoS 공격 같은 위협이 감소합니다. 리전 간 VPC 피어링은 리전 간에 리소스를 공유하거나 지리적 중복성을 위해 데이터를 복제할 수 있는 간단하고 비용 효율적인 방법을 제공합니다.

![VPC 피어링](https://devio2023-media.developers.io/wp-content/uploads/2022/10/27a0e10cfc6a82093658c92de3cd87db-1536x915.png)

- VPC의 CIDR이 일치하거나 겹치는 경우 피어링 연결을 할 수 없습니다.
- 전이적인 연결을 할 수 없습니다. (A - B, B - C | A - C 불가능)

### VPC 피어링 연결 생성

1. 피어링 연결 생성 선택
2. 정보 입력 및 생성

   > 이름  
   > 요청자 VPC ID  
   > 수락자 계정, 리전, VPC ID

3. 피어링 연결 수락(수락자)
4. 라우팅 테이블 수정(요청자, 수락자)

## 테라폼 디버깅하기

### 오류 메시지에 주의 기울이기

- 테라폼 오류 메시지는 어떤 리소스에서 문제가 발생했는지, 코드의 라인 넘버는 어디인지, 어떤 모듈에서 발생한 것인지 충분히 알려주도록 설계되어 있다.
- `check` 블록이나 `precondition` 블록 등을 포함한 유효성 검사를 수행해 오류가 일어난 지점을 더 정확하게 포착할 수 있다.

### 구성 파일 검증: validate와 fmt

- `terraform validate` 명령을 사용해서 문법 검증 수행과 코드로 추론할 수 있는 모든 유효성 검사를 수행할 수 있다.
- `terraform fmt` 명령을 사용해서 테라폼 언어 스타일 규칙에 맞게 자동으로 코드를 포맷팅할 수 있다.
- 만약 명령을 실행한 디렉터리의 모든 하위 경로의 구성 파일에 포맷팅을 적용하고자 한다면 `terraform fmt -recursive` 옵션을 사용한다.

### 테라폼 콘손을 사용한 디버깅: console

- `terraform console` 명령을 사용하여 상호작용 가능한 셸 안에서 각종 함수, 표현식의 값을 확인해 볼 수 있다.

### 외부적 요인 파악

- 상태 충돌이 있는가?  
  상태 충돌의 중요한 원인으로는 테라폼 바깥에서 일어난 수정 사항이 테라폼 코드에 반영되지 않는 리소스 드리프트가 있다.  
  `terraform state list` 명령어를 사용하여 원하는 리소스가 모두 테라폼 상태로 import 되었는지 확인한다.
- 프로바이더와 공개 모듈의 버전이 잘못 설정되어 있는가?  
  내가 작성한 코드가 현재 사용하고 있는 프로바이더나 공개 모듈의 버전에서 지원하는 것인지를 테라폼 레지스트리 등 공식 문서를 참조해 체크해야 한다.
- 외부 라이브러리에 의한 문제가 있는가?(API 사용량 제한, 인증, 권한 등)  
  각 서드파티 서비스에서 API 키의 존재와 권한 부여 여부를 확인하고, API 키를 정확하게 설정했는지 확인해 보아야 한다.
