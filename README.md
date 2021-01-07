# Terraform Serverless AWS Dadjoke Service

This has mostly been done as a learning exercise to remind myself/learn new stuff about bash scripting, terraform, AWS things.

This is a complete deployments of a serverless service on AWS. It provides an API that hands out dadjokes.

### AWS Services
- IAM: for roles and policies
- S3: for terraform state, application zips
- Lambda: the 'business logic' lives there, in Javascript
- API Gateway: provides the API endpoint
- DynamoDB: stores dadjokes
- KMS: automatically generated lambda key used to decrypt lambda env var

No servers were provisioned in the deploying of this service!

### Requirements

To deploy it to your own environment you would need
- AWS account: ID of your AWS account, and access to said account
- Terraform
- Bash: a bash script for convenience of deploying/destroying things selectively

### Configuration

I have put the required config switches into root folder config.json file.

HOWEVER: there are a couple of places in the code where terraform does not accept variables, and i hardcoded values. Don't know how to work around this just yet.
These places are the terraform backend specifications in *database/main.tf* and *application/main.tf*
for 'region' and 'state bucket'. Variables are now allowed there :/

### Key Components

- Lambda: This is where the actual js file with the business logic. It will be compressed into a zip file and uploaded to create a lambda from
- terraform
  - state: the first thing that has to be provisioned. It will later store all the terraform state for provisioned resources. It will be used as terraform backend.
  - database: this is the dynamodb nosql database. should be provisioned second, as it uses the state bucket already; and lambda creation depends on this database existing
  - application
    - modules
      - apigateway: provision the api gateway endpoint and deployment, response mode 'proxy' (no transformations)
      - lambda: provision the lambda, and required permissions.
      - s3: provision the bucket where we will upload zipped lambdas, and perform the upload
- deploy.sh: a helper bash script to deploy all these things in correct sequence, or one by one specifically, or destroy them, passing tf vars from config
- config.json: config switches that deploy.sh bash script will read and pass into the correct commands

### Application versioning

Two ways to version. The deployments bucket has versioning enabled, so you can see previous versions, revert to them. Then need to recreate the lambda.

But i have provided a manual versioning mechanism. There is a config.json switch that you can update (1.0.0 -> 1.0.1) and rerun the deployments.
This should a) reupload the zip, as i use file contents hash for the zip, and terraform picks up that a new zip is created each time
b) recreate the lambda as the source key changes

### TODO

I still want to provide a custom KMS key and not use the default one, as the current implementation
will allow lambda to read all KMS keys and that's not great

I still want to implement second endpoint - a POST to save new dadjokes to DDB. This will need a tweaked policies/new policies.

.. among many other things :)