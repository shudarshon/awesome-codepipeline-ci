resource "aws_api_gateway_rest_api" "gh" {
  name        = "github"
  description = "api to handle github webhooks"
}

resource "aws_api_gateway_method" "webhooks" {
  rest_api_id = "${aws_api_gateway_rest_api.gh.id}"
  resource_id   = "${aws_api_gateway_rest_api.gh.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.X-GitHub-Event" = true
    "method.request.header.X-GitHub-Delivery" = true
  }
}

resource "aws_api_gateway_integration" "webhooks" {
  rest_api_id             = "${aws_api_gateway_rest_api.gh.id}"
  resource_id             = "${aws_api_gateway_rest_api.gh.root_resource_id}"
  http_method             = "${aws_api_gateway_method.webhooks.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.pr-handler.arn}/invocations"
  request_parameters = {
    "integration.request.header.X-GitHub-Event" = "method.request.header.X-GitHub-Event"
  }
  request_templates = {
    "application/json" = <<EOF
{
  "body" : $input.json('$'),
  "header" : {
    "X-GitHub-Event": "$input.params('X-GitHub-Event')",
    "X-GitHub-Delivery": "$input.params('X-GitHub-Delivery')"
  }
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "webhook" {
  rest_api_id = "${aws_api_gateway_rest_api.gh.id}"
  resource_id = "${aws_api_gateway_rest_api.gh.root_resource_id}"
  http_method = "${aws_api_gateway_integration.webhooks.http_method}"
  status_code = "200"

  response_templates {
    "application/json" = "$input.path('$')"
  }

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  selection_pattern = ".*"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.gh.id}"
  resource_id = "${aws_api_gateway_rest_api.gh.root_resource_id}"
  http_method = "${aws_api_gateway_method.webhooks.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_deployment" "gh" {
  depends_on = ["aws_api_gateway_method.webhooks"]

  rest_api_id = "${aws_api_gateway_rest_api.gh.id}"
  stage_name  = "test"
}
