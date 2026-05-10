const qrcode = require("qrcode-terminal");

const url = "https://erik-derived-xbox-quantum.trycloudflare.com";

console.log("\nScan QR:\n");

qrcode.generate(url, { small: true });