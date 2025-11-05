# 1. logar com a conta da Bulk 

# 2. validar template
aws cloudformation validate-template --template-body file://s3-replication-source.yaml

# 3. policies dos buckets da bulk
aws cloudformation create-stack --stack-name s3-replication-source --template-body file://s3-replication-source.yaml --region us-east-1

# 4. logar no IGA e rodar abaixo as policies dos buckets do IGA
aws cloudformation create-stack --stack-name s3-replication-destination-policies --template-body file://s3-destination-policies.yaml --region us-east-1

# 5. logar na Bulk e rodar abaixo (criação da replication role na bulk)
aws cloudformation create-stack --stack-name s3-replication-role --template-body file://s3-replication-role.yaml --capabilities CAPABILITY_NAMED_IAM --region us-east-1

# logar na conta da Bulk no WSL (Ubuntu)

# 6. rodar o script pra sincronizar objetos passados do s3:
chmod +x sync_all_buckets.sh
./sync_all_buckets.sh

# 7. rodar os comandos abaixo:
chmod +x replicate_all_buckets.sh 
./replicate_all_buckets.sh 

#################################
# extra: ativar versionamento em todos os buckets de uma vez se não tiver ativado ainda
# rodar no wsl logado na Bulk:
for bucket in $(jq -r '.[]' ../../Cloudformation/buckets_Bulk.json); do
  echo "🟢 Habilitando versionamento em $bucket ..."
  aws s3api put-bucket-versioning --bucket "$bucket" --versioning-configuration Status=Enabled --region us-east-1
done

# rodar no wsl logado no IGA:
for bucket in $(jq -r '.[]' ../../Cloudformation/buckets_IGA.json); do
  echo "🟢 Habilitando versionamento em $bucket ..."
  aws s3api put-bucket-versioning --bucket "$bucket" --versioning-configuration Status=Enabled --region us-east-1
done