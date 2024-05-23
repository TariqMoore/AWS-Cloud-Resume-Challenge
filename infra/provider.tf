terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}
/*Set the required provider AWS above and then specified the region for it below*/
provider "aws" {
    region = "us-east-1"
  
}