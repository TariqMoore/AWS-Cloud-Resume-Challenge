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
item_searched = 1 #Refers to the primary key row (ID : 1)
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
        "headers": { #Returning headers through the lambda function. Function is setup with proxy integration in Terraform. 
            "Content-Type": "application/json", #Returning Json to browser
            "Access-Control-Allow-Origin": "*" #Allows cross origin resource sharing. Important since we setup lambda as a proxy.
        },
        "body": json.dumps(visits, cls=DecimalEncoder)
    }
    return res