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


## Installing Tor
**Note:** The FreeBSD equivalent of Linux's `/var/lib/tor` is `/var/db/tor`. This is where you can expect Tor stats, identity files, and hidden service keys to be stored.

Install:
```
cd /usr/ports/security/tor
sudo make install clean
```

Copy the sample config to the default config location (or you can base your config on the one in this directory):
```
sudo cp /usr/local/etc/tor/torrc.sample /usr/local/etc/tor/torrc
```

Tweak the config:
```
sudo nano /usr/local/etc/tor/torrc
```

To enable logging for debug purposes, ensure that the following line is not commented out in the `torrc` config. You can disable logging at a later date if you like, but this is probably going to be useful for debugging why things don't work if they are failing:
```
Log notice file /var/log/tor/notices.log
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
sudo ps aux | grep tor
```

We can also tail the logfile we specified in the `torrc`:
```
sudo tailf /var/log/tor/notices.log
```


## Copying Tor Config from an Existing Machine
If, like me, you can't be bothered to build `rsync` from ports, `scp` is probably the easiest option to move an existing relay's config to your new FreeBSD host. I did (from the machine containing the current config):

```
scp -r /path/to/tor/config/backup/ relay@172.16.16.60:/home/relay/torconfig/
```

Always remember that if you copy an old config over `/var/db/tor` on your FreeBSD machine, that it should be owned by the `_tor` user and group. To be safe:
```
sudo chown -R _tor:_tor /var/db/tor
```


## Installing Open-VM-Tools (VMware Guests Only)
Run the following (make sure to turn of X11 support when the `ncurses` prompt gives you the option - might as well reduce the attack surface by not compiling in features we don't need).

This will take a LONG time, as there are a lot of dependencies to build too.
```
cd /usr/ports/emulators/open-vm-tools
sudo make install clean
```

To run the Open Virtual Machine tools at startup, add the following
settings to your ```/etc/rc.conf```
```
vmware_guest_vmblock_enable="YES"
vmware_guest_vmhgfs_enable="YES"
vmware_guest_vmmemctl_enable="YES"
vmware_guest_vmxnet_enable="YES"
vmware_guestd_enable="YES"
```


## Future Maintenance - Backing-Up/Migrating Relay Identity
It should suffice to back-up `/var/db/tor` if you want to preserve (or migrate) your relay. If you are migrating, the following files are the important ones:
```
/var/db/tor/fingerprint
/var/db/tor/keys/ed25519_master_id_public_key
/var/db/tor/keys/ed25519_master_id_secret_key
/var/db/tor/keys/ed25519_signing_cert
/var/db/tor/keys/ed25519_signing_secret_key
/var/db/tor/keys/secret_id_key
/var/db/tor/keys/secret_onion_key
/var/db/tor/keys/secret_onion_key_ntor
```


## Future Maintenance - Stopping Tor Service (Temporarily)
```
sudo service stop tor
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
Install `portupgrade` to help us with keeping software that we installed from ports up-to-date:
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
