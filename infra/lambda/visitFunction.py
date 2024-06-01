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
    response = table.get_item(
        Key={'VisitCounter': item_searched}
    )
    
    visits = response['Item']['Visits']
    visitStr = str(visits)
    
    res = {
        "statusCode": 200,
        "data": visits,
        "headers": {
            "Content-Type": "*/*"
        },
        "body":"Hello, " + visitStr + " people have visited!"
    }
    return res