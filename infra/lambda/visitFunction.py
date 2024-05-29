import json
import boto3

# Get the service resource.
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume_site_table')
item_searched = 1
def event_handler(event, context):

    response = table.update_item(
        Key={'VisitCounter': item_searched},
        UpdateExpression="SET Visits = Visits + :val",
        ExpressionAttributeValues={':val': 1},
        ReturnValues="UPDATED_NEW"
    )
    visits = response['Item']['Visits']
    return visits