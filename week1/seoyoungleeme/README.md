# IaC(Infrastructure as Code)와 자동화

---

# 요약

* 인프라 자동화의 핵심은 **프로세스 기반 접근**과 **코드형 인프라(IaC)**이다.
* 기존의 절차적 자동화는 환경마다 다르게 동작했지만, IaC는 인프라의 **최종 상태를 코드로 정의**하여 일관성과 재현성을 확보한다.
* 대표 도구인 **Terraform**은 멀티클라우드 환경에서 인프라를 선언적으로 관리하며, **Ansible**과 결합해 프로비저닝부터 설정까지 완전 자동화를 구현할 수 있다.

---

# 학습 내용

## 프로세스로서의 자동화

* 자동화는 **프로세스 간 통합과 재활용성 향상**을 중점으로 한다.
* 과거에는 기술 주도형 접근으로, 수동 단계가 많고 특정 환경에 종속된 파편화된 자동화가 주를 이뤘다.
* 그러나 클라우드처럼 **동적인 인프라와 이기종 플랫폼**을 다루기 위해서는 코드 기반의 **프로세스적 접근**이 필요하다.
* 코드로 자동화를 정의하면, 반복적인 변경과 배포를 효율화하고 언제든 재구성 및 개선이 용이하다.

---

## IaC (Infrastructure as Code)

* 인프라를 코드로 정의해 관리하는 방식으로, 수동 설정 없이 코드 기반으로 서버·네트워크·스토리지를 자동 프로비저닝한다.
* “원하는 상태(desired state)”만 정의하면 IaC 도구가 자동으로 구축하고 유지한다.

### 장점

* **환경 복제 용이:** 동일 코드를 다른 리전에 실행하면 완전히 동일한 인프라 복제 가능
* **오류 감소:** 휴먼 에러 최소화, Git 기반 버전 관리 및 롤백 가능
* **일관성 확보:** 코드로 기록되어 추적 및 문서화가 용이

### 접근 방식

| 방식               | 설명                         | 예시                         |
| ---------------- | -------------------------- | -------------------------- |
| 선언적(Declarative) | 최종 상태를 정의, 도구가 자동으로 상태를 맞춤 | Terraform, Kubernetes YAML |
| 명령형(Imperative)  | 수행 순서를 명시, 단계별 실행          | Ansible, Bash Script       |

---

## DevOps와 IaC의 결합

* DevOps는 개발과 운영 간 협업을 강화해 **릴리즈 주기 단축**과 **지속적 배포(CI/CD)**를 실현한다.
* IaC는 DevOps의 자동화 핵심 구성 요소로,

  * 개발부터 운영까지 **일관된 환경 구성**,
  * **자동 배포 및 환경 재현성 보장**,
  * **확장성 높은 리소스 관리**를 가능하게 한다.

---

## Terraform

* HashiCorp의 오픈소스 IaC 도구로, HCL(HashiCorp Configuration Language)을 사용해 인프라의 **최종 상태를 선언적으로 정의**한다.
* 테라폼은 클라우드 API를 통해 실제 리소스를 생성·변경·삭제하며, 모든 상태를 **tfstate 파일**로 관리한다.

### 주요 명령어

| 명령어                  | 설명                       |
| -------------------- | ------------------------ |
| `terraform init`     | Provider 초기화 및 라이브러리 설치  |
| `terraform validate` | 코드 유효성 검사                |
| `terraform plan`     | 변경 사항 시뮬레이션              |
| `terraform apply`    | 인프라 실제 배포                |
| `terraform destroy`  | 리소스 삭제                   |
| `terraform import`   | 기존 리소스를 Terraform 관리로 전환 |

### 장점

* 멀티클라우드/하이브리드 환경 동시 관리
* 선언적 구성으로 변경 추적 및 자동 적용
* 모듈화된 인프라 코드 재사용성 높음
* 광범위한 Provider 및 커뮤니티 생태계 지원

### 단점

* tfstate 관리 부담 (협업 시 Lock 필요)
* 일부 리소스 변경 시 파괴적 반영 가능
* OS/앱 구성은 별도 도구(Ansible 등) 필요

---

## Terraform vs CloudFormation vs Ansible

| 항목        | Terraform      | CloudFormation | Ansible   |
| --------- | -------------- | -------------- | --------- |
| 멀티클라우드 지원 | O              | X (AWS 전용)     | O         |
| 상태 관리     | tfstate 명시적 관리 | 내부 Stack 관리    | Stateless |
| 구성 방식     | 선언형            | 선언형            | 절차형       |
| 주요 역할     | 인프라 프로비저닝      | AWS 인프라 관리     | 설정/배포 자동화 |
| 벤더 종속     | 없음             | 있음             | 없음        |

---

## Terraform과 Ansible의 연동

* **Terraform:** 서버, 네트워크, 스토리지 등 인프라 생성
* **Ansible:** 해당 서버 내부 설정 자동화 (패키지 설치, 서비스 설정 등)

### 실행 시나리오

1. Terraform으로 EC2 생성
2. Ansible이 SSH 접속하여 Nginx, Node.js 등 설정 배포
3. Terraform output을 Ansible inventory로 연동

```bash
terraform apply
terraform output -json > inventory.json
ansible-playbook -i inventory.json playbook.yml
```

또는 Terraform provisioner로 Ansible 직접 실행:

```hcl
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.web.public_ip},' playbook.yml"
  }
}
```

---

# 추가

* IaC는 단순한 자동화 스크립트가 아닌 **인프라 설계도(Architecture Blueprint)** 역할을 한다.
* Kubernetes YAML은 부분적 IaC로 볼 수 있으며, Terraform은 클러스터 외부 리소스(VPC, IAM, LB 등)까지 통합 관리할 수 있다.
* 실무에서는 **Terraform + Ansible 조합**으로 프로비저닝부터 구성까지 완전 자동화된 DevOps 파이프라인을 구축한다.
