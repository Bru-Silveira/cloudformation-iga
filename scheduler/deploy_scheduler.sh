SET AWS_ACCESS_KEY_ID=*******
SET AWS_SECRET_ACCESS_KEY=********
SET AWS_SESSION_TOKEN=********

# validar o template antes de rodar:
aws cloudformation validate-template --template-body file://scheduler/scheduler-all.yml

# deploy
aws cloudformation deploy --stack-name scheduler-all-iga --template-file scheduler/scheduler-all.yml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
