output "ecr" {
  value = "${
    map(
      "arn", "${aws_ecr_repository.main.arn}",
      "registry_id", "${aws_ecr_repository.main.registry_id}",
      "repository_url", "${aws_ecr_repository.main.repository_url}",
    )
  }"
}
