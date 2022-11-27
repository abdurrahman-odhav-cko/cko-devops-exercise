# Admin
variable "role_arn" {
  description = "AWS IAM Role Arn for KMS Key Administration"
}
# Website
variable "website_name" {
  description = "Website Name"
}

# DNS
variable "hosted_zone_name" {
  description = "Name of the AWS Route53 Hosted Zone"
  type = string
}

variable "domain_name" {
  description = "Fully Qualified Domain Name for the website"
  type = string
}

variable "zone_id" {
  description = "Route53 Zone ID"
  type = string
}

variable "sans" {
  description = "List of Subject Alternative Names that require HTTPS"
  type = list(string)
  default = []
}

variable "email_address" {
  description = "Email address for alerting"
}