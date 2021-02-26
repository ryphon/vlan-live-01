#!/usr/bin/env python3
import time
import os
import sys
import json
import docker
import boto3
region = os.environ.get('AWS_REGION', 'us-west-2')
sqs = boto3.client('sqs', region_name=region)
asg = boto3.client('autoscaling', region_name=region)
docker_client = docker.from_env()

backup_queue_url = 'https://sqs.{}.amazonaws.com/456410706824/valheim-default-lifecycle'.format(region)
# frustrating to hard code this, idk about this quite yet
queue_url = os.environ.get('SQS_QUEUE_URL', backup_queue_url)
'''
{
    'MessageId': '34c9da53-fbb5-4823-8679-b07297030896',
    'ReceiptHandle': 'AQEBP5yRsqjtQt5cLYBry/2DxGh9jFBjUiDuiLMXK/NMdewHSluWWvVTMIpuNCkz2k7xwd6VI5oQPg+JsMBVPFKtKtpVKgCA/aJNckAWjxOS4LN+FxDJFvfMpjtMLjtIRugFMiGSE4AMCLduJwX8DMpX0XpPuMx5gDtgsSDh2dQmiR1CSvndyF2yg+K5EP3guSQP35Nczzc/jhWHbmXIAj19igenkXLhB7v7lML79CZzwZTiKrOt8TwnBOcuO7SZD78MY9gGFQgSny8oTY7F6WRsWQRPbH1OurQtvI5rY2RlVWoRcXaXXVIdUoLYwqRySultgJ4BLsmDASmHuwaIjZ2J0FNvQmjkezQDCEZxGUL/Vz/tc9PBi+JNKtg04IEZ6PWCmqOREuodNd+yKxEVi7RKkuJfhJU6QATZwaet8Fd6FW8=',
    'MD5OfBody': 'd27dac4b7d3f761b5bd3d32d5d5e81fb',
    'Body': '{"LifecycleHookName":"valheim-default-terminate","AccountId":"456410706824","RequestId":"a7b2d01b-69d3-4940-910a-3a2ee0cbe1f9","LifecycleTransition":"autoscaling:EC2_INSTANCE_TERMINATING","AutoScalingGroupName":"valheim-default","Service":"AWS Auto Scaling","Time":"2021-02-26T06:40:06.663Z","EC2InstanceId":"i-016a0e69d8b5ae49d","NotificationMetadata":"{\\n  \\"game\\": valheim,\\n  \\"gameType\\": default,\\n  \\"asgName\\": valheim-default\\n}\\n","LifecycleActionToken":"dce60e5a-ffe3-4a47-bd57-56effbaefd60"}',
    'Attributes': {'SentTimestamp': '1614321606685'}}
'''
while True:
    try:
        print('Rx')
        response = sqs.receive_message(
            QueueUrl=queue_url,
            AttributeNames=[
                'SentTimestamp',
                'SequenceNumber'
            ],
            MaxNumberOfMessages=1,
            MessageAttributeNames=[
                'All'
            ],
            VisibilityTimeout=15,
            WaitTimeSeconds=2
        )
        message = response['Messages'][0]
        print('Message recieved, starting kill process now.')
        message_body = json.loads(message['Body'])
        receipt_handle = message['ReceiptHandle']
        lifecycleToken = message_body['LifecycleActionToken']
        metadata = json.loads(message_body['NotificationMetadata'].strip())
        lifecycle_hook_name = message_body['LifecycleHookName']
        autoscaling_group_name = metadata['asgName']

        # Delete the message once I receive
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )

        # docker shutdown then wait 10s
        print('Docker shutdown.')
        containers = docker_client.containers.list()
        containers[0].stop()

        # wait for init_script to back up the world as it is after the stop
        print('Waiting for final save efforts.')
        time.sleep(20)

        print('Complete Lifecycle now.')
        # now you can allow the instance to die
        resp = asg.complete_lifecycle_action(
            LifecycleHookName=lifecycle_hook_name,
            AutoScalingGroupName=autoscaling_group_name,
            LifecycleActionResult='CONTINUE',
            LifecycleActionToken=lifecycleToken
        )

        # ur gonna die anyway LUL
        print('We\'re done!')
        sys.exit(0)
        break
    except KeyError:
        print('No RX')
        pass
