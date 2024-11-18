variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
}

variable "subnet_public_cidr_block" {
  type        = string
  description = "Public subnet CIDR"
}


variable "subnet_private_cidr_block" {
  type        = string
  description = "Private subnet CIDR"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}