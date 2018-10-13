
#
# AWS Lamda
#

resource "aws_lambda_function" "pr-handler" {
    filename = "handler.zip"
    function_name = "pr-handler"
    role = "${aws_iam_role.cp-manager.arn}"
    handler = "handler.Handle"
    source_code_hash = "${base64sha256(file("handler.zip"))}"
    memory_size = 256
    timeout = 300
    runtime = "python2.7"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.pr-handler.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.gh.id}/*/POST/"
}
