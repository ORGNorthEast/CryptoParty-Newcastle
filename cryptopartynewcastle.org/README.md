### Server Config Transparency Notes
This is the server installation log for https://cryptopartynewcastle.org/ (also available at http://nclcrypto2bfuejv.onion/)

Debian 8 (Jessie) installed as host OS.


#### OS Installation
Perform first update as root and install sudo:
```
su -c "apt-get clean && apt-get update && apt-get install sudo"
```

Added `cryptoparty` user to sudoers list:
```
su -c "usermod -a -G sudo cryptoparty"
```

Generated Ed25519 host key with:
```
sudo rm -v /etc/ssh/ssh_host_*key*
sudo ssh-keygen -t ed25519 -P "" -f "/etc/ssh/ssh_host_ed25519_key"
```

Configured `sshd_config` as per the example in this repo:
```
sudo nano /etc/ssh/sshd_config
```

Set up Ed25519 keyfile for client OpenSSH authentication. Also runs on non-standard port (see `/etc/ssh/sshd_config`)


Tor installed to provide updates over onion service (see `/etc/apt/sources.list`):
```
sudo apt install apt-transport-tor tor && sudo systemctl start tor && sudo systemctl enable tor
```

Added TorProject repo signing keys with:
```
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
```

Configured `sources.list` as per the example in this repo:
```
sudo nano /etc/apt/sources.list
```

Ensured everything was up-to-date:
```
sudo apt-get clean && sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
```

Configured NTP due to virtual machine clock drift causing Tor to not work (Deployed `/etc/ntp.conf` as per this repo's example):
```
sudo apt-get install ntp && sudo systemctl start ntp && sudo systemctl enable ntp
```


#### Discourse Forum Installation
Signed up for [Mailgun](https://mailgun.com/signup) mail relay account. Free package allows 10k emails per month to be relayed, and these mailer credentials are needed before installation can be completed. Configured DNS records as suggested by Mailgun. *Verification can take several hours, and you will not be able to install Discourse before this has completed and mails can be sent.*

Installed Discourse as per the instructions [on the Discourse GitHub docs page](https://github.com/discourse/discourse/blob/master/docs/INSTALL-cloud.md).

The first step in the Discourse tutorial installs Docker and the Docker repo on the system. I ran the following command to configure Docker to always update via Tor:
```
sudo perl -pi -e 's,https://,tor://,' /etc/apt/sources.list.d/docker.list
```

At the end of the configuration wizard, Discourse produces an output that looks like the following:
```
Does this look right?

Hostname      : forum.cryptopartynewcastle.org
Email         : admin@cryptopartynewcastle.org
SMTP address  : smtp.mailgun.org
SMTP port     : 587
SMTP username : postmaster@cryptopartynewcastle.org
SMTP password : [HIDDEN, OBVIOUSLY]
```

Created routes on the [Mailgun page](https://mailgun.com/app/routes) to forward mail going to `admin@cryptopartynewcastle.org` to an actual mail address (we will need this otherwise we won't be able to verify the mail address for our admin account.


#### nginx Reverse-Proxy Installation
Rather than allowing Discourse to act as its own webserver, we want to be able to use Nginx as a reverse-proxy to allow us to have better control over the crypto and certificates used, and the server headers set by the site. I based this section on a great guide by DigitalOcean, [which can be found here](https://www.digitalocean.com/community/tutorials/how-to-install-discourse-behind-nginx-on-ubuntu-14-04).

Open the Discourse config for editing (do this before attempting to install nginx otherwise the nginx post-install scripts will fail as Discourse will be bound to `:80`):
```
sudo nano /var/discourse/containers/app.yml
```

And change the first port on each line in the `expose` section, like so:
```
## which TCP/IP ports should this container expose?
## If you want Discourse to share a port with another webserver like Apache or nginx,
## see https://meta.discourse.org/t/17247 for details
expose:
  - "8090:80"   # http
  - "8091:443" # https
```

The above example will listen for HTTP connections on port `8090` on the host, and redirect it to port `80` in the Docker container.

Rebuild and rebuild Discourse with:
```
cd /var/discourse && sudo ./launcher rebuild app
```

Install nginx:
```
sudo apt-get install nginx
```

Ensure the `proxy_pass` and `proxy_redirect` directives in the `nginx.conf` file point to our new HTTP port (`8090`). (See the `/etc/nginx/nginx.conf` example in this repo)

Added `cryptoparty` user to `www-data` group, to make it easier to deal with nginx directories:
```
sudo usermod -a -G www-data cryptoparty
```


#### Install UFW Firewall
Install `ufw`:
```
sudo apt-get install ufw
```

One-line config to set all the options I use with `ufw`:
```
sudo ufw reset && sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw allow 80/tcp && sudo ufw allow 443/tcp && sudo ufw allow 45498/tcp && sudo ufw enable
```

You can check the firewall status with the following command:
```
sudo ufw status
```

It's probably advisable to try and open a new SSH connection to the server in a new terminal window before closing the original session. If your connection is rejected, this means you have probably misconfigured the firewall, but the original SSH session will still be active so you can fix the problem, and you will not have locked yourself out.


#### Install fail2ban
Install `fail2ban`:
```
sudo apt-get install fail2ban
```

Enable it:
```
sudo systemctl start fail2ban.service && sudo systemctl enable fail2ban.service
```


#### Enable AppArmor
Install AppArmor:
```
sudo apt-get install apparmor apparmor-profiles apparmor-profiles-extra apparmor-utils
```

Add AppArmor support to the GRUB config:
```
sudo perl -pi -e 's,GRUB_CMDLINE_LINUX="(.*)"$,GRUB_CMDLINE_LINUX="$1 apparmor=1 security=apparmor",' /etc/default/grub
```

Refresh GRUB and Kernel initramfs:
```
sudo update-grub && sudo update-initramfs -u -k all
```


#### HTTPS
Finally, LetsEncrypt keys were generated using the process noted in LetsEncrypt dir README.md here on this repo.
