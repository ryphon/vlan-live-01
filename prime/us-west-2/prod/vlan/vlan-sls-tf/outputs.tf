output "sls_role_arn" {
  value = aws_iam_role.sls.arn
}

output "firebase_arn" {
  value = aws_ssm_parameter.jwt.arn
}

output "firebase_name" {
  value = aws_ssm_parameter.jwt.name
}

output "firebase_key" {
  value = aws_kms_key.jwt.arn
}
