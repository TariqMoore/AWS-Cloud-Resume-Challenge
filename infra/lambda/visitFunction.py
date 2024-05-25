import json
import boto3

#Grabbing the AWS resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume_site_tabe')
print(table)

def lambda_handler(event, context):
    # TODO implement
        return "Can't find table" 