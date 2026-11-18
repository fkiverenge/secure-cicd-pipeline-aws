variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Name prefix for all resources. The workflow file uses the same names."
  type        = string
  default     = "secure-cicd"
}

variable "github_repo" {
  description = "GitHub repository allowed to deploy, in the form owner/repo"
  type        = string
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set to false if your AWS account already has one."
  type        = bool
  default     = true
}
