Installed Snort from Package manager.

Added WAN as the interface, with AC-BNFA search method. Set to block offenders (though we will remove blocks after 1 Hour in a later config page).

In Global Settings, configured to use Snort VRT rules with my Oinkmaster code (free if you sign up for one).

Set rules to auto-update every 12 hours, starting at 09:17.

Set blocked hosts to be removed after 1 hour, and after deinstall.

Chose "Force Update" on the update page to download a new ruleset (this will probably take a while).

At this point, I shut down the pfSense VM without enabling Snort, then snapshotted it and booted it back up. Snort will start on boot. (I do this because if you enable Snort from the WebGUI, the WebGUI will sometimes hang.)
