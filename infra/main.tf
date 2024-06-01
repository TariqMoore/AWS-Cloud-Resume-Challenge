/*Below is the creation of the DynamoDB Table*/
resource "aws_dynamodb_table" "resume_site_table" {
    name            =   "resume_site_table" #(Required), this needs to be unique within the region. This is the physical name of the table.
    billing_mode    =   "PAY_PER_REQUEST" #(Optional) Billing_Mode controls how you are charged. Default is PROVISIONED
    hash_key        =   "VisitCounter" #(Required) Hash_key is the primary key of the table.
    table_class     =   "STANDARD" 
    
    attribute {
      name          =   "VisitCounter" #Name of the attribute
      type          =   "N" #Attribute types. This can be S (string), N (number), or B (Binary)
    }
    tags = {
        Name        =   "ResumeSite" #Attached Billing Tag for monitoring
    }
}
resource "aws_lambda_function" "visitFunction" {
  filename          = data.archive_file.zip_the_python_code.output_path
  source_code_hash  = data.archive_file.zip_the_python_code.output_base64sha256
  function_name     = "visitFunction"
  role              = aws_iam_role.lambda_role.arn
  handler           = "visitFunction.event_handler"
  runtime           = "python3.8"
}
/*Creating the AWS Lambda resource with an IAM role
This IAM role is giving Lambda access to the AWS console. Enabling it to interact with services*/
resource "aws_iam_role" "lambda_role" {
  name               =  "lambda_execution_role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "iam_policy_for_resume_site" {
  name                   =  "aws_iam_policy_for_terraform_resume_site_policy"
  path                   =  "/"
  description            =  "AWS IAM policy for managing the resume site role"
    policy = jsonencode(
      {
        "Version": "2012-10-17",
        "Statement" : [
          {
            /*Creating a log group/stream to keep track of events*/
            "Action" : [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource" : "arn:aws:logs:*:*:*",
            "Effect": "Allow"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "dynamodb:UpdateItem",
              "dynamodb:GetItem"
            ],
            "Resource" : "arn:aws:dynamodb:*:*:table/resume_site_table"
          },
        ]
      }
    ) 
}

/*Attaching policy to role*/
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role                    = aws_iam_role.lambda_role.name
  policy_arn              = aws_iam_policy.iam_policy_for_resume_site.arn
}

/*data resorce putting the function in a zip file for Lambda*/
data "archive_file" "zip_the_python_code" {
  type                    = "zip"
  source_file             = "${path.module}/lambda/visitFunction.py"
  output_path             = "${path.module}/lambda/visitFunction.zip"
}

/*Creating API Gateway as REST API*/
resource "aws_api_gateway_rest_api" "Resume_Site_Api" {
  name                    = "Resume_Site_API"
  description             = "API triggers from website access" 
  
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}
/*Defining API Gateway Access to invoke lambda function*/
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitFunction.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn    = "${aws_api_gateway_rest_api.Resume_Site_Api.execution_arn}/*/*"
  
}
output "base_url" {
  value = aws_api_gateway_deployment.resume_site.invoke_url
}
/*Defining Proxy resource*/
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id =  aws_api_gateway_rest_api.Resume_Site_Api.id
  parent_id   = aws_api_gateway_rest_api.Resume_Site_Api.root_resource_id
  path_part   = "{proxy+}" //Special path_part value that activates proxy behavior. Means this resource will match any request path
  
}
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.Resume_Site_Api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id = aws_api_gateway_rest_api.Resume_Site_Api.id
  resource_id = aws_api_gateway_rest_api.Resume_Site_Api.root_resource_id
  http_method = "ANY"
  authorization = "NONE"
}


/*Creating an integration that specifies where incoming reqeusts are routed to.*/
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.Resume_Site_Api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY" //AWS_PROXY is an integration type that tells API gateway to call into the api of another aws service, Lambda, to invoke the function
  uri                     = aws_lambda_function.visitFunction.invoke_arn 
  
}
/*Proxy resource annot match an empty path at the root of the API.
Adding similar configuration to the root resource built into the REST API object*/
resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.Resume_Site_Api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY" //AWS_PROXY is an integration type that tells API gateway to call into the api of another aws service, Lambda, to invoke the function
  uri                     = aws_lambda_function.visitFunction.invoke_arn 
  
}

/*Creating API Gateway deployment to activate the above configuration and expose API to a URL that can be used for testing*/
resource "aws_api_gateway_deployment" "resume_site" {
  depends_on = [ 
    aws_api_gateway_integration.lambda, 
    aws_api_gateway_integration.lambda_root 
    ]

    rest_api_id = aws_api_gateway_rest_api.Resume_Site_Api.id
    stage_name = "test"
  
}

/*Creating Lambda Function URL*/
resource "aws_lambda_function_url" "url1" {
  function_name           = aws_lambda_function.visitFunction.function_name
  authorization_type      = "NONE"  

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date","keep-alive"]
    expose_headers    = ["keep-alive","date"]
    max_age           = 86400
  }
} 