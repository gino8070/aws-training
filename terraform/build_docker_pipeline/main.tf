provider "aws" {
  region = "ap-northeast-1"
}

module "build_docker_pipeline" {
  source     = "github.com/gino8070/aws-training//terraform_modules/build_docker_pipeline"
  # source     = "../../terraform_modules/build_docker_pipeline"
  name       = "${var.name}"
  repoName   = "${var.repoName}"
  branchName = "${var.branchName}"
}
