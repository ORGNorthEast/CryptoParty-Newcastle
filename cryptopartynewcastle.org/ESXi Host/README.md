Before starting, assigned a proper subdomain (esxi.cryptopartynewcastle.org) to ESXi.

Installed ESXi using Online.net standard procedure, giving it the above hostname when requested.

Accessed ESXi as normal using Windows vSphere application.


## vSphere Setup
Created Virtual Networks as shown in saved image.

Make sure port `902` is not blocked on your outgoing firewall, or you won't be able to connect to the virtual consoles for your VMs! I screwed myself with this one.

Created `_iso/` directory inside datastore and uploaded some useful ISOs.

Set up NTP and fed it some servers.

Closed SNMP ports on firewall.

Signed up to VMware for a free license and assigned it to the server.
