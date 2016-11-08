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
sudo nano /etc/systemd/system/alexhaydock.service
sudo systemctl daemon-reload
sudo systemctl enable alexhaydock.service && sudo systemctl start alexhaydock.service
```
