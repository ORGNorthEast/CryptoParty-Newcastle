## Install Docker

Update:
```
sudo yum clean all && sudo yum update && sudo yum install open-vm-tools nano
```

Install repo:
```
sudo nano /etc/yum.repos.d/docker.repo
```

Paste in the contents of the `docker.repo` file in this directory.

Install Docker:
```
sudo yum install docker-engine
```

Enable Service:
```
sudo systemctl enable docker.service && sudo systemctl start docker.service
```

Enable Docker service to deploy my site:
```
sudo nano /etc/systemd/system/cccp.service
sudo systemctl daemon-reload
sudo systemctl enable cccp.service && sudo systemctl start cccp.service
```

Automatic security updates:
```
sudo yum install yum-cron
```

Edit the config (see this directory for my edited version):
```
/etc/yum/yum-cron.conf
```

Start and enable the service:
```
sudo systemctl enable yum-cron.service && sudo systemctl start yum-cron.service
```
