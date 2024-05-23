/*Creating the Visitor Counter item*/
resource "aws_dynamodb_table_item" "item1" { 
    #Depends_on is saying THIS resource is dependent on the DynamoDB table "Resume_Site_Table"
    depends_on      = [ 
        aws_dynamodb_table.resume_site_table 
        ]
    table_name      = aws_dynamodb_table.resume_site_table.name #Pulls the name of the database table from above.
    hash_key        = aws_dynamodb_table.resume_site_table.hash_key 

    #Required => DynamoDB uses JSON Representation of a map of attribute name/value pairs, one for each attribute
    item    =   <<ITEM
    {
        "VisitCounter": {"N": "0"}
    }
    ITEM
}