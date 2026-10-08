#!/bin/bash
set +x
set -euo pipefail
S="$1"
L="$2"
W="$(mktemp -d)"
echo "$W" > "$RUNNER_TEMP/w"
H="$PWD"
mkdir "$W/p" "$W/s" "$W/o"
gh release download g -p "$M" -D "$W" >/dev/null 2>&1
node d.cjs d "$W/$M" "$W/m.json"
node -e 'for (const p of JSON.parse(require("fs").readFileSync(process.argv[1])).partes) console.log(p)' "$W/m.json" > "$W/lista"
xargs -n 40 sh -c 'a=""; for p in "$@"; do a="$a -p $p"; done; gh release download g $a -D "$0" >/dev/null 2>&1' "$W/p" < "$W/lista"
while read -r p; do
  node "$H/d.cjs" d "$W/p/$p" "$W/x.tgz"
  tar -xzf "$W/x.tgz" -C "$W/s"
  rm -f "$W/p/$p" "$W/x.tgz"
done < "$W/lista"
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
