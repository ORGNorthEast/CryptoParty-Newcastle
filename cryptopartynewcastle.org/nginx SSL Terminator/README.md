## Update & VMware Tools
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

## Building nginx
Build with my CentOS buildscript for [BoringNginx](https://github.com/ajhaydock/BoringNginx).
