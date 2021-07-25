/**
 * # 300compute - main.tf
*/

terraform {
  required_version = "0.13.5"

  backend "s3" {
    bucket = "curtis-terraform-interview-2021"
    key    = "terraform.350container.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  version    = "~> 3.3.0"
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  tags = {
    environment = var.environment
    layer       = var.layer
    terraform   = "true"
  }
}

data "terraform_remote_state" "state_000base" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-interview-2021"
    key    = "terraform.000base.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "state_100security" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-interview-2021"
    key    = "terraform.100security.tfstate"
    region = "us-east-1"
  }
}


data "aws_caller_identity" "current" {
}

## ----------------------------------
## ECR Repository

resource "aws_ecr_repository" "my_ecr_repo" {
  name = "curtis-int-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
}


## ----------------------------------
## Codebuild IAM role

resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild_role"
  permissions_boundary = "arn:aws:iam::615196324256:policy/dog-policy-policy-boundary"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "codebuild.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}


## ----------------------------------
## Codebuild policy

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild_policy"
  description = "my codebuild policy"
  policy      = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Sid" : "CloudWatchLogsPolicy",
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource" : [
        "*"
      ]
    },
    {
      "Sid" : "CodeCommitPolicy",
      "Effect" : "Allow",
      "Action" : [
        "codecommit:GitPull"
      ],
      "Resource" : [
        "*"
      ]
    },
    {
      "Sid" : "S3GetObjectPolicy",
      "Effect" : "Allow",
      "Action" : [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource" : [
        "*"
      ]
    },
    {
      "Sid" : "S3PutObjectPolicy",
      "Effect" : "Allow",
      "Action" : [
        "s3:PutObject"
      ],
      "Resource" : [
        "*"
      ]
    },
    {
      "Sid" : "ECRPullPolicy",
      "Effect" : "Allow",
      "Action" : [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource" : [
        "*"
      ]
    },
    {
      "Sid" : "ECRAuthPolicy",
      "Effect" : "Allow",
      "Action" : [
        "ecr:GetAuthorizationToken"
      ],
      "Resource" : [
        "*"
      ]
    },
    {
      "Sid" : "S3BucketIdentity",
      "Effect" : "Allow",
      "Action" : [
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:CreateNetworkInterfacePermission",
        "ec2:*",
        "ecr:*"
      ],
      "Resource" : [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuildrole_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuildrole_attach2" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

## ----------------------------------
## Codebuild project

resource "aws_codebuild_project" "mycodebuildproject" {
  name         = "my-codebuild-project"
  description  = "Test codebuild project"
  service_role = aws_iam_role.codebuild_role.id
  source {
    type     = "GITHUB"
    location = "https://github.com/CURRTIS1/Interviewapp.git"
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:1.0"
    privileged_mode = true
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.my_ecr_repo.id
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }
  vpc_config {
    vpc_id             = data.terraform_remote_state.state_000base.outputs.vpc_id
    subnets            = data.terraform_remote_state.state_000base.outputs.subnet_private
    security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_ecs]
  }
}


## ----------------------------------
## ECS Cluster

resource "aws_ecs_cluster" "Curtis-int" {
  name = "Curtis-Interview"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


## ----------------------------------
## ECS IAM role

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  permissions_boundary = "arn:aws:iam::615196324256:policy/dog-policy-policy-boundary"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
                "Service": [
                  "ecs.amazonaws.com",
                  "ecs-tasks.amazonaws.com"
                ]
              },
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecsrole_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

## ----------------------------------
## ECS policy

resource "aws_iam_policy" "ecs_policy" {
  name        = "ecs_policy"
  description = "my ecs policy"
  policy      = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Sid" : "ECR",
      "Effect" : "Allow",
      "Action" : [
        "ecr:*"
      ],
      "Resource" : [
        "*"
      ]
    }
  ]
}
EOF
}


## ----------------------------------
## ECS Task definition

