#### base64 转码|解码

```js
import CryptoJS from 'crypto-js';

function encode (words) {
	const str = CryptoJS.enc.Utf8.parse(words);
  const base64 = CryptoJS.enc.Base64.stringify(str);
  return base64;
}
function decode (base64) {
	const words  = CryptoJS.enc.Base64.parse(base64);
	return words.toString(CryptoJS.enc.Utf8);
}

let base64 = encode('hello');
let word = decode(base64);
```