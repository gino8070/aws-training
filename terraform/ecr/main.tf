provider "aws" {
  region = "ap-northeast-1"
}

module "ecr" {
  source      = "github.com/gino8070/aws-training//terraform_modules/ecr"
  name        = ""
}
