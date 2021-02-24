resource "aws_ssm_parameter" "asg" {
  name      = "asg_names"
  type      = "String"
  value     = "{\"gmod\": {\"ttt\": \"${data.terraform_remote_state.gmod_ttt.outputs.asg_name}\", \"hdn\": \"${data.terraform_remote_state.gmod_hdn.outputs.asg_name}\", \"dr\": \"${data.terraform_remote_state.gmod_dr.outputs.asg_name}\"}, \"soldat\": {\"dm\": \"${data.terraform_remote_state.soldat_dm.outputs.asg_name}\", \"ctf\": \"${data.terraform_remote_state.soldat_ctf.outputs.asg_name}\", \"rambo\": \"${data.terraform_remote_state.soldat_rambo.outputs.asg_name}\", \"oddball\": \"${data.terraform_remote_state.soldat_oddball.outputs.asg_name}\"}, \"minecraft\": {\"minecraft\": \"placeholder\"}, \"valheim\": {\"valheim\": \"placeholder\"}}"
  tags = merge(
    {
      "Name" = "asg_names"
    },
    var.tags,
  )
}
