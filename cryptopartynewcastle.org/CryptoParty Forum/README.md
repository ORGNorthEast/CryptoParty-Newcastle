## Server Config Transparency Notes
This is the server installation log for the CryptoParty Newcastle [website](https://cryptopartynewcastle.org/) and [forum](https://forum.cryptopartynewcastle.org/).

Installed OS into VM (CentOS 7).


#### OS Initial Setup
User `party` created during setup, with sudo priveliges.

Perform first update as root and install some useful packages:
```
sudo yum clean all && sudo yum update && sudo yum install git wget open-vm-tools nano
```

Shut down VM and created a snapshot here, before further action was taken.


#### Docker Installation
Installed Docker as follows:
```
wget -qO- https://get.docker.com/ | sh
```

Configured Docker daemon to start on boot:
```
sudo systemctl start docker && sudo systemctl enable docker
```


#### Discourse Forum Installation
Signed up for [Mailgun](https://mailgun.com/signup) mail relay account. Free package allows 10k emails per month to be relayed, and these mailer credentials are needed before installation can be completed. Configured DNS records as suggested by Mailgun. *Verification can take several hours, and you will not be able to install Discourse before this has completed and mails can be sent.*

Installed Discourse as per the instructions [on the Discourse GitHub docs page](https://github.com/discourse/discourse/blob/master/docs/INSTALL-cloud.md).

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

Please note that the SMTP password is set in your Mailgun control panel. It is **not** the same password as the one you use to log into the Mailgun control panel to administer the mail service.

Skipped LetsEncrypt setup as we are going to be serving this via nginx acting as our SSL terminator.

Created routes on the [Mailgun page](https://mailgun.com/app/routes) to forward mail going to `admin@cryptopartynewcastle.org` to an actual mail address (we will need this otherwise we won't be able to verify the mail address for our admin account.


#### nginx Reverse-Proxy Installation
Rather than allowing Discourse to act as its own webserver, we want to be able to use Nginx as a reverse-proxy to allow us to have better control over the crypto and certificates used, and the server headers set by the site. I based this section on a great guide by DigitalOcean, [which can be found here](https://www.digitalocean.com/community/tutorials/how-to-install-discourse-behind-nginx-on-ubuntu-14-04).

Open the Discourse config for editing (do this before attempting to install nginx on the same system - otherwise the nginx post-install scripts will fail as Discourse will be bound to `:80`):
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
  - "8091:443"  # https
```

The above example will listen for HTTP connections on port `8090` on the host, and redirect it to port `80` in the Docker container.

If we were going to be using an nginx reverse proxy on the same host to connect to our Discourse instance, our lines should look like this instead:
```
  - "127.0.0.1:8090:80"   # http
  - "127.0.0.1:8091:443"  # https
```
Please pay close attention to [the addition of 127.0.0.1](https://meta.discourse.org/t/running-other-websites-on-the-same-machine-as-discourse/17247/26) on each line above. This is done because when Docker is configured to expose ports, it [messes with the iptables firewall directly](http://blog.viktorpetersson.com/post/101707677489/the-dangers-of-ufw-docker) and would end up bypassing UFW and listening for outside connections on `8090` and `8091` if we didn't ensure we did that.

Now, we rebuild our Discourse container:
```
cd /var/discourse && sudo ./launcher rebuild app
```

Install nginx:
```
sudo yum install nginx
```

Ensure the `proxy_pass` and `proxy_redirect` directives in the `nginx.conf` file point to our new HTTP port (`8090`). (See the `/etc/nginx/nginx.conf` example [in this repo](https://github.com/ORGNorthEast/CryptoParty-Newcastle/blob/master/cryptopartynewcastle.org/System/etc/nginx/nginx.conf))

Added `cryptoparty` user to `nginx` group, to make it easier to deal with nginx directories: (This group is called `www-data` if you are using a Debian-based system).
```
sudo usermod -a -G nginx cryptoparty
```


#### nginx Reverse Proxy
**Important!**
If you are running an nginx reverse proxy on a different machine to your Discourse instance like me (virtual machines included), you might need to set the following SELinux boolean before traffic will be properly proxied:
```
sudo setsebool -P httpd_can_network_connect true
```
If you are not running a distribution with SELinux, the above command will not be necessary.



#### Install TripWire
**Caution:** If you intend to use TripWire, it is recommended that your system does not deploy `unattended-upgrades`. System and package upgrades (as you might expect) modify a lot of files on disk and the use of unattended upgrades will lead to your TripWire reports of modified files being mostly false positives that have been changed by the update process, and you may end up missing vital clues leading to a genuine intrusion.

Install TripWire [HIDS](https://en.wikipedia.org/wiki/Host-based_intrusion_detection_system):
```
sudo yum install tripwire
```

Initialize TripWire database:
```
sudo tripwire --init
```

Pay attention to the files that TripWire notes are not installed (you probably want to comment these out in your TripWire policy, or the fact that they are "missing" will be reported as an error every time TripWire is run).

Edit TripWire policy:
```
sudo nano /etc/tripwire/twpol.txt
```

See [here](https://github.com/ORGNorthEast/CryptoParty-Newcastle/blob/master/cryptopartynewcastle.org/TripWire/DefaultPolicy/twpol.txt) for the default policy, [here](https://github.com/ORGNorthEast/CryptoParty-Newcastle/blob/master/cryptopartynewcastle.org/TripWire/MyPolicy/twpol.txt) for my policy, and [here](https://github.com/ORGNorthEast/CryptoParty-Newcastle/blob/master/cryptopartynewcastle.org/TripWire/MyPolicy.patch) for a patchdiff comparing the two.

Load new TripWire policy:
```
sudo twadmin -m P /etc/tripwire/twpol.txt
```

Rebuild the TripWire database using the new config:
```
sudo tripwire --init
```

In the future, you can now check for files within the TripWire policy which have been modified with the following command:
```
sudo tripwire --check
```

When conducting system updates, it is a good idea to run `tripwire --check` before updating anything, as updates will modify a lot of system files and you may miss out on information about a potential intrusion if you conduct an update before running a TW check.

After you have finished updating, remember to run `tripwire --init` again, to re-initialize the TripWire database and make it aware of the new packages. If you do not do this, you will still be working from a pre-update TripWire database, and a `tripwire --check` will report up a lot of false positives, as it cannot distinguish between files modified maliciously and files modified by a system update.


#### HTTPS
LetsEncrypt keys were generated for my nginx SSL terminator using the process noted in [the LetsEncrypt README file here on this repo](https://github.com/ORGNorthEast/CryptoParty-Newcastle/tree/master/cryptopartynewcastle.org/LetsEncrypt).


#### Final Reboot
As always, it's useful to check that after a reboot (or maintenance event) everything comes back up and works as expected. Our final test for this server is to reboot with:
```
sudo shutdown -r now
```
