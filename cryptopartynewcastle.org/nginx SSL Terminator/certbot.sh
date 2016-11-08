#!/bin/bash

AHWEBROOT="/usr/share/nginx/html"
CPARTYWEBROOT="/usr/share/nginx/html"

sudo yum install epel-release # We need this as Certbot depends on `python-pip`, which is only available from the EPEL repo

sudo mkdir -p /usr/share/nginx/keys/alexhaydock.co.uk/
sudo mkdir -p /usr/share/nginx/keys/cryptopartynewcastle.org/

if [ -d "$HOME/certbot" ]
then
	cd "$HOME/certbot"
	git pull
else
	git clone https://github.com/certbot/certbot "$HOME/certbot"
	cd "$HOME/certbot"
fi


# Remove old certs
rm -v $HOME/certbot/*.pem

# Cert for alexhaydock.co.uk
openssl ecparam -genkey -name secp384r1 | sudo tee /usr/share/nginx/keys/alexhaydock.co.uk/privkey-p384.pem

openssl req -new -sha256 -key /usr/share/nginx/keys/alexhaydock.co.uk/privkey-p384.pem -subj "/CN=alexhaydock.co.uk" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:alexhaydock.co.uk,DNS:www.alexhaydock.co.uk,DNS:test.alexhaydock.co.uk")) -outform der -out csr-p384.der

sudo mv -f -v csr-p384.der /usr/share/nginx/keys/alexhaydock.co.uk/csr-p384.der


cd "$HOME/certbot"
sudo ./certbot-auto certonly --webroot --webroot-path $AHWEBROOT --email alex@alexhaydock.co.uk --csr /usr/share/nginx/keys/alexhaydock.co.uk/csr-p384.der --renew-by-default --agree-tos

sudo mv -f -v $HOME/certbot/0001_chain.pem /usr/share/nginx/keys/alexhaydock.co.uk/ecdsa-chain.pem


# Cert for cryptopartynewcastle.org
openssl ecparam -genkey -name secp384r1 | sudo tee /usr/share/nginx/keys/cryptopartynewcastle.org/privkey-p384.pem

openssl req -new -sha256 -key /usr/share/nginx/keys/cryptopartynewcastle.org/privkey-p384.pem -subj "/CN=cryptopartynewcastle.org" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:cryptopartynewcastle.org,DNS:www.cryptopartynewcastle.org,DNS:forum.cryptopartynewcastle.org")) -outform der -out csr-p384.der

sudo cp -f -v csr-p384.der /usr/share/nginx/keys/cryptopartynewcastle.org/csr-p384.der

sudo ./certbot-auto certonly --webroot --webroot-path $CPARTYWEBROOT --email alex@alexhaydock.co.uk --csr /usr/share/nginx/keys/cryptopartynewcastle.org/csr-p384.der --renew-by-default --agree-tos

sudo mv -f -v $HOME/certbot/0001_chain.pem /usr/share/nginx/keys/cryptopartynewcastle.org/ecdsa-chain.pem


# Key ownership & SELinux contexts
sudo chown -R nginx:nginx "/usr/share/nginx/keys/"
sudo chcon -Rv --type=httpd_sys_content_t "/usr/share/nginx/keys/"
