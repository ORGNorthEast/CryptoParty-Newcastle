### Why FreeBSD?
As of the time I wrote this (Nov 2016), most of the relays in the network are running on Linux. This means that an exploit like [Dirty COW](https://dirtycow.ninja/) could potentially affect a **significant majority** of the relays within the network. An increase in diversity in the relays making up the Tor network is therefore a good thing, as it may help to defend against these classes of attacks or exploits which are unique to a particular kernel or operating system. Ideally, operating system distribution within the Tor network would be a lot more evenly-spread. Having a network that is too homogenous is harmful for its overall security.

An example graph, from [torstatus.blutmagie.de](http://torstatus.blutmagie.de/network_detail.php) showing the (lack of) operating system diversity in Nov 2016:

![Tor Network Diversity](https://raw.githubusercontent.com/ORGNorthEast/CryptoParty-Newcastle/master/cryptopartynewcastle.org/ORGNorthEast1%20Tor%20Relay%20(FreeBSD)/Nov2016Diversity.png)

For the reasons listed above, I have decided to move the `ORGNorthEast` relay, which has existed for over a year on Linux based platforms (I've moved between Debian and CentOS a few times), to FreeBSD. In future I am also going to be looking into setting up relays on OpenBSD, and potentially OpenIndiana.

### Notes
* Please note that to complete this guide you will need to create a VM with a relatively large filesystem (compiling packages from ports can take up a lot of space). A 32GB disk should do it.
* You might also want to create your VM with plenty of cores available when you're doing the initial installation and building packages (will speed things up a lot). You can then return to just 1 vCPU afterwards if you prefer.

### Initial Installation & Update
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

#### Setting up pkg
In order to use the `pkg` package management tool, we need to install it. Fortunately, FreeBSD includes an automatic bootstrapping tool to install pkg. Simply try and execute `pkg` using:
```
/usr/sbin/pkg
```
and FreeBSD will let you know that `pkg` is not installed and will need to be downloaded.

**Note:** There is a bug present in the current version of VirtualBox (5.1.10, Dec 2016) that prevents `pkg` from bootstrapping correctly if a "bridged" virtual network adapter is used. To avoid this, make sure to use a NAT adapter if installing as a VirtualBox VM.

#### Installing sudo & nano
```
pkg install sudo nano
```

Now add your user to the `/usr/local/etc/sudoers` file with the following line (where `relay` is your username):
```
relay ALL=(ALL) ALL
```

### Installing Tor
**Note:** The FreeBSD equivalent of Linux's `/var/lib/tor` is `/var/db/tor`. This is where you can expect Tor stats, identity files, and hidden service keys to be stored.

Install:
```
pkg install tor
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

### Copying Tor Config from an Existing Machine
If, like me, you can't be bothered to build `rsync` from ports, `scp` is probably the easiest option to move an existing relay's config to your new FreeBSD host. I did (from the machine containing the current config):

```
scp -r /path/to/tor/config/backup/ relay@172.16.16.60:/home/relay/torconfig/
```

Always remember that if you copy an old config over `/var/db/tor` on your FreeBSD machine, that it should be owned by the `_tor` user and group. To be safe:
```
sudo chown -R _tor:_tor /var/db/tor
```

### Installing Open-VM-Tools (VMware Guests Only)
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

### Installing Arm (Advanced Relay Monitor)
Install [Arm](https://www.torproject.org/projects/arm.html.en) to monitor your Tor relay as follows:
```
pkg install arm
```

You will also need to install Python, as it does not seem to get built automatically when installing Arm:
```
/usr/ports/lang/python
sudo make install clean
```

You should now be able to run arm as follows:
```
sudo -u _tor arm
```

### Future Maintenance - Backing-Up/Migrating Relay Identity
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

### Future Maintenance - Stopping Tor Service (Temporarily)
```
sudo service stop tor
```

### Future Maintenance - Checking for Vulnerabilities
FreeBSD maintains a database of software with known vulnerabilities. You can check whether any of your installed ports match current security advisories with:
```
sudo pkg audit -F
```