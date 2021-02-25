data "null_data_source" "tags" {
  count = length(keys(var.tags))

  inputs = {
    key                 = element(keys(var.tags), count.index)
    value               = element(values(var.tags), count.index)
    propagate_at_launch = "true"
  }
}

data "template_file" "game" {
  template = <<EOF
#!/bin/bash
set -ex
yum update -y
yum install -y git \
               docker \
               aws-cli \
               htop \
               vim
sudo systemctl start docker
IPV4=$(curl 169.254.169.254/latest/meta-data/public-ipv4)
aws route53 change-resource-record-sets --hosted-zone-id ${data.terraform_remote_state.route53.outputs.hosted_zone_id} --change-batch "{
   \"Changes\":[
      {
         \"Action\":\"UPSERT\",
         \"ResourceRecordSet\":{
            \"Name\":\"${var.game}.${var.game_type_short}.itisamystery.com\",
            \"ResourceRecords\":[
               {
                  \"Value\":\"$IPV4\"
               }
            ],
            \"Type\":\"A\",
            \"TTL\":300
         }
      }
   ]
}"
echo WTF DO I DO
EOF
}

resource "aws_launch_template" "game" {
  name = "${var.game}-${var.game_type}"
  image_id = data.aws_ami.base_ami.id
  instance_type = var.instance_type
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.game.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 30
      volume_type = "gp3"
      throughput = 125
    }
  }
  tags = var.tags
  tag_specifications {
    resource_type = "volume"
    tags = var.tags
  }
  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }
  lifecycle {
    create_before_destroy = true
  }
  vpc_security_group_ids = [
    aws_security_group.game.id,
  ]
  user_data = base64encode(data.template_file.game.rendered)
}

