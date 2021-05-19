resource "aws_ssm_parameter" "asg" {
  name      = "asg_names"
  type      = "String"
  value     = "{\"gmod\": {\"ttt\": \"${data.terraform_remote_state.gmod_ttt.outputs.asg_name}\", \"hdn\": \"${data.terraform_remote_state.gmod_hdn.outputs.asg_name}\", \"dr\": \"${data.terraform_remote_state.gmod_dr.outputs.asg_name}\"}, \"soldat\": {\"dm\": \"${data.terraform_remote_state.soldat_dm.outputs.asg_name}\", \"ctf\": \"${data.terraform_remote_state.soldat_ctf.outputs.asg_name}\", \"rambo\": \"${data.terraform_remote_state.soldat_rambo.outputs.asg_name}\", \"oddball\": \"${data.terraform_remote_state.soldat_oddball.outputs.asg_name}\"}, \"minecraft\": {\"default\": \"${data.terraform_remote_state.minecraft_default.outputs.asg_name}\", \"sf4\": \"${data.terraform_remote_state.minecraft_sf4.outputs.asg_name}\"}, \"valheim\": {\"default\": \"${data.terraform_remote_state.valheim_default.outputs.asg_name}\"}}"
  tags = merge(
    {
      "Name" = "asg_names"
    },
    var.tags,
  )
}

resource "aws_kms_key" "jwt" {
  description = "vlan-sls kms key"
  tags = merge(
    {
      "Name" = "vlan-sls"
    },
    var.tags,
  )
}

resource "aws_kms_alias" "jwt" {
  name_prefix   = "alias/vlan-sls-"
  target_key_id = aws_kms_key.jwt.key_id
}

resource "aws_ssm_parameter" "jwt" {
  name      = "firebase_secrets"
  type      = "SecureString"
  value     = file("./service-account.json")
  key_id    = aws_kms_key.jwt.id
  tags = merge(
    {
      "Name" = "firebase_secrets"
    },
    var.tags,
  )
}
