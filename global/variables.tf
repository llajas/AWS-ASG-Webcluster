variable "bucket_name" {
    description = "the name to give the bucket"
}

variable "dynamo_db_lock_name" {
    description = "the name to give the DynamoDB used for locking the state file"
}