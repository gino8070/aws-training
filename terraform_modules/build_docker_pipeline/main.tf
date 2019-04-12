#resource "aws_codepipeline" "main" {
#  name     = "${var.name}"
#  role_arn = "${aws_iam_role.main.arn}"
#}

resource "aws_iam_role" "main" {
  name = "${var.name}_codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "CodePipelineFullAccess" {
  role       = "${aws_iam_role.main.id}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}
