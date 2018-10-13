provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "ci" {
  bucket = "awesome-codepipeline-ci-bucket"
  acl    = "private"
}


resource "aws_codebuild_project" "unit-tests" {
  name          = "unit-tests"
  description   = "Run unit tests"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "golang:1.8"
    type         = "LINUX_CONTAINER"
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/nicolai86/traq.git"

    buildspec = <<EOF
version: 0.1

phases:
  install:
    commands:
      - go get github.com/nicolai86/traq

  build:
    commands:
      - go test ./...
EOF
  }
}
