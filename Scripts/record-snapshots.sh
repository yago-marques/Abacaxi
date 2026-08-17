#!/usr/bin/env bash
# Grava as referências de snapshot do DesignSystem no ambiente canônico (CI)
# e as commita na branch atual.
#
# Fluxo: empurra o HEAD atual para uma branch record/* (que dispara o
# snapshot.yml em modo record=all), espera o run terminar, baixa o artifact
# com as __Snapshots__/, extrai na raiz do repo e commita.
#
# Requisitos: gh autenticado (gh auth status) e working tree limpa.
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

if ! git diff --quiet HEAD; then
  echo "erro: working tree suja — commite ou faça stash antes de gravar." >&2
  exit 1
fi

branch=$(git branch --show-current)
record_branch="record/${branch}"

echo "==> Empurrando HEAD para ${record_branch} (dispara o record na CI)"
git push -f origin "HEAD:${record_branch}"

echo "==> Aguardando o run do snapshot.yml aparecer..."
run_id=""
for _ in $(seq 1 30); do
  run_id=$(gh run list --workflow snapshot.yml --branch "$record_branch" \
    --limit 1 --json databaseId,headSha \
    --jq ".[] | select(.headSha == \"$(git rev-parse HEAD)\") | .databaseId" || true)
  [ -n "$run_id" ] && break
  sleep 5
done
if [ -z "$run_id" ]; then
  echo "erro: run não apareceu; verifique em Actions → Snapshot Tests." >&2
  exit 1
fi

echo "==> Acompanhando o run ${run_id} (asserts falham por design em modo record)"
gh run watch "$run_id" --exit-status || true

echo "==> Baixando o artifact de referências"
tmp_dir=$(mktemp -d)
gh run download "$run_id" --name ds-snapshot-references --dir "$tmp_dir"
tar -xzf "$tmp_dir/ds-snapshot-references.tgz" -C "$repo_root"
rm -rf "$tmp_dir"

echo "==> Limpando a branch de record remota"
git push origin --delete "$record_branch" || true

git add 'Modules/DesignSystem/Tests'
if git diff --cached --quiet; then
  echo "Nenhuma referência nova ou alterada — nada a commitar."
  exit 0
fi

git commit -m "test: record DS snapshot references (CI canonical environment)"
echo "==> Referências commitadas. Faça push para atualizar o PR."
