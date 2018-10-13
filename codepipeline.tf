resource "aws_codepipeline" "ci" {
  name     = "pr-template"
  role_arn = "${aws_iam_role.ci.arn}"

  artifact_store {
    location = "${aws_s3_bucket.ci.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["test"]

      configuration {
        Owner      = "nicolai86"
        Repo       = "traq"
        Branch     = "master"
        OAuthToken = "${var.github_oauth_token}"
      }
    }
  }

  stage {
    name = "Test"

    action {
      name            = "Go"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["test"]
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.unit-tests.name}"
      }
    }
  }
}
