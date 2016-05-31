#### Log in as webserver user
Change the shell of the `www-data` user to allow us to login:
<pre>sudo nano /etc/passwd</pre>

Edit the line that looks like:
<pre>www-data:x:33:33:www-data:/home/crabgrass:/usr/sbin/nologin</pre>

...to look like:
<pre>www-data:x:33:33:www-data:/home/crabgrass:/bin/bash</pre>

Now, login as `www-data`:
<pre>sudo su www-data</pre>

#### Install Anahita
Enter your webroot:
<pre>cd /usr/share/nginx/html</pre>

#### Clone Anahita stable release with the Composer package manager
Download the Composer install script:
<pre>wget http://getcomposer.org/installer -O composer-installer</pre>

Install Composer:
<pre>php composer-installer && rm composer-installer</pre>

Create your Anahita project:
<pre>php composer.phar create-project anahita/project cryptopartynewcastle</pre>

The webroot that you will now serve using your webserver will be the current directory, plus the name you chose above and `/www`. In my case, this ends up being:
<pre>/usr/share/nginx/html/cryptopartynewcastle/www</pre>

Enter your project directory:
<pre>cd cryptopartynewcastle/</pre>

#### Install Anahita
You should be able to type the following command to get a list of commands you can use to interface with Anahita:
<pre>php anahita</pre>

To begin installing, run the following command:
<pre>php anahita site:init</pre>

You will be asked to provide your MySQL database information here. Please note that you also need the `php5-mysql` package for this webapp.

What I provided:
<pre>
Enter the name of the database? anahita
Enter the database user? root
Enter the database password? myrootpassword
Enter the database host address? (default: 127.0.0.1) 
Enter the database port? (default: 3306) 
Enter a prefix for the tables in the database? (default: jos_)
</pre>
Please note that you don't have to create the `anahita` database already, but you will need MySQL login details. You should have been asked for these when you first installed MySQL.

Set an Anahita config option to allow our app to play nice with Nginx:
<pre>nano www/configuration.php</pre>

Set the following option:
<pre>
var $sef_rewrite = '1';
</pre>

And then execute:
<pre>php anahita site:symlink</pre>


#### Web config
At this point, you now need to head to `http://yoursite/people/signup` and sign up an account to become the administrator of the site.
