### LetsEncrypt ECDSA Certificate Generation Process

#### Main Process
Create a directory to hold our keys:
```
sudo mkdir -p /usr/share/nginx/keys/ && chown -R www-data:www-data /usr/share/nginx/keys/
```

Create a directory for the verification process (Ensure `nginx.conf` knows how to deal with this):
```
sudo mkdir -p /usr/share/nginx/letsencrypt/ && chown -R www-data:www-data /usr/share/nginx/letsencrypt/
```

Clone LetsEncrypt client ready to request our certificate:
```
git clone https://github.com/certbot/certbot "$HOME/certbot" && cd "$HOME/certbot"
```

Generate the ECC private key we will use for our cert:
```
openssl ecparam -genkey -name secp384r1 | sudo tee /usr/share/nginx/keys/privkey-p384.pem
```

Generate the CSR (Certificate Signing Request) using the private key. It is important to ensure you also include the `www.` subdomain in this line, as otherwise Google will not incorporate your domain into their [HSTS preload list](https://hstspreload.appspot.com):
```
openssl req -new -sha256 -key /usr/share/nginx/keys/privkey-p384.pem -subj "/CN=cryptopartynewcastle.org" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:cryptopartynewcastle.org,DNS:www.cryptopartynewcastle.org,DNS:forum.cryptopartynewcastle.org")) -outform der -out csr-p384.der && sudo cp -f -v csr-p384.der /usr/share/nginx/keys/csr-p384.der
```

Feed the CSR into LetsEncrypt client so it spits out a full (public) ECDSA leaf certificate for us:
```
sudo ./certbot-auto certonly --webroot --webroot-path /usr/share/nginx/letsencrypt --email admin@cryptopartynewcastle.org --csr /usr/share/nginx/keys/csr-p384.der --renew-by-default --agree-tos
```

If you are running a Grsec kernel, the above step will probably have failed. Please see the bottom of this document for some extra instructions to complete at this point, and then try the above command again.

Move the public leaf cert to our keys directory (Note that your generated certificate might be under a different number if you have generated certificates in the past):
```
sudo mv -f -v $HOME/certbot/0001_chain.pem /usr/share/nginx/keys/ecdsa-chain.pem
```

Now, we need to add the following lines to our `nginx.conf`, within our SSL server block, so that Nginx knows where to find our public certificate and corresponding private key:
```nginx
		ssl_certificate		/usr/share/nginx/keys/ecdsa-chain.pem;
		ssl_certificate_key	/usr/share/nginx/keys/privkey-p384.pem;
```


#### Notes for Grsec/PaX kernels
If you are running a [Grsecurity-patched](https://grsecurity.net/) kernel, then `MPROTECT` will need to be disabled on some of the binaries pulled in by the LetsEncrypt client.

Ensure that you have the `attr` package installed, and then run the following commands:
```
sudo setfattr -n user.pax.flags -v m $HOME/.local/share/letsencrypt/bin/letsencrypt
sudo setfattr -n user.pax.flags -v m $HOME/.local/share/letsencrypt/bin/pip
sudo setfattr -n user.pax.flags -v m $HOME/.local/share/letsencrypt/bin/pip2
sudo setfattr -n user.pax.flags -v m $HOME/.local/share/letsencrypt/bin/pip2.7
sudo setfattr -n user.pax.flags -v m $HOME/.local/share/letsencrypt/bin/python2.7
sudo setfattr -n user.pax.flags -v m /root/.local/share/letsencrypt/bin/letsencrypt
sudo setfattr -n user.pax.flags -v m /root/.local/share/letsencrypt/bin/pip
sudo setfattr -n user.pax.flags -v m /root/.local/share/letsencrypt/bin/pip2
sudo setfattr -n user.pax.flags -v m /root/.local/share/letsencrypt/bin/pip2.7
sudo setfattr -n user.pax.flags -v m /root/.local/share/letsencrypt/bin/python2.7
```
