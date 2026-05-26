# Edge Layer 구성 가이드

## 아키텍처 흐름
```
User
│
▼
Route53 (선택)
│  DNS 조회 → CloudFront 도메인
▼
CloudFront Distribution
│  ├─ WAF Web ACL (AWSManagedRules 3종)
│  ├─ ACM 인증서 (us-east-1, HTTPS 강제)
│  └─ Origin: Prod ALB (Custom Header 포함)
▼
Prod VPC Public Subnet — ALB
│  └─ X-CloudFront-Secret 헤더 검증 (향후 ALB WAF Rule)
▼
EKS (moment-prod-eks-cluster)
├─ RDS (Aurora PostgreSQL)
├─ Redis (ElastiCache)
└─ OpenSearch
```

---

## 주요 리소스

| 리소스 | 위치 | 설명 |
|---|---|---|
| CloudFront Distribution | Global | CDN + HTTPS 진입점 |
| WAF Web ACL | us-east-1 (CLOUDFRONT scope) | 공통 웹 공격 방어 |
| ACM 인증서 | us-east-1 | CloudFront 전용 (커스텀 도메인 시) |
| Route53 Hosted Zone | Global (선택) | DNS 관리 |

---

## 설계 결정 사항

### Route53 Hosted Zone 사용 여부
- 실제 도메인 없을 경우: `edge_domain_name = ""` → CloudFront 기본 도메인(`xxxx.cloudfront.net`) 사용
- 도메인 구입 시: `edge_domain_name = "your-domain.com"`, `create_route53_hosted_zone = true`

### ACM 인증서 (us-east-1)
- CloudFront에 연결되는 ACM 인증서는 **반드시 us-east-1**에 생성해야 함
- `providers = { aws.us_east_1 = aws.us_east_1 }` 로 provider alias 전달

### ALB Origin HTTPS 여부
- 현재: `prod_alb_https_enabled = false` (HTTP 80 → ALB)
- Prod ALB에 ap-northeast-3용 ACM 인증서 연결 후 `true`로 변경
- ap-northeast-3 ALB ACM은 별도 모듈(M2-EDGE-02 등)에서 처리 권장

### CloudFront → ALB 접근 제한 전략
**Custom Secret Header 방식** 사용:
1. CloudFront가 ALB로 요청 시 `X-CloudFront-Secret: <secret>` 헤더 자동 삽입
2. ALB 앞단 WAF Rule에서 해당 헤더 없는 요청 차단 (향후 ALB WAF 구성 시 적용)
3. Secret 값은 `terraform.tfvars`의 `cloudfront_secret_header_value`에서 관리 (sensitive)

### WAF Managed Rule 선택 근거
| Rule | 우선순위 | 목적 |
|---|---|---|
| AWSManagedRulesCommonRuleSet | 10 | SQLi, XSS 등 OWASP Top 10 방어 |
| AWSManagedRulesKnownBadInputsRuleSet | 20 | 알려진 악성 패턴 차단 |
| AWSManagedRulesAmazonIpReputationList | 30 | 봇·DDoS 소스 IP 차단 |

---

## 운영 절차

### Prod ALB 연동 (ALB 구성 완료 후)
```bash
# terraform.tfvars 수정
prod_alb_dns_name      = "<prod-alb-dns-name>.ap-northeast-3.elb.amazonaws.com"
prod_alb_https_enabled = false   # ALB HTTPS 준비되면 true

# 적용
cd terraform/environments/dev
terraform plan
terraform apply
```

### Secret Header 갱신
```bash
# terraform.tfvars에서 값 변경 후 apply
cloudfront_secret_header_value = "new-secret-value-$(date +%Y%m)"
```

### CloudFront 캐시 무효화
```bash
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

---

## outputs 참조

```bash
terraform output cloudfront_domain_name   # 접속 URL
terraform output waf_web_acl_id           # WAF ACL ID
terraform output acm_certificate_arn      # ACM ARN (도메인 있을 때만)
```