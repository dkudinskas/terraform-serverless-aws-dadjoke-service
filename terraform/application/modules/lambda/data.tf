data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "dynamodb_ro_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.aws_ddb_table}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:decrypt"
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${var.aws_account_id}:key/*"
    ]
  }
}