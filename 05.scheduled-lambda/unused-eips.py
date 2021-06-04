import boto3
import os

client = boto3.client('ec2')
sesClient = boto3.client('ses')

SOURCE_EMAIL = os.environ['SOURCE_EMAIL']
DEST_EMAIL = os.environ['DEST_EMAIL']

def lambda_handler(event,context):
    response = client.describe_addresses()
    eips = []
    # if elastic ip is not associated to any ec2 instances
    for eip in response['Addresses']:
        if 'InstanceId' not in eip:
            eips.append(eip['PublicIp'])

    # print(eips)

    # send email using ses
    if eips:
        sesClient.send_email(
           Source = SOURCE_EMAIL,
           Destination={
            'ToAddresses': [
                DEST_EMAIL
            ]
          },
          Message={
            'Subject': {
                'Data': 'Unused EIPS',
                'Charset': 'utf-8'
            },
            'Body': {
                'Text': {
                    'Data': str(eips),
                    'Charset': 'utf-8'
                }
            }
          }
        )
