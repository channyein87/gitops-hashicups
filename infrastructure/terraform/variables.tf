variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnets ids"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet ids"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "route53_domains" {
  description = "List of Route 53 domains for External DNS"
  type        = string
}

variable "eks_cluster_domain" {
  description = "Route 53 domain for EKS"
  type        = string
}

variable "github_owner" {
  type        = string
  description = "GitHub owner"
}

variable "github_token" {
  type        = string
  description = "GitHub token"
}

variable "repository_name" {
  type        = string
  description = "GitHub repository name"
}

variable "repository_visibility" {
  type        = string
  default     = "public"
  description = "Visibility of the GitHub repository"
}

variable "repository_branch" {
  type        = string
  default     = "main"
  description = "Branch name"
}

variable "repository_flux_path" {
  type        = string
  description = "Path to flux kustomization"
}
