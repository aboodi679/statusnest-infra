variable "environment" {
  type = string
}
variable "waf_web_acl_arn" {
  type    = string
  default = null
}
variable "alb_dns_name" { type = string }
