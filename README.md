# StatusNest Infra

Terraform IaC for the StatusNest multi-tenant service monitoring platform. Provisions the complete AWS infrastructure across modular, reusable components.

**Account:** `<AWS_ACCOUNT_ID>` | **Region:** `us-east-1`

---

<!-- Images removed/replaced for privacy. If these are non-sensitive diagrams, consider re-adding sanitized versions. -->
<!-- Example: ![architecture diagram](docs/architecture.png) -->

## Architecture

```
Internet
    │
    ▼
AWS WAF v2
    │
    ▼
CloudFront (<CLOUDFRONT_DOMAIN>)
    ├── /auth/*  ──────────────────────────────────┐
    ├── /api/*   ──────────────────────────────────┤
    │                                              ▼
    │                                    ALB (<ALB_HOSTNAME>)
    │                                              │
    │                              ┌───────────────┼───────────────┐
    │                              ▼               ▼               ▼
    │                         auth:8000      monitor:8001    status:8002
    │                         ECS Fargate    ECS Fargate     ECS Fargate
    │                              │               │               │
    └── default → S3 ─────────┐   └───────────────┴───────────────┘
                               ▼               │
                         React SPA         RDS PostgreSQL
                                            ElastiCache Redis
```

---

## Modules

| Module | Resources |
|---|---|
| `vpc` | VPC, public/private subnets, IGW, NAT Gateway, route tables |
| `rds` | RDS PostgreSQL, subnet group, security group |
| `elasticache` | Redis cluster, subnet group, security group |
| `ecr` | ECR repositories for auth, monitor, status images |
| `ecs` | ECS cluster, Fargate task definitions, services, IAM roles |
| `alb` | Application Load Balancer, target groups, listener rules |
| `frontend` | S3 bucket, CloudFront distribution, OAC, bucket policy |
| `waf` | WAF v2 Web ACL (CloudFront-scoped, `us-east-1`) |
| `waf-alb` | WAF v2 Web ACL (ALB-scoped, regional) |
| `monitoring` | CloudWatch dashboards, alarms |

---

## Key Infrastructure

| Resource | Value |
|---|---|
| CloudFront | `<CLOUDFRONT_DOMAIN>` (ID: `<CLOUDFRONT_ID>`) |
| ALB | `<ALB_HOSTNAME>` |
| ECS Cluster | `statusnest-dev-cluster` |
| RDS | `<RDS_ENDPOINT>` |
| Redis | `<REDIS_ENDPOINT>` |
| S3 Bucket | `<S3_BUCKET>` |
| GitHub Actions Role | `<GITHUB_ACTIONS_ROLE_ARN>` |

---

## Usage

```bash
cd statusnest-infra

# Init
terraform init

# Plan
terraform plan -var="environment=dev"

# Apply
terraform apply -var="environment=dev"
```

### Variables

| Variable | Description |
|---|---|
| `environment` | Deployment environment (`dev`, `prod`) |

---

## CI/CD Integration

GitHub Actions uses OIDC to assume a short-lived IAM role — no long-lived AWS credentials stored in GitHub secrets.

The role trust policy allows your automation/builder repositories to assume it; ensure the trust policy is scoped to the minimum required repositories and branches and uses precise OIDC subjects.

---

## Notes

- Route 53 / custom domain intentionally omitted (CloudFront default certificate used)
- RDS uses PostgreSQL instead of Aurora (account-level restrictions)
- Monitor and status ECS task definitions were created via CLI and are not yet fully managed by Terraform (auth task definition is Terraform-managed)

---

## Related Repos

| Repo | Description |
|---|---|
| [statusnest-api](https://github.com/aboodi679/statusnest-api) | FastAPI microservices (auth, monitor, status) |
| [statusnest-worker](https://github.com/aboodi679/statusnest-worker) | Lambda monitor + SQS processor |
| [statusnest-frontend](https://github.com/aboodi679/statusnest-frontend) | React SPA |
