output "repository" {
  value = "${
    map(
      "repository_id", "${aws_codecommit_repository.main.repository_id}",
      "arn", "${aws_codecommit_repository.main.arn}",
      "clone_url_http", "${aws_codecommit_repository.main.clone_url_http}",
      "clone_url_ssh", "${aws_codecommit_repository.main.clone_url_ssh}",
    )
  }"
}
