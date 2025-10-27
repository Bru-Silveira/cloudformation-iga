####### STACK: Container Platform
aws cloudformation deploy --stack-name BsContainersPlatform --template-file trash_BsContainersPlatform.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --region us-east-1
aws cloudformation describe-stacks --stack-name BsContainersPlatform --query "Stacks[0].Outputs"
aws cloudformation delete-stack --stack-name BsContainersPlatform

####### STACK: Task Definitions
aws cloudformation deploy --stack-name BsTaskDefinitions --template-file trash-BsTaskDefinitions.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --region us-east-1
aws cloudformation describe-stacks --stack-name BsTaskDefinitions --query "Stacks[0].Outputs"
aws cloudformation delete-stack --stack-name BsTaskDefinitions

####### STACK: S3 Buckets
aws cloudformation deploy --stack-name BsS3Buckets --template-file trash-BsS3Buckets.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --region us-east-1
aws cloudformation describe-stacks --stack-name BsS3Buckets --query "Stacks[0].Outputs"
aws cloudformation delete-stack --stack-name BsS3Buckets