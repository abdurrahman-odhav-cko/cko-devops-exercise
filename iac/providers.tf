terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "aodhav-cko-devops-exercise-backend"
    key    = "state"
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Owner       = "abdurrahman-odhav"
      Terraform   = "True"
      Environment = "Test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Owner       = "abdurrahman-odhav"
      Terraform   = true
      Environment = "demo"
    }
  }
}