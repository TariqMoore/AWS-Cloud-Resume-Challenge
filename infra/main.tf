/*Below is the creation of the DynamoDB Table*/
resource "aws_dynamodb_table" "resume_site_table" {
    name            =   "resume_site_table" #(Required), this needs to be unique within the region. This is the physical name of the table.
    billing_mode    =   "PAY_PER_REQUEST" #(Optional) Billing_Mode controls how you are charged. Default is PROVISIONED
    hash_key        =   "VisitCounter" #(Required) Hash_key is the primary key of the table.
    table_class     =   "STANDARD" 
    
    attribute {
      name          =   "VisitCounter" #Name of the attribute
      type          =   "N" #Attribute types. This can be S (string), N (number), or B (Binary)
    }
    tags = {
        Name        =   "ResumeSite" #Attached Billing Tag for monitoring
    }
}