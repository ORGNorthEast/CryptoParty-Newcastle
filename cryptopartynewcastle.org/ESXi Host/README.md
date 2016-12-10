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


## Hardening ESXi
So ESXi by its nature has a management interface exposed to the internet if you're remotely managing it. This means it tends to get hammered with logins pretty consistently once automated bots and scripts find it and attempt to log in.

There are some precautions that can be taken to solve this issue.

#### Change root password
ESXi appears to support up to 40-character passwords for accounts. Might as well use all 40.

**Note:** This seems to only hold true when the passwords are set from the Web GUI. Set them there rather than trying to do it from the .NET vSphere Client.

#### Stop SSH
You probably don't use it much, so stop it in the Configuration tab. Ensure that it doesn't start up again when the host is restarted by setting it to "Start and stop manually".

#### Create a new user and disable root
* In vCenter, navigate to the "Users" tab and right click to add a new user. Choose a strong password and a username that automated scripts won't guess.
* Move to the "Permissions" tab and right click and select "Add Permission".
* From the dropdown box, choose "Administrator" and then add your new user into the box on the left of this window.

You have now added a new Administrator account, without the `root` username. Once **you have confirmed that this account definitely actually works to log into the vSphere Client and WebUI**, you can navigate back to the "Permissions" tab and change the "Role" for `root` to "No Access". This will prevent `root` from logging in at all.

#### Lock down the login attempts
In Advanced Settings > Security, set `Security.AccountLockFailures` to 3, and `Security.AccountUnlockTime` to the maximum 3600 seconds.
