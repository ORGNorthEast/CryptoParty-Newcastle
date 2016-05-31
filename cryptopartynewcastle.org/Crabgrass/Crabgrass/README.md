# Installing Crabgrass (Ruby-on-Rails App) on Nginx

#### System Setup
Install dependencies:
<pre>sudo apt install ruby ruby-dev rake mysql-server mysql-client libmysqld-dev git make libssl-dev g++ graphicsmagick libmysqlclient-dev libsqlite3-dev</pre>

Install Rails:
<pre>sudo gem install rails</pre>

Install Passenger (tool for deploying Rails apps):
<pre>sudo gem install passenger</pre>

Install Bundler:
<pre>sudo gem install bundler</pre>

Install Passenger module for Nginx (**THIS WILL MAKE CHANGES TO YOUR NGINX CONFIG!**):
<pre>sudo passenger-install-nginx-module</pre>

After Passenger finishes recompiling Nginx, it will let you know about any changes it made to your Nginx config. You probably want to verify these, and then restart nginx.

If you want to compile Nginx with Google's BoringSSL instead of the default OpenSSL, then please see my [BoringNginx](https://github.com/ajhaydock/BoringNginx) repo.

#### Database Creation
Create database:
<pre>sudo mysqladmin --user=root --password create crabgrass</pre>

Enter a MySQL shell:
<pre>mysql --user=root --password</pre>

Enter the following in the MySQL shell:
<pre>
mysql> use crabgrass;
mysql> grant all on crabgrass.* to crabgrass@localhost identified by 'a_new_password';
mysql> flush privileges;
mysql> quit
</pre>

#### Switch to Crabgrass User
Add a new directory to run Crabgrass from, owned by your webserver user:
<pre>sudo mkdir -p /home/crabgrass</pre>
<pre>sudo chown -R www-data:www-data /home/crabgrass</pre>

Change the home directory of the `www-data` user to this area, to make things easier:
<pre>sudo usermod -m -d /home/crabgrass www-data</pre>

Change the shell of the `www-data` user to allow us to login:
<pre>sudo nano /etc/passwd</pre>

Edit the line that looks like:
<pre>www-data:x:33:33:www-data:/home/crabgrass:/usr/sbin/nologin</pre>

...to look like:
<pre>www-data:x:33:33:www-data:/home/crabgrass:/bin/bash</pre>

Now, login as `www-data`:
<pre>sudo su www-data</pre>

#### Download & Setup Crabgrass
Now, clone Crabgrass:
<pre>git clone https://github.com/riseuplabs/crabgrass-core.git $HOME/crabgrass</pre>

Ensure that our `RAILS_ENV` environment variable is set to `production` in the current shell:
<pre>export RAILS_ENV=production</pre>

...and in all future shells
<pre>echo "export RAILS_ENV=production" >> .bashrc</pre>

Enter Crabgrass dir and install bundle:
<pre>cd crabgrass/ && bundle install</pre>

Create database config:
<pre>cp config/database.yml.example config/database.yml</pre>

Edit `config/database.yml`:
<pre>
username: crabgrass
password: database_password_from_before
</pre>

Copy an example production config to use for our configuration file:
<pre>cp config/crabgrass/crabgrass.production.example.yml config/crabgrass/crabgrass.production.yml</pre>

Create a secret:
<pre>rake create_a_secret</pre>

Initialize the DB:
<pre>
rake cg:convert_to_unicode
rake db:schema:load
</pre>

Compile assets:
<pre>rake assets:precompile</pre>

The above command deals with compiling javascript, which is run through a JIT compiler, meaning a hyperactive [Grsecurity-patched](https://grsecurity.net/) kernel will kill the above command. If you are running a Grsec kernel, ensure you have the `attr` package installed, and then try running the following (as your normal user - `www-data` will not be granted sudo privileges):
<pre>sudo setfattr -n user.pax.flags -v m /usr/bin/ruby</pre>

To install the CSS for images:
<pre>rake cg:images:update_css</pre>

If you are using a Grsec kernel and opted to manually compile Passenger into your Nginx binary, you probably also missed out on the `passenger-config` step that compiles your PassengerAgent binary. You may see something like the following in your Nginx error log if this is the case:
<pre>The PassengerAgent binary is not compiled. Please run this command to compile it: /var/lib/gems/2.1.0/gems/passenger-5.0.28/bin/passenger-config compile-agent</pre>

To fix the above error, run:
<pre>sudo /var/lib/gems/2.1.0/gems/passenger-5.0.28/bin/passenger-config compile-agent</pre>

#### Test Crabgrass is Working
*This section assumes you have already set up your `nginx.conf` file accordingly. (See the `Nginx` directory in this repo for more info and my example config.)*

Logout of the `www-data` user:
<pre>exit</pre>

Restart Nginx:
<pre>sudo systemctl restart nginx</pre>

Visit your site, and hopefully you get a login page.

**Most things will work at this point, but there is still more work to be done here, so this guide is to be treated as a WORK IN PROGRESS**
