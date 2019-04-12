provider "aws" {
  region = "ap-northeast-1"
}

module "code_commit" {
  source      = "github.com/gino8070/aws-training//terraform_modules/code_commit"
  name        = ""
  description = "aws-training"
}
