terraform {
  backend "s3" {
    bucket         = "statusnest-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "statusnest-terraform-locks"
  }
}