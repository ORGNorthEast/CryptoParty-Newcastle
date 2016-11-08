## Notes
* Please note that to complete this guide you will need to create a VM with a relatively large filesystem (compiling all this code from ports can take up a lot of space). A 32GB disk should do it.
* You might also want to create your VM with plenty of cores available when you're doing the initial installation and building packages (will speed things up a lot). You can then return to just 1 vCPU afterwards if you prefer.


##Initial Installation & Update
Install FreeBSD. Most of the defaults are probably fine, but I have included some notes below from my installation.

Pick UFS over ZFS for the filesystem. There will be no real benefit from ZFS for a system like this, and it is much heavier on resources.

Install system sources, and enable `ntpd` during install.

Enable all hardening options during install.

Create user `relay` during installation.

Log in as `root` via the **console** (`root` is locked out of SSH, and we can't do anything as the `relay` user until we set up `sudo`).

Update system:
```
freebsd-update fetch install
```

Reboot, and then log back into the `root` account via the console again.


## Downloading the Ports Tree
Perform the first download the ports tree (we use this command on a new system where `/usr/ports` is going to be blank):
```
portsnap fetch extract
```


## Maintenance as Non-Root User
To maintain the system via SSH, we should really be using the non-root user we created during the setup, and the `sudo` command.

First, we need to install `sudo` from our newly synced ports tree:
```
cd /usr/ports/security/sudo/
make install clean
```

Let's install `nano` to make editing config files etc a bit easier:
```
cd /usr/ports/editors/nano/
make install clean
```

Now we can add our user `relay` to the sudoers file:
```
nano /usr/local/etc/sudoers
```

We can give our `relay` user sudo privileges by adding the following line to the sudoers file:
```
relay ALL=(ALL) ALL
```

After a reboot, you should now be able to log in as the non-root user via SSH and perform administrative tasks that way using `sudo`.


## Installing Open-VM-Tools (VMware Guests Only)
Run the following (make sure to turn of X11 support at the `ncurses` prompt - might as well reduce the attack surface by not compiling in features we don't need).

This will take a LONG time, as there are a lot of dependencies to build too.
```
cd /usr/ports/emulators/open-vm-tools
sudo make install clean
```


## Installing Tor
Install:
```
cd /usr/ports/security/tor
sudo make install clean
```

Copy the sample config to the default config location:
```
sudo cp /usr/local/etc/tor/torrc.sample /usr/local/etc/tor/torrc
```

Tweak the config:
```
sudo nano /usr/local/etc/tor/torrc
```

Create the logfile and set the correct permissions:
```
sudo touch /var/log/tor.log && sudo chown _tor:_tor /var/log/tor.log && sudo chmod 600 /var/log/tor.log
```

To enable Tor as a daemon (sets it to start on boot), open the `rc.conf` file for editing:
```
sudo nano /etc/rc.conf
```

Add the following line to the file opened with the above command:
```
tor_enable=YES
```

Restart:
```
sudo shutdown -r now
```

And confirm that Tor has started properly after the reboot:
```
tail -f /var/log/tor.log
```


## Future Maintenance - Updating the Ports Tree
**Note:** The `portsnap fetch extract` command further up this page is for downloading the whole ports tree onto an empty system.

Once we already have the ports tree downloaded, we will only need to run the following command in future:
```
sudo portsnap fetch && sudo portsnap update
```


## Future Maintenance - Checking for Vulnerabilities
FreeBSD maintains a vulnerability database that should be checked regularly to ensure that there are no vulnerabilities in the software you have installed on your system.

To check for known vulnerabilities with any of the optional software you have installed on your system, type:
```
sudo portaudit -F
```


## Future Maintenace - Updating All Outdated Ports
Install `portupgrade`:
```
cd /usr/ports/sysutils/portupgrade
sudo make install clean
```

After portupgrade is installed, update all packages with:
```
sudo portsnap fetch && sudo portsnap update
sudo portaudit -F
sudo portupgrade -arR
```
