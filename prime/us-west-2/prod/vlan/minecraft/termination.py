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

backup_queue_url = 'https://sqs.{}.amazonaws.com/456410706824/minecraft-default-lifecycle'.format(region)
# frustrating to hard code this, idk about this quite yet
queue_url = os.environ.get('SQS_QUEUE_URL', backup_queue_url)
while True:
    try:
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
            VisibilityTimeout=60,
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

        # Docker shutdown then wait 10s
        print('Docker list.')
        containers = docker_client.containers.list()
        print('Docker stop.')
        for container in containers:
            container.stop(timeout=10)

        # wait for init_script to back up the world as it is after the stop
        print('Waiting for final save efforts.')
        time.sleep(20)

        # Delete the message once I receive
        print('Deleting SQS Message now')
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )

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
        pass
    except docker.errors.APIError as e:
        print("Docker Api Error: {}".format(e))
