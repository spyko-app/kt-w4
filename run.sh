#!/bin/bash
set +x
set -euo pipefail
W="$(mktemp -d)"
echo "$W" > "$RUNNER_TEMP/w"
H="$PWD"
swiftc -O -o "$W/c" c.swift >/dev/null 2>&1
gh release download d -p d.bin -D "$W" >/dev/null 2>&1
"$W/c" d "$W/d.bin" "$W/i.tgz"
mkdir "$W/s" "$W/o"
tar -xzf "$W/i.tgz" -C "$W/s"
rm "$W/i.tgz"
s=$SECONDS
if (cd "$W/s" && ./go.sh "$W/o") >"$W/o/log.txt" 2>&1; then r=ok; else r=falhou; fi
echo "$r $((SECONDS - s))s"
tar -czf "$W/r.tgz" -C "$W/o" .
"$W/c" e "$W/r.tgz" "$H/r.bin"
[ "$r" = ok ]
