// AES-256-GCM, formato nonce(12) || cifra || tag(16). Chave em base64 na variavel K.
// node d.cjs d <entrada> <saida>   decifra
// node d.cjs e <entrada> <saida>   cifra
const { createCipheriv, createDecipheriv, randomBytes } = require("node:crypto");
const fs = require("node:fs");
const [op, ent, sai] = process.argv.slice(2);
const k = Buffer.from(process.env.K || "", "base64");
if (k.length !== 32) process.exit(2);
const b = fs.readFileSync(ent);
if (op === "d") {
  const d = createDecipheriv("aes-256-gcm", k, b.subarray(0, 12));
  d.setAuthTag(b.subarray(b.length - 16));
  fs.writeFileSync(sai, Buffer.concat([d.update(b.subarray(12, b.length - 16)), d.final()]));
} else {
  const n = randomBytes(12);
  const c = createCipheriv("aes-256-gcm", k, n);
  const corpo = Buffer.concat([c.update(b), c.final()]);
  fs.writeFileSync(sai, Buffer.concat([n, corpo, c.getAuthTag()]));
}
