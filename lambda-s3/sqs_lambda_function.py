import boto3
from botocore.exceptions import ClientError
import uuid
import json

bucket_name = "paul-test-bucket-random"

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    
    print(event)

    

    messageBody = json.loads(event['Records'][0]['body'])
    print(messageBody)
    name = messageBody['name']





    message = 'Hello {}!'.format(name) 
    
    
    s3_client.put_object(
     Bucket=bucket_name,
     Key=name + "-"+  str(uuid.uuid4()),
     Body=message,
    )
    
    return {
        "body" : message
    }