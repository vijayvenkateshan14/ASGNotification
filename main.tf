resource "aws_vpc" "enovis_vpc" {
  cidr_block       = "10.81.0.0/16"
  tags = {
    Name = "enovis-vpc"
    Application = var.app
  }
}