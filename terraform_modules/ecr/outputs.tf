output "ecr" {
  value = "${
    map(
      "arn", "${aws_ecr_repository.main.arn}",
      "name", "${aws_ecr_repository.main.name}",
      "registry_id", "${aws_ecr_repository.main.registry_id}",
      "registry_url", "${aws_ecr_repository.main.registry_url}",
    )
  }"
}