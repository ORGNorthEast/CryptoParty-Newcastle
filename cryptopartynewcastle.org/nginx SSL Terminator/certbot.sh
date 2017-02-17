#!/bin/bash

# NOW DOES NOT RELY ON RUNNING WEBSERVER TO GRAB CERT!

sudo yum install epel-release # We need this as Certbot depends on `python-pip`, which is only available from the EPEL repo

sudo mkdir -p /home/ssl/keys/alexhaydock.co.uk/
sudo mkdir -p /home/ssl/keys/cryptopartynewcastle.org/
sudo mkdir -p /home/ssl/keys/creativecommonscatpictures.com/

if [ -d "$HOME/certbot" ]
then
	cd "$HOME/certbot"
	git pull
else
	git clone https://github.com/certbot/certbot "$HOME/certbot"
	cd "$HOME/certbot"
fi

# Stop nginx
sudo systemctl stop sslterminator.service

# Cert for alexhaydock.co.uk
rm -f -v $HOME/certbot/*.der
rm -f -v $HOME/certbot/*.pem
openssl ecparam -genkey -name secp384r1 | sudo tee /home/ssl/keys/alexhaydock.co.uk/privkey-p384.pem
openssl req -new -sha256 -key /home/ssl/keys/alexhaydock.co.uk/privkey-p384.pem -subj "/CN=alexhaydock.co.uk" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:alexhaydock.co.uk,DNS:www.alexhaydock.co.uk,DNS:test.alexhaydock.co.uk")) -outform der -out csr-p384.der
sudo mv -f -v csr-p384.der /home/ssl/keys/alexhaydock.co.uk/csr-p384.der
sudo rm -f -v /home/ssl/keys/alexhaydock.co.uk/ecdsa-chain.pem
sudo ./certbot-auto certonly --standalone --keep-until-expiring --agree-tos --email alex@alexhaydock.co.uk --csr /home/ssl/keys/alexhaydock.co.uk/csr-p384.der --fullchain-path /home/ssl/keys/alexhaydock.co.uk/ecdsa-chain.pem

# Cert for cryptopartynewcastle.org
rm -f -v $HOME/certbot/*.der
rm -f -v $HOME/certbot/*.pem
openssl ecparam -genkey -name secp384r1 | sudo tee /home/ssl/keys/cryptopartynewcastle.org/privkey-p384.pem
openssl req -new -sha256 -key /home/ssl/keys/cryptopartynewcastle.org/privkey-p384.pem -subj "/CN=cryptopartynewcastle.org" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:cryptopartynewcastle.org,DNS:www.cryptopartynewcastle.org,DNS:forum.cryptopartynewcastle.org")) -outform der -out csr-p384.der
sudo cp -f -v csr-p384.der /home/ssl/keys/cryptopartynewcastle.org/csr-p384.der
sudo rm -f -v /home/ssl/keys/cryptopartynewcastle.org/ecdsa-chain.pem
sudo ./certbot-auto certonly --standalone --keep-until-expiring --agree-tos --email alex@alexhaydock.co.uk --csr /home/ssl/keys/cryptopartynewcastle.org/csr-p384.der --fullchain-path /home/ssl/keys/cryptopartynewcastle.org/ecdsa-chain.pem

# Cert for creativecommonscatpictures.com
rm -f -v $HOME/certbot/*.der
rm -f -v $HOME/certbot/*.pem
openssl ecparam -genkey -name secp384r1 | sudo tee /home/ssl/keys/creativecommonscatpictures.com/privkey-p384.pem
openssl req -new -sha256 -key /home/ssl/keys/creativecommonscatpictures.com/privkey-p384.pem -subj "/CN=creativecommonscatpictures.com" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:creativecommonscatpictures.com,DNS:www.creativecommonscatpictures.com")) -outform der -out csr-p384.der
sudo cp -f -v csr-p384.der /home/ssl/keys/creativecommonscatpictures.com/csr-p384.der
sudo rm -f -v /home/ssl/keys/creativecommonscatpictures.com/ecdsa-chain.pem
sudo ./certbot-auto certonly --standalone --keep-until-expiring --agree-tos --email alex@alexhaydock.co.uk --csr /home/ssl/keys/creativecommonscatpictures.com/csr-p384.der --fullchain-path /home/ssl/keys/creativecommonscatpictures.com/ecdsa-chain.pem --agree-tos

# Key ownership & SELinux contexts (Deprecated now that we're deploying with Docker)
##sudo chown -R nginx:nginx "/home/ssl/keys/"
##sudo chcon -Rv --type=httpd_sys_content_t "/home/ssl/keys/"

# Restart nginx
sudo systemctl start sslterminator.service
