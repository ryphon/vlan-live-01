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
               vim \
               python3 \
               gcc-c++
sudo systemctl start docker
python3 -m pip install pip --upgrade
python3 -m pip install docker boto3 python-valve firebase_admin
sudo systemctl start docker
IPV4=$(curl 169.254.169.254/latest/meta-data/public-ipv4)
wget https://raw.githubusercontent.com/ryphon/vlan-live-01/main/prime/us-west-2/prod/vlan/running.py -O running.py
nohup python3 -u running.py --serverAddress localhost --serverPort 27015 --game "${var.game}" --gameType "${var.game_type_short}" --name "${var.game_name}" > /root/runlog.log &
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
docker run -idt -e "GLST=${var.glst}" -e "WORKSHOPCOLLECTIONID=${var.workshop_collection}" -e "WORKSHOPDL=${var.workshop_collection}" -e "WORKSHOP=${var.workshop_collection}" -e "GAMEMODE=${var.game_type}" -e "MAP=${var.default_map}" -p 27015:27015/tcp -p 27015:27015/udp -v /home/ec2-user/${var.game_type}:/opt/steam ${var.image}
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
  tags = var.tags
  key_name = aws_key_pair.key.id
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp3"
      throughput = 125
    }
  }

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

