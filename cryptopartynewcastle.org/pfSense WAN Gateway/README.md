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


## pfSense Gateway Creation
Created pfSense VM with 8GB HDD and 1GB RAM. Used E1000 NICs as the VMXNET ones require the VM tools first.

Generated a MAC address for the "failover IP" using the Online.net console, and put this in the pfSense VM's network config for the "WAN" NIC. Without doing this, Online.net would have locked our host for broadcasting a MAC that its switch was not expecting.

After boot, assign the failover IP statically to the WAN port (it suggests a /32 subnet on Online.net, but pfSense will only take /31, so do that for now)

In my example: 212.129.38.254/31 has been assigned as the WAN IP.

When it asks for a gateway - do not give it one!

Then return to the main pfSense console and press `8` to drop into a shell.

Enter the following commands (where 163.172.84.1 is the IP of your MAIN gateway - the gateway of your primary (not failover) IP on this server):
```
route add -inet 163.172.84.1/32 -link -iface em0
route add default 163.172.84.1
```

We can test this is working with:
```
ping -c 3 google.com
```

Enable SSH access from the console by choosing option `14`.

Drop back into a shell, and run the following to allow SSH access on the WAN port (where `82.2.53.144` is the IP you want to connect **from**, and `212.129.38.254` is the WAN IP of the pfSense machine that you want to connect **to**):
```
easyrule pass wan tcp YOUR.HOME.IP.HERE 212.129.38.254 22
```

You should now be able to connect with (the default password is `pfsense`):
```
ssh -L 4434:127.0.0.1:443 admin@212.129.38.254
```

This will forward port `443` from pfSense (i.e. the WebGUI) to `4434` on your local machine. You can then go to https://127.0.0.1:4434/ to view the pfSense WebGUI.

When you are redirected to the wizard, skip it by clicking the pfSense logo in the top left of the initial page. You will need to set up your LAN IP and subnet manually, as well as specifying DNS and NTP servers. We can do that later. You will also want to change the admin password at some point (IMPORTANT!).


### Making the Gateway Change Persistent
Navigate to the Package Manager page and install the "shellcmd" package.

Now, in Services > Shellcmd, you need to add the following two commands (same as we ran earlier):
```
route add -inet 163.172.84.1/32 -link -iface em0
route add default 163.172.84.1
```

Now it is safe to make the changes I described above. Do these, then ensure the system is updated, then reboot.

Finally, you should go into the "WAN" section of the WebGUI and make sure the subnet mask is set to `/32`. After you click save, the WebGUI will hang (obviously, since you just changed the subnet of the interface you're using to connect to it), so return to the ESXi console and reboot the VM using option `5` on the console menu. If you have your shellcmd commands set correctly, it should come back up fine and allow SSH connections again.

The gateway seems to always show "Offline" if you add the widget to the pfSense dashboard, but it doesn't seem to be a problem, so I think that can be safely ignored. DO NOT REMOVE this "broken" gateway from the 'Routing' page in pfSense, or all your routing will stop. You have been warned.


### VMXNET Network Adapters
Don't forget to also install the Open-VM-Tools package so ESXi knows what we are doing. After you do this, you can switch out the default E1000 virtual LAN adapter for the 10GigE VMXNET 3 one. Remember to ensure that the MAC address for the WAN adapter is manually set up to be the same as the one used before and put into the Online.net web console!

**Please note that when using VMXNET adapters, your interfaces will probably be called `vmx0` and `vmx1` now and will require some reconfiguration.** This will include changing the commands run by the shellcmd package to use the `vmx0` interface.


## NAT (Enable Routing Capabilities - Required!)
Navigate to Firewall > NAT > Outbound and set the NAT rule generation to "Manual Outbound NAT rule generation."

Then, create a new NAT rule pointing to your internal virtual LAN as shown in the image saved in this directory.


## A Suggestion Re: DHCP
When creating VMs, I like to use DHCP to assign their "internal LAN" IP addresses. It's easiest if you set a manual MAC address in VMware before even turning the VM on for the first time. Then this can be put into pfSense, and an IP can be assigned before the first poweron. This leads to much fewer headaches and is a much better way of doing things.


## SSH Pivot
I then created a VM to act as an SSH 'pivot' and attached it to the pfSense LAN interface. On this, I installed only OpenSSH and Tor, and configured the machine to expose the SSH port via an arbitrary port on a secret `.onion` address.

I then removed the SSH port forward from the pfSense VM's SSH port to the internet, leaving me with only this port to bridge into the virtual LAN. By SSH-ing into this machine, I can use it as if I am inside the virtual LAN, and SSH into other machines to manage them.

Problems with the machine can be resolved from the VMware console if necessary.

The following command is the standard SSH command to connect to my server now, and it forwards many things (see list):
```
torsocks -i ssh -p 40422 -L 4444:172.16.16.1:443 pivot@myonionaddress.onion
```

This forwards the following:
* pfSense WebGUI to 4444 on localhost.

From here, you can administer pfSense as you would expect.


## Repeated packet blocks from  0.0.0.0 UDP/68 to 255.255.255.255 UDP/67 (on the WAN interface) clogging up firewall logs
Under the default config, you may notice a lot of firewall log events blocking DHCP requests from 0.0.0.0 UDP/68 to 255.255.255.255 on UDP/67. This is likely to be the case if you have other clients on the same ISP subnet as you [making DHCP requests](https://forum.pfsense.org/index.php?topic=108776.0). It probably means that whoever owns this particular machine has configured it incorrectly - but that isn't really your problem. You can safely ignore these, or add a specific firewall block rule for these with logging disabled (will avoid these records polluting your logs all the time).
