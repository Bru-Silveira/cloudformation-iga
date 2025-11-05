#!/bin/bash
set -e

# Caminhos dos JSONs (ajuste se estiverem em outra pasta)
SOURCE_FILE="../../Cloudformation/buckets_Bulk.json"
DEST_FILE="../../Cloudformation/buckets_IGA.json"

# IDs das contas (apenas informativo)
ACCOUNT_B="412381761647"
ACCOUNT_I="035786426797"

# Número total de buckets (só pra logs)
total=$(jq length $SOURCE_FILE)

echo "🚀 Iniciando sincronização manual de $total buckets da conta $ACCOUNT_B → $ACCOUNT_I..."
echo

for i in $(seq 0 $((total-1))); do
    source_bucket=$(jq -r ".[$i]" $SOURCE_FILE)
    dest_bucket=$(jq -r ".[$i]" $DEST_FILE)

    echo "🔁 Sincronizando: $source_bucket → $dest_bucket"
    
    aws s3 sync s3://$source_bucket s3://$dest_bucket --exact-timestamps --delete --debug

    if [ $? -eq 0 ]; then
        echo "✅ Sincronização concluída para $source_bucket"
    else
        echo "⚠️ Falha na sincronização para $source_bucket"
    fi

    echo
done

echo "🎉 Todas as sincronizações foram processadas!"
