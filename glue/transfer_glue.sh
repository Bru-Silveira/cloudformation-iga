# Para rodar o comando do .sh no cdm, precisa sempre rodar esse comando primeiro:
SET AWS_ACCESS_KEY_ID=*******
SET AWS_SECRET_ACCESS_KEY=********
SET AWS_SESSION_TOKEN=********

# Se quiser validar o template antes de rodar:
aws cloudformation validate-template --template-body file://trash-glue-setup.yaml 

# depois dele, roda o comando abaixo
aws cloudformation create-stack --stack-name glue-crawler-and-database-stack --template-body file://glue-setup.yaml --capabilities CAPABILITY_NAMED_IAM --region us-east-1