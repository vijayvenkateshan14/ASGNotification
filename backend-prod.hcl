    bucket         = "ahead-prod-terraform-state"
    key            = "ahead/celfie/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ahead-prod-terraform-locks"
    encrypt        = true

  