#!/bin/bash
set -euo pipefail

# Perfis AWS e região
PROFILE_ORIG="origem"
PROFILE_DEST="destino"
REGION="us-east-1"

# IDs das contas
ORIG_ACCOUNT="412381761647"
DEST_ACCOUNT="035786426797"

echo "🔍 Listando todas as task definitions na conta de origem..."
TASK_DEFS=$(aws ecs list-task-definitions \
  --profile "$PROFILE_ORIG" \
  --region "$REGION" \
  --query 'taskDefinitionArns' \
  --output text)

for ARN in $TASK_DEFS; do
  FAMILY=$(echo "$ARN" | awk -F'/' '{print $2}' | awk -F':' '{print $1}')

  # Filtrar apenas tasks com prefixos desejados
  if [[ "$FAMILY" == iga-* || "$FAMILY" == pipefy-* || "$FAMILY" == iga-pipefy-* ]]; then
    echo "⚙️ Copiando Task Definition: $FAMILY"

    # Obter definição completa sem imprimir no terminal
    echo "📦 Baixando definição da task $FAMILY ..."
    aws ecs describe-task-definition \
      --task-definition "$FAMILY" \
      --profile "$PROFILE_ORIG" \
      --region "$REGION" \
      --output json \
      --query 'taskDefinition' > taskdef.json 2>/dev/null

    # Verifica se o arquivo foi criado e tem conteúdo
    if [ ! -s taskdef.json ]; then
      echo "⚠️  Falha ao descrever a task $FAMILY. Pulando..."
      continue
    fi

    # Limpar campos não permitidos
    jq 'del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)' \
      taskdef.json > cleaned.json

    # Substituir ID da conta nas imagens
    sed -i "s/${ORIG_ACCOUNT}/${DEST_ACCOUNT}/g" cleaned.json

    # Registrar na conta destino
    aws ecs register-task-definition \
      --cli-input-json file://cleaned.json \
      --profile "$PROFILE_DEST" \
      --region "$REGION" >/dev/null 2>&1

    echo "✅ Task $FAMILY copiada com sucesso."

    # Limpar arquivos temporários
    rm -f taskdef.json cleaned.json
  else
    echo "⏭️ Pulando $FAMILY (não pertence ao IGA/Pipefy)"
  fi
done

echo "🎉 Todas as task definitions relevantes foram copiadas!"
