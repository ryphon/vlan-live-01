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
               gcc-c++ \
               zstd
sudo systemctl start docker
python3 -m pip install pip --upgrade
python3 -m pip install docker boto3 python-valve firebase_admin
wget https://raw.githubusercontent.com/ryphon/vlan-live-01/main/prime/us-west-2/prod/vlan/${var.game}/termination.py -O termination.py
wget https://raw.githubusercontent.com/ryphon/vlan-live-01/main/prime/us-west-2/prod/vlan/running.py -O running.py
nohup python3 -u termination.py > /root/termlog.log &
nohup python3 -u running.py --serverAddress localhost --serverPort 34197 --game "${var.game}" --gameType "${var.game_type}" --name "${var.game_name}"> /root/runlog.log &
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
cd /
mkdir /root/gp3/factorio -p
chown 845:845 /root/gp3/factorio
aws s3 cp s3://${aws_s3_bucket.worlds.id}/${var.game_type}/latest.tar.zst .
tar --use-compress-program zstd -xvf latest.tar.zst
rm latest.tar.zst
set +e
(
  docker run \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /root/gp3/factorio:/factorio \
  --name factorio \
  -e LOAD_LATEST_SAVE=true
  factoriotools/factorio
)
set -e
tar --use-compress-program zstd -cvf "latest.tar.zst" "/root/gp3/${var.game}"
aws s3 cp "latest.tar.zst" "s3://${aws_s3_bucket.worlds.id}/${var.game_type}/latest.tar.zst"
DATE=`date +%H-%M--%m-%d-%y`
mv "latest.tar.zst" "$DATE.tar.zst"
aws s3 cp "$DATE.tar.zst" "s3://${aws_s3_bucket.worlds.id}/${var.game_type}/archive/$DATE.tar.zst"
EOF
}

resource "aws_launch_template" "game" {
  name = "${var.game}-${var.game_type}"
  image_id = data.aws_ami.base_ami.id
  instance_type = var.instance_type

  key_name = aws_key_pair.key.id

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.game.id]
  }

  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.game.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

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
  user_data = base64encode(data.template_file.game.rendered)
}

