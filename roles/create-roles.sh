# Para rodar o comando do .sh no cdm, precisa sempre rodar esse comando primeiro:
SET AWS_ACCESS_KEY_ID=*******
SET AWS_SECRET_ACCESS_KEY=********
SET AWS_SESSION_TOKEN=********

# depois dele, roda o comando abaixo
aws cloudformation create-stack --stack-name base-roles-stack --template-body file://create-roles.yaml --capabilities CAPABILITY_NAMED_IAM 
