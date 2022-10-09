# AWS extra assume role for local development
data "aws_iam_policy_document" "local_airflow_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::00123456789:user/user_for_api_calls"]
    }
  }
}

resource "aws_iam_role" "local_airflow_assume_role" {
  name = format("local_airflow-exec-role-%s", var.environment)
  # If applicable - permission boundary may be necessary to set up all roles in your AWS environment
  # permissions_boundary = format("arn:aws:iam::%s:policy/env-boundary", var.account_id)
  assume_role_policy = data.aws_iam_policy_document.local_airflow_assume_role_policy_document.json
}

# To alter in a production environment - AdministratorAccess is definitely too much
resource "aws_iam_role_policy_attachment" "local_airflow_assume_role_policy_attachement" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.local_airflow_assume_role.name
}


# AWS MWAA role
data "aws_iam_policy_document" "mwaa_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["airflow.amazonaws.com", "airflow-env.amazonaws.com"]
    }
  }
}

# To alter in a production environemnt
data "aws_iam_policy_document" "mwaa_exec_role_policy_document" {
  statement {
    actions = [
      "s3:*",
      "iam:*",
      "cloudwatch:*",
      "logs:*",
      "sqs:*",
      "kms:*",
      "glue:*",
      "elasticmapreduce:*",
      "redshift:*",
      "sagemaker:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "mwaa_assume_role" {
  name = format("mwaa-exec-role-%s", var.environment)
  # If applicable - permission boundary may be necessary to set up all roles in your AWS environment
  # permissions_boundary = format("arn:aws:iam::%s:policy/env-boundary", var.account_id)
  assume_role_policy = data.aws_iam_policy_document.mwaa_assume_role_policy_document.json
}

resource "aws_iam_policy" "mwaa_exec_role_policy" {
  policy = data.aws_iam_policy_document.mwaa_exec_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "mwaa_assume_role_policy_attachement" {
  policy_arn = aws_iam_policy.mwaa_exec_role_policy.arn
  role       = aws_iam_role.mwaa_assume_role.name
}


# AWS Glue role for crawlers and jobs
data "aws_iam_policy_document" "glue_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_role_policy_document" {
  statement {
    actions = [
      "s3:*",
      "glue:*",
      "cloudwatch:*",
      "logs:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "glue_assume_role" {
  name = format("ap-role-glue-%s", var.environment)
  # If applicable - permission boundary may be necessary to set up all roles in your AWS environment
  # permissions_boundary = format("arn:aws:iam::%s:policy/env-boundary", var.account_id)
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy_document.json
}

resource "aws_iam_policy" "glue_role_policy" {
  policy = data.aws_iam_policy_document.glue_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_assume_role_policy_attachement" {
  policy_arn = aws_iam_policy.glue_role_policy.arn
  role       = aws_iam_role.glue_assume_role.name
}


# AWS Sagemaker role for ML jobs
data "aws_iam_policy_document" "sagemaker_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sagemaker_role_policy_document" {
  statement {
    actions = [
      "s3:*",
      "sagemaker:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "sagemaker_assume_role" {
  name = format("ap-role-sagemaker-%s", var.environment)
  # If applicable - permission boundary may be necessary to set up all roles in your AWS environment
  # permissions_boundary = format("arn:aws:iam::%s:policy/env-boundary", var.account_id)
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role_policy_document.json
}

resource "aws_iam_policy" "sagemaker_role_policy" {
  policy = data.aws_iam_policy_document.sagemaker_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "sagemaker_assume_role_policy_attachement" {
  policy_arn = aws_iam_policy.sagemaker_role_policy.arn
  role       = aws_iam_role.sagemaker_assume_role.name
}


# AWS EMR default role
data "aws_iam_policy_document" "emr_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "emr_assume_role" {
  name = format("ap-role-emr-%s", var.environment)
  # If applicable - permission boundary may be necessary to set up all roles in your AWS environment
  # permissions_boundary = format("arn:aws:iam::%s:policy/env-boundary", var.account_id)
  assume_role_policy = data.aws_iam_policy_document.emr_assume_role_policy_document.json
}


resource "aws_iam_role_policy_attachment" "emr_assume_role_policy_attachement_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.emr_assume_role.name
}

resource "aws_iam_role_policy_attachment" "emr_assume_role_policy_attachement_emr" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
  role       = aws_iam_role.emr_assume_role.name
}

resource "aws_iam_instance_profile" "emr_instance_profile" {
  name = "emr_instance_profile"
  role = aws_iam_role.emr_assume_role.name
}


# AWS EMR EC2 default role
data "aws_iam_policy_document" "emr_ec2_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "emr_ec2_assume_role" {
  name = format("ap-role-emr-ec2-%s", var.environment)
  # If applicable - permission boundary may be necessary to set up all roles in your AWS environment
  # permissions_boundary = format("arn:aws:iam::%s:policy/env-boundary", var.account_id)
  assume_role_policy = data.aws_iam_policy_document.emr_ec2_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "emr_ec2_assume_role_policy_attachement_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.emr_ec2_assume_role.name
}

resource "aws_iam_role_policy_attachment" "emr_ec2_assume_role_policy_attachement_emr" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
  role       = aws_iam_role.emr_ec2_assume_role.name
}

resource "aws_iam_instance_profile" "emr_ec2_instance_profile" {
  name = "emr_ec2_instance_profile"
  role = aws_iam_role.emr_ec2_assume_role.name
}


# AWS Redshift role
data "aws_iam_policy_document" "redshift_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "redshift_assume_role" {
  name = format("ap-role-redshift-%s", var.environment)
  # If applicable - permission boundary may be necessary to set up all roles in your AWS environment
  # permissions_boundary = format("arn:aws:iam::%s:policy/env-boundary", var.account_id)
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "redshift_assume_role_policy_attachement_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.redshift_assume_role.name
}

resource "aws_iam_role_policy_attachment" "redshift_assume_role_policy_attachement_emr" {
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
  role       = aws_iam_role.redshift_assume_role.name
}