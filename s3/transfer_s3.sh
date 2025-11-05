# Para rodar o comando do .sh no cdm, precisa sempre rodar esse comando primeiro:
SET AWS_ACCESS_KEY_ID=*******
SET AWS_SECRET_ACCESS_KEY=********
SET AWS_SESSION_TOKEN=********

# Se quiser validar o template antes de rodar:
aws cloudformation validate-template --template-body file://s3-buckets.yaml 

aws cloudformation create-stack --stack-name s3-buckets-stack --template-body file://s3-buckets.yaml --capabilities CAPABILITY_NAMED_IAM --region us-east-1