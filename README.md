# Terraform Firelens to Firehose to Datadog Example

 * Terraform
  * AWS Fargate
  * FireLens
  * Amazon Kinesis Data Firehose
  * Datadog  
  * S3
 

```
aws ssm put-parameter \
    --name "/datadog_apikey" \
    --region "us-west-2" \
    --value "YOUR_DATADOG_API_KEY" \
    --type "SecureString"
```

```
tfenv install 1.1.5
tfenv use 1.1.5
tflint --init 
terraform init
terraform plan
terraform apply
```
