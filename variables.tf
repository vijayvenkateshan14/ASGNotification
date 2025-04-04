variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
  default = null
}

 variable "cust_name" {
   description = "CUSTOMER NAME"
   type        = string
 }

 variable "report_regions" {
   description = "AWS REPORTING REGIONS"
   type        = string
 }

 variable "master_account_number" {
  description = "Master AWS Account Number"
  type        = string
}


 variable "sns_topic_arn" {
  description = "SNS Topic ARN"
  type        = string
}