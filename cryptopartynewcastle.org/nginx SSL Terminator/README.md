This SSL terminator is based on the Nginx webserver running as a reverse proxy.

It is hosted inside a Docker container, running on CentOS 7.

## Update VM & Install VMware Tools
```
sudo yum clean all && sudo yum upgrade && sudo yum install open-vm-tools
```

## SELinux
Check that SELinux is running with:
```
getenforce
```

If it displays anything other than `Enforcing`, turn it on with:
```
sudo setenforce 1
```

Run the following commands to carry out a deep inspection of the status of the current SELinux booleans. Turn on the ones that need to be on, and off the ones that need to be off:
```
getsebool -a | less
getsebool -a | grep off
getsebool -a | grep on
```

## Install Docker
Remove any version of Docker installed from the CentOS repos (their version is way too old):
```
sudo yum remove docker && sudo yum autoremove
```

Install `yum-utils` to manage repos:
```
sudo yum install yum-utils
```

Add the Docker repo:
```
sudo yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo
```

Update package cache and install Docker:
```
sudo yum makecache fast && sudo yum install docker-engine
```

## Deploying nginx from Docker Hub
For info on this deployment, see [the README.md file in this repo](https://github.com/ajhaydock/Nginx-PageSpeed-OpenSSLBeta).
