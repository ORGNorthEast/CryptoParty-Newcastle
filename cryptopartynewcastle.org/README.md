### Server Config Transparency Notes
This is the server config for https://cryptopartynewcastle.org/ (also available at http://nclcrypto2bfuejv.onion/)

Debian Jessie installed as host OS.

Created `party` user to manage the host:
```
adduser party
```

Added `party` user to sudoers list:
```
usermod -a -G sudo party
```

Tor installed to provide updates over onion service (see `/etc/apt/sources.list`):
```
sudo apt install apt-transport-tor && sudo systemctl start tor && sudo systemctl enable tor
```

Added TorProject repo signing keys with:
```
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
```

Configured NTP due to virtual machine clock drift causing Tor to not work (see `/etc/ntp.conf`):
```
apt install ntp && sudo systemctl start ntp && sudo systemctl enable ntp
```

Created `party` user to manage the host:
```
useradd party -s /bin/bash
```

Generated Ed25519 host key with:
```
sudo rm -v /etc/ssh/ssh_host_*key*
sudo ssh-keygen -t ed25519 -P "" -f "/etc/ssh/ssh_host_ed25519_key"
```

Set up Ed25519 keyfile for client OpenSSH authentication. Also runs on non-standard port (see `/etc/ssh/sshd_config`)

Nginx [compiled against BoringSSL](https://github.com/ajhaydock/BoringNginx) to provide X25519 support [for supported browsers](https://www.chromestatus.com/feature/5682529109540864).

Generated LetsEncrypt keys using process noted in LetsEncrypt dir README.md here on this repo.
