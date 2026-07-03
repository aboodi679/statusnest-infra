# StatusNest Infra

Terraform IaC for the StatusNest multi-tenant service monitoring platform. Provisions the complete AWS infrastructure across modular, reusable components.

**Account:** `026243800492` | **Region:** `us-east-1`

---

## Architecture

```
Internet
    │
    ▼
AWS WAF v2
    │
    ▼
CloudFront (d1wwgn689544k.cloudfront.net)
    ├── /auth/*  ──────────────────────────────────┐
    ├── /api/*   ──────────────────────────────────┤
    │                                              ▼
    │                                    ALB (statusnest-dev-alb)
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
| CloudFront | `d1wwgn689544k.cloudfront.net` (ID: `E1PD475EXURYXL`) |
| ALB | `statusnest-dev-alb-1293848550.us-east-1.elb.amazonaws.com` |
| ECS Cluster | `statusnest-dev-cluster` |
| RDS | `statusnest-dev-db.c2hcyc4yyuxy.us-east-1.rds.amazonaws.com` |
| Redis | `statusnest-dev-redis.b8x2ra.0001.use1.cache.amazonaws.com:6379` |
| S3 Bucket | `statusnest-dev-frontend` |
| GitHub Actions Role | `arn:aws:iam::026243800492:role/statusnest-dev-github-actions-role` |

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

GitHub Actions uses OIDC to assume the GitHub Actions IAM role — no long-lived AWS credentials stored in GitHub secrets.

The role trust policy allows the `aboodi679/statusnest-*` repos to assume it on pushes to `main`.

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
