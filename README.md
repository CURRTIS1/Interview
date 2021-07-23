# Interview


# Web application
Flask app written in python, hosting my CV as a static HTML page

# Config build/management
Terraform

# Infrastructure
ECS Fargate cluster behind an ALB
Fargate benefits from being a managed service and cheaper than ECS on EC2

# Revision control
## Github
Terraform repo - https://github.com/CURRTIS1/Interview
Python app repo - https://github.com/CURRTIS1/Interviewapp

# Continuous integration / deployment
Github repo > Codebuild

# Automated orhcestration / Build process
Terraform. Codebuild > ECR > ECS

# Security hardening
Using python:3.7-alpine environment over python:3 has cleared 438 ECR vulnerabilities

# Monitoring / Alerting
- ECS cluster has Container insights sending logs to Cloudwatch loggroups
- Route 53 healthcheck on the ALB DNS name
- Cloudwatch alarm sending notifications to SNS topic based on the R53 healthcheck

# Ticket / time management
https://trello.com/b/IBpvZtcy/interview-to-do

# Certificate - lets encrypt
na