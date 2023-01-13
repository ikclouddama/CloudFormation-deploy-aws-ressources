data "aws_iam_policy" "lambda_execute" {
  arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

data "aws_iam_policy" "lambda_vpc" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy" "efs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

#========lambda-iam-role-creation========

resource "aws_iam_role" "lambda_efs" {
  name               = "${var.environment}-lambdaEFS"
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

#=========aws managed policy attach to iam-role======

resource "aws_iam_role_policy_attachment" "lambda_execute_policy" {
  role = aws_iam_role.lambda_efs.name

  policy_arn = data.aws_iam_policy.lambda_execute.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_policy" {
  role = aws_iam_role.lambda_efs.name

  policy_arn = data.aws_iam_policy.lambda_vpc.arn
}

resource "aws_iam_role_policy_attachment" "lambda_efs_full_policy" {
  role = aws_iam_role.lambda_efs.name

  policy_arn = data.aws_iam_policy.efs_full_access.arn
}
