# GitHub's OIDC thumbprint is well-known and stable; AWS also validates
# the token signature independently, so this isn't a secret.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Environment = var.environment
  }
}

# Trust policy: only workflows running on these exact repos, on any branch/ref,
# can assume this role. Narrow to specific branches later if you want stricter control.
data "aws_iam_policy_document" "github_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        for repo in var.github_repos :
        "repo:${var.github_org}/${repo}:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "statusnest-${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  tags = {
    Environment = var.environment
  }
}

# Minimum permissions to build/push images and deploy to ECS.
# Narrow further once Day 6/7 reveal exactly which actions CI actually needs.
resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "statusnest-${var.environment}-github-actions-deploy-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = "*" # this specific action requires "*"; it's a global auth endpoint, not a per-repo grant
      },
      {
        Sid    = "S3Frontend"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::statusnest-${var.environment}-frontend",
          "arn:aws:s3:::statusnest-${var.environment}-frontend/*",
        ]
      },
      {
        Sid    = "CloudFrontInvalidate"
        Effect = "Allow"
        Action = ["cloudfront:CreateInvalidation"]
        Resource = "arn:aws:cloudfront::026243800492:distribution/E1PD475EXURYXL"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
        ]
        Resource = "arn:aws:ecr:us-east-1:026243800492:repository/statusnest-*"
      },
      {
        Sid    = "ECSDeploy"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
        ]
        Resource = "*" # ECS task def registration doesn't support resource-level ARNs cleanly; scope by tags later if needed
      },
      {
        Sid      = "PassExecutionRoles"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = [
          "arn:aws:iam::026243800492:role/statusnest-${var.environment}-ecs-execution-role",
          "arn:aws:iam::026243800492:role/statusnest-${var.environment}-ecs-task-role",
        ]
      }
    ]
  })
}