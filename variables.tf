variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "aws_region" {
  default = "us-east-2"
}

variable "azure_ssh_pub_key" {
  description = "Public SSH key for Azure VM"
  type        = string
}