resource "aws_ecs_task_definition" "mytaskdef" {
  family                   = "Curtis-int"
  requires_compatibilities = ["FARGATE"]
  memory                   = 512
  cpu                      = 256
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.my_ecr_repo.name}:latest"
      cpu       = 1
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}


## ----------------------------------
## ECS Loadbalancer

module "ec2_alb" {
  source = "github.com/CURRTIS1/Interview/modules/ec2_alb"

  vpc_id             = data.terraform_remote_state.state_000base.outputs.vpc_id
  elb_subnets        = data.terraform_remote_state.state_000base.outputs.subnet_public
  elb_securitygroups = [data.terraform_remote_state.state_100security.outputs.sg_ecs]
  tg_name            = var.tg_name
  elb_name           = var.elb_name
  elb_port           = 80
  target_type        = var.target_type
  tg_port = var.tg_port
}


## ----------------------------------
## ECS Service

resource "aws_ecs_service" "myecssvc" {
  name            = "Curtis-Int-Service"
  cluster         = aws_ecs_cluster.Curtis-int.id
  task_definition = aws_ecs_task_definition.mytaskdef.id
  desired_count   = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets         = data.terraform_remote_state.state_000base.outputs.subnet_public
    security_groups = [data.terraform_remote_state.state_100security.outputs.sg_ecs]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = module.ec2_alb.elb_target_group
    container_name   = "first"
    container_port   = 80
  }
  depends_on = [
    module.ec2_alb.elb
  ]
}


## ----------------------------------
## ALB monitoring

resource "aws_route53_health_check" "alb_check" {
  fqdn = module.ec2_alb.elb_dns
  port = 80
  type = "HTTP"
  resource_path = "/"
  failure_threshold = "5"
  request_interval = "30"
  regions           = ["eu-west-1", "us-east-1", "us-west-1"]
}

resource "aws_sns_topic" "alb_topic" {
  name = "My-alb-check"
}

resource "aws_sns_topic_subscription" "my_alb_sub" {
  topic_arn = aws_sns_topic.alb_topic.arn
  protocol = "sms"
  endpoint = "+447801455201"
}

resource "aws_cloudwatch_metric_alarm" "alb_check" {
  alarm_name = "alb_check"
  metric_name = "HealthCheckPercentageHealthy"
  statistic           = "Average"
  period              = "300"
  threshold = "60"
  evaluation_periods = "2"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace = "AWS/Route53"
  actions_enabled = "true"
  alarm_actions = [aws_sns_topic.alb_topic.id]
  ok_actions = [aws_sns_topic.alb_topic.id]
  dimensions = {
    HealthCheckId = aws_route53_health_check.alb_check.id
  }
}

## ----------------------------------
## CodeCommit repo

resource "aws_codecommit_repository" "Curtis-int" {
  repository_name = "Curtis-int-Repo"
  description     = "This is the Repository for Curtis Interview"
}

resource "aws_s3_bucket" "codebuild_bucket" {
  versioning {
    enabled = true
  }
}


## ----------------------------------
## S3 bucket

resource "null_resource" "my_resource" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/app s3://${aws_s3_bucket.codebuild_bucket.id}"
    environment = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key
      AWS_SECRET_ACCESS_KEY = var.aws_secret_key
    }
  }
}


## ----------------------------------
## Codepipeline

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"
  permissions_boundary = "arn:aws:iam::615196324256:policy/dog-policy-policy-boundary"

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

resource "aws_iam_policy" "codepipeline_policy" {
  name = "codepipeline_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_bucket.arn}",
        "${aws_s3_bucket.codebuild_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_codepipeline" "mycodepipeline" {
  name     = "Curtis-Interview"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codebuild_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket = "${aws_s3_bucket.codebuild_bucket.id}"
        S3ObjectKey = "InterviewApp.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.mycodebuildproject.arn}"
      }
    }
  }
}

