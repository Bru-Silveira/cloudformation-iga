#!/usr/bin/env bash
set -euo pipefail

# ==============================================
# CONFIGURAÇÕES
# ==============================================

# Perfis AWS conforme ~/.aws/credentials
PROFILE_ORIG="origem"
PROFILE_DEST="destino"

# Região
REGION="us-east-1"

# IDs das contas
ORIG_ACCOUNT="412381761647"
DEST_ACCOUNT="035786426797"

# Lista de repositórios a copiar
REPOS=(
"iga-boxe-automacao-sheets"
"iga-brasilandia-automacao-sheets"
"iga-ept-alongamento-automacao-sheets"
"iga-ept-atletismo-sheets"
"iga-ept-basquete-ginasio-esportes-automacao-sheets"
"iga-ept-boxe-chines-sheets"
"iga-ept-capoeira-sheets"
"iga-ept-corrida-de-rua-sheets"
"iga-ept-futebol-de-campo-sheets"
"iga-ept-futsal-bairro-padre-eterno-automacao-sheets"
"iga-ept-futsal-ginasio-esportes-automacao-sheets"
"iga-ept-ginastica-ginasio-esportes-automacao-sheets"
"iga-ept-hidroginastica-automacao-sheets"
"iga-ept-hidroginastica-sheets"
"iga-ept-karate-sheets"
"iga-ept-ritmos-automacao-sheets"
"iga-ept-volei-ginasio-esportes-automacao-sheets"
"iga-guaratingueta-alcina-soares-automacao-sheets"
"iga-guaratingueta-ana-fausta-automacao-sheets"
"iga-guaratingueta-maria-aparecida-automacao-sheets"
"iga-guaratingueta-maria-julia-automacao-sheets"
"iga-mulher-periferia-automacao-sheets"
"iga-pipefy-alongamento"
"iga-pipefy-boxe"
"iga-pipefy-brasilandia"
"iga-pipefy-ept-alongamento"
"iga-pipefy-ept-atletismo"
"iga-pipefy-ept-basquete-ginasio-esportes"
"iga-pipefy-ept-boxe-chines"
"iga-pipefy-ept-capoeira"
"iga-pipefy-ept-corrida-de-rua"
"iga-pipefy-ept-futebol-de-campo"
"iga-pipefy-ept-futsal-bairro-padre-eterno"
"iga-pipefy-ept-futsal-ginasio-esportes"
"iga-pipefy-ept-ginastica-ginasio-esportes"
"iga-pipefy-ept-hidroginastica"
"iga-pipefy-ept-karate"
"iga-pipefy-ept-ritmos"
"iga-pipefy-ept-volei-ginasio-esportes"
"iga-pipefy-escola-sorocaba"
"iga-pipefy-guaratingueta-alcina-soares"
"iga-pipefy-guaratingueta-ana-fausta"
"iga-pipefy-guaratingueta-maria-aparecida"
"iga-pipefy-guaratingueta-maria-julia"
"iga-pipefy-hidroginastica"
"iga-pipefy-mulher-periferia"
"iga-pipefy-pmq-eventos"
"iga-pipefy-pmq-fotografia"
"iga-pipefy-pmq-midias"
"iga-pmq-eventos-automacao-sheets"
"iga-pmq-fotografia-automacao-sheets"
"iga-pmq-midias-automacao-sheets"
"iga-sorocaba-automacao-sheets"
"iga/alunos"
)

# ==============================================
# LOGIN NOS REGISTRIES
# ==============================================
echo "🔐 Fazendo login no ECR origem..."
aws ecr get-login-password --region "$REGION" --profile "$PROFILE_ORIG" \
| docker login --username AWS --password-stdin "$ORIG_ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

echo "🔐 Fazendo login no ECR destino..."
aws ecr get-login-password --region "$REGION" --profile "$PROFILE_DEST" \
| docker login --username AWS --password-stdin "$DEST_ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

# ==============================================
# LOOP PRINCIPAL
# ==============================================
for repo in "${REPOS[@]}"; do
  echo "==============================="
  echo "🚀 Copiando repositório: $repo"
  echo "==============================="

  # Obter as tags existentes na origem
  TAGS=$(aws ecr list-images \
    --repository-name "$repo" \
    --region "$REGION" \
    --profile "$PROFILE_ORIG" \
    --query 'imageIds[*].imageTag' \
    --output text || true)

  if [ -z "$TAGS" ]; then
    echo "⚠️  Nenhuma imagem encontrada em $repo, pulando..."
    continue
  fi

  for TAG in $TAGS; do
    if [ -z "$TAG" ] || [ "$TAG" = "<none>" ]; then
      echo "⏩ Ignorando imagem sem tag em $repo"
      continue
    fi

    SRC="${ORIG_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${repo}:${TAG}"
    DST="${DEST_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${repo}:${TAG}"

    echo "⬇️  Pull: $SRC"
    docker pull "$SRC" || { echo "❌ Falha no pull de $SRC"; continue; }

    echo "🏷️  Tag: $DST"
    docker tag "$SRC" "$DST"

    echo "⬆️  Push: $DST"
    docker push "$DST" || { echo "❌ Falha no push de $DST"; continue; }

    echo "✅ Copiado: $repo:$TAG"
  done

done

echo "🎉 Transferência concluída com sucesso!"
