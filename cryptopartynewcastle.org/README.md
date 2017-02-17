# cryptopartynewcastle.org
This is where the config lives for the CryptoParty [main site](https://cryptopartynewcastle.org/) and [forum](https://forum.cryptopartynewcastle.org/). It serves a dual-purpose here - a useful central repository of configuration for easy deployment/migration, and as an effort in transparency. Please feel free to browse through this section and learn from it, or suggest improvements.

To suggest improvements or point out something we're doing wrong, you should probably contact `alex@alexhaydock.co.uk`.

## Useful Security Auditing Tools
* [Mozilla Observatory](https://observatory.mozilla.org/analyze.html?host=forum.cryptopartynewcastle.org)
* [SSL Labs](https://www.ssllabs.com/ssltest/analyze?d=forum.cryptopartynewcastle.org)
* [CryptCheck](https://tls.imirhil.fr/https/forum.cryptopartynewcastle.org)
* [SecurityHeaders.io](https://securityheaders.io/?followRedirects=on&hide=on&q=forum.cryptopartynewcastle.org)
* [HSTS Preload Tool](https://hstspreload.org/?domain=cryptopartynewcastle.org)
* [Google CSP Evaluator](https://csp-evaluator.withgoogle.com/)
* [ValiMail SPF/DMARC Check](https://www.valimail.com/dmarc/domain-checker/cryptopartynewcastle.org)
* [DNS Inspect](http://www.dnsinspect.com/cryptopartynewcastle.org)
* [ReportURI](https://report-uri.io/)

## Security Checklist
#### Host
* [x] SELinux `Enforcing` (CentOS Default)
* [ ] grsecurity/PaX Kernel (WIP)

#### HTTPS
* [x] HTTPS enforced
* [x] HSTS enabled with long expiry time (2 years)
* [x] HSTS preloaded (check with [HSTS Preload Tool](https://hstspreload.org/?domain=cryptopartynewcastle.org))
* [ ] ~~Included in HTTPS Everywhere ruleset~~ (Not necessary when site is fully HSTS preloaded)
* [x] 301 to redirect all attempted HTTP access to the HTTPS URL
* [x] ECDSA cert (384-bit one from LetsEncrypt)
* [x] Only support ECDH key exchange (all non-ECC DH exchange methods disabled)
* [x] X25519 ECDH support enabled (nginx SSL terminator [built with latest OpenSSL Beta](https://github.com/ajhaydock/Nginx-PageSpeed-OpenSSLBeta) to enable this)
* [ ] Disabled all [unsafe NIST ECDH curves](https://safecurves.cr.yp.to/) (NIST P-384 sadly still enabled due to [lack of X25519 in Firefox](https://www.chromestatus.com/feature/5682529109540864))
* [x] Only support TLS v1.2+
* [x] HPKP enabled with LetsEncrypt intermediary cert pinned (leaf cert not pinned, as LE certs have a short 90-day life)
* [x] HPKP violation reports enabled via [ReportURI](https://report-uri.io/)

#### Client-Side
* [x] Strong `Content-Security-Policy` header (check with Google's [CSP Evaluator](https://csp-evaluator.withgoogle.com/))
* [x] CSP violation reports enabled via [ReportURI](https://report-uri.io/)
* [x] All cookies set to use the `Secure` flag (in Discourse this is achieved with the use of the "Force HTTPS" option)
* [x] Strong `Referrer-Policy` header

#### Mail
* [x] SPF restricted to Mailgun hosts (check with [ValiMail](https://www.valimail.com/dmarc/domain-checker/cryptopartynewcastle.org))
* [x] DKIM
* [x] DMARC configured to quarantine spoofed mail (check with [ValiMail](https://www.valimail.com/dmarc/domain-checker/cryptopartynewcastle.org))
