# terraform-lambda-python
Terraform module that packages and deploys a python-based AWS Lambda function

## Example usage:
```
module "router_lambda" {
  source                      = "git::ssh://git@github.digitalglobe.com/p20-20-devops/terraform-lamdba-python.git//?ref=master"
  aws_account_id              = "${var.aws_account_id}"
  aws_region                  = "${var.aws_region}"
  entrypoint                  = "main.process_event"
  env_name                    = "${var.env_name}"
  function_name               = "${var.app_name}_router"
  source_path                 = "${path.module}/router"
  subnet_ids                  = "${data.terraform_remote_state.vpc.private_app_subnet_ids}"
  tags                        = "${merge(map("Name", "${var.app_name}-${var.env_name}"),var.tags)}"
  vpc_id                      = "${data.terraform_remote_state.vpc.vpc_id}"
  environment_variables       = {
    SQS_PYTHON_QUEUE_NAME     = "${aws_sqs_queue.python.name}"
  }
  policy_attachment_arn       = "${aws_iam_policy.sqs_for_lambda.arn}"
}
```
