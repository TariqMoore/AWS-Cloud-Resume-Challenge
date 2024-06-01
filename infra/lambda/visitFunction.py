import json
import boto3

from decimal import Decimal

#Helper function created to convert Decimal to JSON serializable
class DecimalEncoder(json.JSONEncoder):
  def default(self, obj):
    if isinstance(obj, Decimal):
      return str(obj)
    return json.JSONEncoder.default(self, obj)
    
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
    
    #Created response variable to return statusCode, and visit count
    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(visits, cls=DecimalEncoder)
    }
    return res