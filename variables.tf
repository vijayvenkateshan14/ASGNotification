variable "aws_region" {
  type = string
}

 variable "cust_name" {
   description = "CUSTOMER NAME"
   type        = string
 }

 variable "app" {
  description = "Application name"
  type        = string
}


 variable "environment" {
  description = "environment"
  type        = string
}

 variable "state_bucket" {
  description = "terraform state bucket"
  type        = string
}

 variable "state_key" {
  description = "state file"
  type        = string
}

 variable "state_dynamodb_table" {
  description = "State lock table"
  type        = string
}
