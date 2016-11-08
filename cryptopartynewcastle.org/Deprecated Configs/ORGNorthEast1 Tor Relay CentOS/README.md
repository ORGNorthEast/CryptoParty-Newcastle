## Install Docker

Update:
```
sudo yum clean all && sudo yum update && sudo yum install epel-release && sudo yum install open-vm-tools nano tor
```

Install Tor config:
```
sudo nano /etc/tor/torrc
```

Configure Tor to start on boot:
```
sudo systemctl enable tor.service
```

Installed Tripwire:
```
sudo yum install tripwire
```

On CentOS, Tripwire's config must be manually installed as so:
```
sudo /usr/sbin/tripwire-setup-keyfiles
```

TRIPWIRE CONFIG HASN'T BEEN PROPERLY SET UP ON THIS MACHINE YET!
