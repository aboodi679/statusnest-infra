variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "github_org" {
  description = "GitHub org/username that owns the repos"
  type        = string
  default     = "aboodi679"
}

variable "github_repos" {
  description = "List of repo names trusted to assume the deploy role"
  type        = list(string)
  default     = ["statusnest-infra", "statusnest-api", "statusnest-worker", "statusnest-frontend"]
}