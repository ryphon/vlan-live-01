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
export AWS_REGION=${var.aws_region}
export SQS_QUEUE_URL=${aws_sqs_queue.game.id}
yum update -y
yum install -y git \
               docker \
               aws-cli \
               htop \
               vim \
               python3 \
               gcc-c++
sudo systemctl start docker
IPV4=$(curl 169.254.169.254/latest/meta-data/public-ipv4)
python3 -m pip install pip --upgrade
python3 -m pip install docker boto3 firebase_admin mcstatus
wget https://raw.githubusercontent.com/ryphon/vlan-live-01/main/prime/us-west-2/prod/vlan/${var.game}/termination.py -O termination.py
wget https://raw.githubusercontent.com/ryphon/vlan-live-01/main/prime/us-west-2/prod/vlan/running.py -O running.py
nohup python3 -u termination.py > /root/termlog.log &
nohup python3 -u running.py --serverAddress $IPV4 --serverPort 25565 --game "${var.game}" --gameType "${var.game_type}" --name "${var.game_name}"> /root/runlog.log &
sudo systemctl start docker
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
cd /
aws s3 cp s3://${aws_s3_bucket.worlds.id}/${var.game_type}/latest.tar.gz .
tar -xzvf latest.tar.gz
rm latest.tar.gz
mkdir /root/gp3/modpacks
wget "https://media.forgecdn.net/files/3012/798/SkyFactory-4_4.2.2.zip" -P /root/gp3/modpacks
set +e
(
  docker run -i \
    -p 25565:25565 \
    -e EULA=TRUE \
    -e TYPE=CURSEFORGE \
    -e CF_SERVER_MOD=/modpacks/SkyFactory-4_4.2.2.zip \
    -v /etc/timezone:/etc/timezone:ro \
    -v /root/gp3/${var.game}:/data \
    -v /root/gp3/modpacks:/modpacks
    ${var.image}
)
set -e
tar -czvf "latest.tar.gz" "/root/gp3/${var.game}"
aws s3 cp "latest.tar.gz" "s3://${aws_s3_bucket.worlds.id}/${var.game_type}/latest.tar.gz"
DATE=`date +%H-%M--%m-%d-%y`
mv "latest.tar.gz" "$DATE.tar.gz"
aws s3 cp "$DATE.tar.gz" "s3://${aws_s3_bucket.worlds.id}/${var.game_type}/archive/$DATE.tar.gz"
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

  key_name = aws_key_pair.key.id

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

