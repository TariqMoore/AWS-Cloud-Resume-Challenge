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
  handler           = "func.lambda_handler"
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
  name                =  "aws_iam_policy_for_terraform_resume_site_policy"
  path                =  "/"
  description         =  "AWS IAM policy for managing the resume site role"
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
              "dynamodb:UpdateItem"
            ],
            "Resource" : "arn:aws:dynamodb:*:*:table/resume_site_table"
          },
        ]
      }
    ) 
}

/*Attaching policy to role*/
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_resume_site.arn
}

/**/
data "archive_file" "zip_the_python_code" {
  type = "zip"
  source_file = "${path.module}/lambda/visitFunction.py"
  output_path = "${path.module}/lambda/visitFunction.zip"
}