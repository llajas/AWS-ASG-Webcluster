This module can be used to create an s3 storage bucket and DynamoDB table that will be used to hold and lock the terraform state files generated from our modules, respectively. While the state files can be stored locally, this creates issues in relation to collaboration and overall security. This module aims to help get around those issues by creating an s3 bucket comes with the following options enabled:

Encryption - s3 bucket will be encrypted by default, preventing data from being read as plain text, namely the state files that hold sensitive data/secrets.
Versioning - important as the state file can/will undergo changes overtime - This allows rolling back to a previous version.
Locking - Prevents multiple team members from making edits/changes at the same time.
Confidentiality - the s3 bucket and all contained objects will be restricted from public access

Additionally, the resource will be created with the 'prevent_destroy = true' option set, to ensure that the data isn't lost on accident.

First, run 'Terraform init' followed by 'terraform apply' - You'll be prompted for the name of the s3 bucket you'd like to create as well as the name of the DynamoDB table.
After the resources have been created and you are given the outputs for your s3 bucket and DynamoDB table, you'll want to go back into the 'main.tf' file and uncomment the 'terraform' block at the bottom, updating 'bucket' & 'dynamodb_table' with the information from the prior step. This will move the terraform state file for this s3 bucket creation into s3 for holding.

Once this is done, feel free to use the s3 bucket for storing your state files.