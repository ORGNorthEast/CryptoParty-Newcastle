## Discourse Backup Policy
After installing Discourse, navigate to Settings > Backups and configure the frequency of your auto-backup. The defaults here are to take one backup per week and keep 5. This might be fine if you have a giant forum, but for a smaller forum there is no harm in setting the backup frequency to once a day, and setting the system to keep something like 30 previous backups.

#### Automated Offsite Backup
By default, these backups are stored in the following directory:
```
/var/discourse/shared/standalone/backups/default/
```

Since your VPS/server probably has a single hard disk and is a single point of failure, we really want to get these backups off the system in an automated manner.

This guide will configure and deploy automated backups via rsync to a remote location (in this case, a Tor `.onion`)
