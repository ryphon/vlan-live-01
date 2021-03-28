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
nohup python3 -u running.py --serverAddress localhost --serverPort 2457 --game "${var.game}" --gameType "${var.game_type}" --name "${var.game_name}"> /root/runlog.log &
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
aws s3 cp s3://${aws_s3_bucket.worlds.id}/${var.game_type}/latest.tar.zst .
tar --use-compress-program zstd -xvf latest.tar.zst
rm latest.tar.zst
set +e
rm /root/gp3/valheim/config/backups/*
(
  docker run -i \
    -p 2456-2458:2456-2458/udp \
    -p 2456-2458:2456-2458/tcp \
    -v /root/gp3/valheim/config:/config \
    -e SERVER_NAME="vlan-${var.game}-${var.game_type}" \
    -e WORLD_NAME="${var.world_name}" \
    -e SERVER_PASS="${var.server_password}" \
    -e VALHEIM_PLUS=true \
    -e VPCFG_Server_enabled=true \
    -e VPCFG_Server_enforceMod=true \
    -e VPCFG_Server_maxPlayers=12 \
    -e VPCFG_Server_dataRate=120 \
    -e VPCFG_Server_serverSyncsConfig=true \
    -e VPCFG_Building_enabled=true \
    -e VPCFG_Building_maximumPlacementDIstance=10 \
    -e VPCFG_Fermenter_enabled=true \
    -e VPCFG_Fermenter_showFermenterDuration=true \
    -e VPCFG_Fermenter_autoDeposit=true \
    -e VPCFG_Fermenter_autoFuel=true \
    -e VPCFG_FireSource_enabled=true \
    -e VPCFG_FireSource_torches=true \
    -e VPCFG_FireSource_fires=true \
    -e VPCFG_FireSource_=true \
    -e VPCFG_Furnace_enabled=true \
    -e VPCFG_Furnace_maximumOre=30 \
    -e VPCFG_Furnace_maximumCoal=50 \
    -e VPCFG_Furnace_autoDeposit=true \
    -e VPCFG_Furnace_autoDepositRange=8 \
    -e VPCFG_Furance_autoFuel=true \
    -e VPCFG_Items_enabled=true \
    -e VPCFG_Items_itemStackMultiplier=50 \
    -e VPCFG_Hud_enabled=true \
    -e VPCFG_Hud_experienceGainedNotifications=true \
    -e VPCFG_Kiln_enabled=true \
    -e VPCFG_Kiln_dontProcessFineWood=true \
    -e VPCFG_Kiln_dontProcessRoundLog=true \
    -e VPCFG_Kiln_maximumWood=50 \
    -e VPCFG_Kiln_autoDeposit=true \
    -e VPCFG_Kiln_autoFuel=true \
    -e VPCFG_Kiln_autoDepositRange=2 \
    -e VPCFG_Map_enabled=true \
    -e VPCFG_Map_exploreRadius=150 \
    -e VPCFG_Map_shareMapProgression=true \
    -e VPCFG_Map_preventPlayerFromTurningOffPublicPosition=true \
    -e VPCFG_Player_enabled=true \
    -e VPCFG_Player_baseUnarmedDamage=240 \
    -e VPCFG_Player_cropNotifier=true \
    -e VPCFG_Player_autoRepair=true \
    -e VPCFG_Player_fallDamage=-25 \
    -e VPCFG_Player_reequipItemsAfterSwimming=true \
    -e VPCFG_StructuralIntegrity_enabled=true \
    -e VPCFG_StructuralIntegrity_wood=25 \
    -e VPCFG_StructuralIntegrity_stone=25 \
    -e VPCFG_StructuralIntegrity_iron=25 \
    -e VPCFG_StructuralIntegrity_hardWood=25 \
    -e VPCFG_StructuralIntegrity_disableWaterDamageToPlayerBoats=true \
    -e VPCFG_FirstPerson_enabled=true \
    -e VPCFG_FirstPerson_defaultFOV=90 \
    -e VPCFG_Stamina_enabled=true \
    -e VPCFG_Stamina_sneakStaminaDrain=-50 \
    -e VPCFG_Stamina_swimStaminaDrain=-50 \
    ${var.image}
)
set -e
tar --use-compress-program zstd -cvf "latest.tar.zst" "/root/gp3/valheim"
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

