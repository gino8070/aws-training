resource "aws_s3_bucket" "artifact_store" {
  bucket = "${var.name}_fajklduvlzfej1k234j38u1j"
  acl    = "private"
}

# Code Pipeline
resource "aws_codepipeline" "main" {
  name     = "${var.name}_build_docker_pipeline"
  role_arn = "${aws_iam_role.pipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artifact_store.name}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      prividor         = "CodeCommit"
      output_artifacts = ["commited_data"]

      configuration {
        RepositoryName = "${var.repoName}"
        BranchName     = "${var.branchName}"
      }
    }
  }

  stage {
    name = "BuildDockerImage"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["commited_data"]

      configuration {
        ProjectName = "${aws_codebuild_project.build_docker.id}"
      }
    }
  }
}

resource "aws_iam_role" "pipeline" {
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
  role       = "${aws_iam_role.pipeline.id}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

# Code Build
resource "aws_iam_role" "build" {
  name = "${var.name}_codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "CodeBuildAdminAccess" {
  role       = "${aws_iam_role.pipeline.id}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_codebuild_project" "build_docker" {
  name          = "${var.name}_build_docker"
  description   = "${var.name}_build_docker"
  build_timeout = "10"
  service_role  = "${aws_iam_role.build.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    compute_image = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type = "CODEPIPELINE"

    buildspec = <<EOF
version: 0.2
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      - echo docker pull $REPOSITORY_URI:latest
      - docker pull $REPOSITORY_URI:latest || true
  build:
    commands:
      - echo Build started on `date`
      - docker build --cache-from $REPOSITORY_URI:latest -t $REPOSITORY_URI:latest .
      - docker push $REPOSITORY_URI:latest
EOF
  }
}
