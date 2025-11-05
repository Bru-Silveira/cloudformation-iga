#!/bin/bash
# === CONFIGURAÇÕES ===
REGION="us-east-1"
ROLE_ARN="arn:aws:iam::412381761647:role/s3-cross-account-replication-role"   # <- conta B (origem)
DEST_ACCOUNT_ID="035786426797"                                # <- conta I (destino)

# === CAMINHOS PARA OS JSONs ===
SOURCE_FILE="../../Cloudformation/buckets_Bulk.json"
DEST_FILE="../../Cloudformation/buckets_IGA.json"

# === VERIFICAÇÃO DE DEPENDÊNCIAS ===
if ! command -v jq &> /dev/null; then
  echo "❌ 'jq' não encontrado. Instale com: sudo apt install jq"
  exit 1
fi

# === LER LISTAS ===
SOURCE_BUCKETS=($(jq -r '.[]' "$SOURCE_FILE"))
DEST_BUCKETS=($(jq -r '.[]' "$DEST_FILE"))

# === VERIFICAR SE AS LISTAS TÊM O MESMO TAMANHO ===
if [ "${#SOURCE_BUCKETS[@]}" -ne "${#DEST_BUCKETS[@]}" ]; then
  echo "❌ As listas de buckets têm tamanhos diferentes!"
  echo "Origem: ${#SOURCE_BUCKETS[@]} / Destino: ${#DEST_BUCKETS[@]}"
  exit 1
fi

# === LOOP DE REPLICAÇÃO ===
for i in "${!SOURCE_BUCKETS[@]}"; do
  SRC="${SOURCE_BUCKETS[$i]}"
  DST="${DEST_BUCKETS[$i]}"
  
  echo "🔁 Configurando replicação: $SRC → $DST"
  
  aws s3api put-bucket-replication \
    --bucket "$SRC" \
    --replication-configuration "{
      \"Role\": \"$ROLE_ARN\",
      \"Rules\": [
        {
          \"ID\": \"ReplicateTo-$DST\",
          \"Status\": \"Enabled\",
          \"Priority\": 1,
          \"DeleteMarkerReplication\": {\"Status\": \"Enabled\"},
          \"Filter\": {\"Prefix\": \"\"},
          \"Destination\": {
            \"Bucket\": \"arn:aws:s3:::$DST\",
            \"StorageClass\": \"STANDARD\"
          }
        }
      ]
    }" \
    --region "$REGION"

  if [ $? -eq 0 ]; then
    echo "✅ Replicação configurada com sucesso para $SRC"
  else
    echo "⚠️ Falha ao configurar replicação para $SRC"
  fi
done

echo "🎉 Todas as replicações foram processadas."
