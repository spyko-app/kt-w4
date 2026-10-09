#!/bin/bash
set +x
set -euo pipefail
E=0
trap 'echo "falhou etapa $E"' ERR
S="$1"
L="$2"
W="$(mktemp -d)"
echo "$W" > "$RUNNER_TEMP/w"
H="$PWD"
mkdir "$W/p" "$W/s" "$W/o"
E=1
U="https://github.com/$GITHUB_REPOSITORY/releases/download/g"
curl -fsSL --retry 5 --retry-all-errors -o "$W/$M" "$U/$M"
E=2
node d.cjs d "$W/$M" "$W/m.json"
node -e 'for (const p of JSON.parse(require("fs").readFileSync(process.argv[1])).partes) console.log(p)' "$W/m.json" > "$W/lista"
E=3
xargs -P 8 -I{} curl -fsSL --retry 5 --retry-all-errors -o "$W/p/{}" "$U/{}" < "$W/lista"
E=4
while read -r p; do
  node "$H/d.cjs" d "$W/p/$p" "$W/x.tgz"
  tar -xzf "$W/x.tgz" -C "$W/s"
  rm -f "$W/p/$p" "$W/x.tgz"
done < "$W/lista"
E=5
s=$SECONDS
r=falhou
if (
  cd "$W/s"
  git init -q
  git add -A -f
  git -c user.name=n -c user.email=n@n commit -qm n
  K= GH_TOKEN= npm ci --no-audit --no-fund
  K= GH_TOKEN= node scripts/nuvem/lote.mjs "$S" "$L" "$W/m.json" "$W/o"
) >"$W/o/log.txt" 2>&1; then r=ok; fi
echo "$r $((SECONDS - s))s"
node -e '
const fs=require("fs"),z=require("zlib"),p=require("path");const o=process.argv[1];
let r;try{r=JSON.parse(fs.readFileSync(p.join(o,"resultado.json")))}catch{r={erro:fs.readFileSync(p.join(o,"log.txt"),"utf8").slice(-20000)}}
fs.writeFileSync(p.join(o,"r.gz"),z.gzipSync(JSON.stringify(r)))' "$W/o"
node d.cjs e "$W/o/r.gz" "$H/r.bin"
