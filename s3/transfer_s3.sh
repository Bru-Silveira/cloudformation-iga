#!/bin/bash
set -euo pipefail

REGION="us-east-1"
DEST_ACCOUNT="035786426797"

# Origem (já existem na BulkdataLab)
declare -A BUCKETS=(
  ["pipefy-dados-sorocaba"]="iga-pipefy-dados-sorocaba-${DEST_ACCOUNT}-${REGION}"
  ["iga-pipefy-pmq"]="iga-pipefy-pmq-${DEST_ACCOUNT}-${REGION}"
  ["iga-pipefy-mulher"]="iga-pipefy-mulher-${DEST_ACCOUNT}-${REGION}"
)

for SRC in "${!BUCKETS[@]}"; do
  DST=${BUCKETS[$SRC]}
  echo "=== Copiando s3://$SRC -> s3://$DST ==="
  # dry-run primeiro (opcional) - comente a linha abaixo para pular o dry-run
  aws s3 sync s3://$SRC s3://$DST --source-region $REGION --region $REGION --exact-timestamps --dryrun

  # execução real (descomente quando validar o dry-run)
  aws s3 sync s3://$SRC s3://$DST --source-region $REGION --region $REGION --exact-timestamps

  echo "✅ $SRC -> $DST concluído"
done
