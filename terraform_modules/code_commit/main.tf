resource "aws_codecommit_repository" "main" {
  repository_name = "${var.name}"
  description     = "${var.description}"
}
