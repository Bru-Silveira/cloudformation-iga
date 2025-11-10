SET AWS_ACCESS_KEY_ID=*******
SET AWS_SECRET_ACCESS_KEY=********
SET AWS_SESSION_TOKEN=********

# validar o template antes de rodar:
aws cloudformation validate-template --template-body file://cloudwatch/log-groups-iga.yaml

# deploy
aws cloudformation deploy --stack-name clone-log-groups-iga --template-file cloudwatch/log-groups-iga.yaml
