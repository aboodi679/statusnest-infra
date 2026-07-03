# StatusNest Infrastructure

> Terraform IaC for the StatusNest AWS infrastructure

All AWS resources for StatusNest defined as code using Terraform — fully reproducible, version-controlled, and modular.

---

## AWS Resources

| Service | Purpose |
|---------|---------|
| VPC | Private subnets for ECS, RDS, Redis |
| ECS Fargate | Runs 3 microservice containers |
| ALB | Path-based routing to each service |
| RDS PostgreSQL | Persistent storage — tenants, services, incidents |
| ElastiCache Redis | Current status cache (sub-ms reads) |
| Lambda | Monitor worker + SQS processor |
| EventBridge | Triggers Lambda every 60 seconds |
| SQS + DLQ | Decouples monitor results from processor |
| SNS | Alert fan-out |
| ECR | Docker image registry (3 repos) |
| Secrets Manager | DB credentials, JWT secret |
| CloudWatch | Dashboards, alarms, log groups |
| IAM | Least-privilege roles per service, OIDC for CI/CD |
| S3 | Terraform remote state + frontend hosting |
| DynamoDB | Terraform state locking |

---

## Module Structure

```
statusnest-infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
└── modules/
    ├── vpc/
    ├── ecs/
    ├── aurora/          # RDS PostgreSQL
    ├── elasticache/     # Redis
    ├── alb/
    ├── lambda/
    ├── sqs/
    ├── sns/
    ├── notifications/   # SNS topic
    ├── secrets/
    └── monitoring/      # CloudWatch dashboards + alarms
```

---

## CloudWatch Alarms

| Alarm | Threshold |
|-------|-----------|
| ECS CPU High | > 80% |
| ECS Memory High | > 80% |
| RDS CPU High | > 80% |
| RDS Connections High | > 50 |
| Redis CPU High | > 80% |
| Redis Memory Low | < 10% freeable |
| ALB 5XX High | > 10 errors |
| Target 5XX High | > 10 errors |
| Unhealthy Hosts | >= 1 |

---

## Remote State

```hcl
terraform {
  backend "s3" {
    bucket         = "statusnest-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "statusnest-terraform-locks"
  }
}
```

---

## Usage

```bash
git clone https://github.com/aboodi679/statusnest-infra
cd statusnest-infra
terraform init
terraform plan
terraform apply
```

---

## Related Repos

| Repo | Description |
|------|-------------|
| [statusnest-api](https://github.com/aboodi679/statusnest-api) | FastAPI backend — 3 microservices |
| [statusnest-worker](https://github.com/aboodi679/statusnest-worker) | Lambda monitor + processor |
| [statusnest-frontend](https://github.com/aboodi679/statusnest-frontend) | React dashboard |

---

*Built by [Muhammad Abdullah](https://github.com/aboodi679) · Powered by AWS*
