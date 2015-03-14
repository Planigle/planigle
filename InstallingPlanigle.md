# Installation Prerequisites #

Note: version numbers below represent what is currently running in production.  Support is easiest to provide the closer you are to these versions.  In particular, be wary of using newer versions of Ruby and Rails.

MySQL 5.0.77 (or higher) - http://dev.mysql.com/downloads/  or in ubuntu: sudo apt-get install mysql-server

Ruby 1.8.6.x - http://www.ruby-lang.org/en/downloads/ or in ubuntu: sudo apt-get install rails ruby1.8-dev build-essential ruby-dev libmysqlclient16-dev

RubyGems 1.3.7 (or higher) - http://rubyforge.org/frs/?group_id=126 (covered in previous step for ubuntu)

Ruby on Rails 2.0.2
  * gem install rails --version 2.0.2

Mongrel 1.1.5 (or higher)
  * gem install mongrel

Fastercsv 1.0.1
  * gem install fastercsv –v 1.0.1

will\_paginate
  * gem sources -a http://gems.github.com
  * gem install will\_paginate –v 2.2.2

mysql
  * gem install mysql

Subversion 1.6.6 (or higher) - http://subversion.tigris.org/getting.html

Flex SDK 3.2 (or higher) - http://www.adobe.com/products/flex/flexdownloads/

# Getting Started: #

Export the current Planigle version to your computer using Subversion:
  * svn checkout http://planigle.googlecode.com/svn/tags/[version]/ [to install](directory.md)

Create a database for Planigle:
  1. mysql -u root -p [password](password.md)
  1. create database planigle\_production;
  1. exit
  1. cd [directory](Planigle.md)
  1. rake db:migrate RAILS\_ENV=production

Build the Flex module for Planigle:
Note: this currently only works on Windows; On other platforms (or on Windows if you prefer), you can get the .swf files by downloading http://www.planigle.com/planigle/Main.swf to [directory](Planigle.md)/public and downloading http://www.planigle.com/planigle/modules/Core.swf to [directory>/public/modules.](Planigle.md)
  1. Set the FLEX\_HOME environment variable to point to your Flex SDK directory (this directory will contain bin).
  1. Add “;%FLEX\_HOME%\bin” to the PATH.
  1. cd [directory](Planigle.md)
  1. rake build:production

Configure Planigle:
  1. In [path](path.md)/config/database.yml, set the properties for your local DB (if different from the default).
  1. In [path](path.md)/config/initializers/mail.rb, configure your mail settings.

Run Planigle:
  1. cd [directory](Planigle.md)
  1. mongrel\_rails start –e production
  1. Test by bringing Planigle up in the browser at http://[hostname]:3000/

Create a job to summarize data:
  * Create a once a day cron job to go to http://[hostname]:3000/summarize

If you’re planning to use http:// only (i.e., you do not plan to configure Apache for SSL with a trusted certificate):
  * No changes necessary

If you’re planning to use https:// only:
  * You should delete public/crossdomain.xml

# Using Apache (optional) #

In Ubuntu, run :
sudo apt-get install apache2

In Windows, to create an Apache server on your development box:
  1. Install Apache (from http://httpd.apache.org/download.cgi; make sure you get the version with SSL; these instructions were written with 2.2.8 on Windows)
  1. Edit the httpd.conf file in the apache/conf directory
  1. Change DocumentRoot to point to the public directory in your planigle directory (use slashes even on Windows; ex., C:/Users/Walter/workspace/planigle/public)
  1. Change `<Directory "<path>">` to point to the same directory as DocumentRoot
  1. Uncomment the line to "LoadModule headers\_module modules/mod\_headers.so"
  1. Uncomment the line to "LoadModule proxy\_module modules/mod\_proxy.so"
  1. Uncomment the line to "LoadModule proxy\_balancer\_module modules/mod\_proxy\_balancer.so"
  1. Uncomment the line to "LoadModule proxy\_http\_module modules/mod\_proxy\_http.so"
  1. Uncomment the line to "LoadModule rewrite\_module modules/mod\_rewrite.so"
  1. Uncomment the line to "Include conf/extra/httpd-vhosts.conf
  1. Edit the httpd-vhosts.conf file in the apache/conf/extra directory
  1. Comment out the existing lines
  1. Add the following:
```
<Proxy balancer://mongrel_cluster> 
  BalancerMember http://127.0.0.1:3000 
</Proxy> 
  
<VirtualHost *:80> 
  ServerName www.planigle.com 
  DocumentRoot <path>/public 
  
  <Directory "<path>/public"> 
    Options FollowSymLinks 
    AllowOverride None 
    Order allow,deny 
    Allow from all 
  </Directory> 
  
  RequestHeader set X_FORWARDED_PROTO "http" 
  
  RewriteEngine On 
  
  # Check for maintenance file and redirect all requests 
  RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -f 
  RewriteCond %{SCRIPT_FILENAME} !maintenance.html 
  RewriteRule ^.*$ /system/maintenance.html [L] 
  
  # Rewrite index to check for static 
  RewriteRule ^/$ /index.html [QSA] 
  
  # Redirect all non-static requests to cluster 
  RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f 
  RewriteRule ^/(.*)$ balancer://mongrel_cluster%{REQUEST_URI} [P,QSA,L] 
  
  ErrorLog "<path>/log/apache.log" 
  TransferLog "<path>/log/access.log"  
  
</VirtualHost> 
```

To enable SSL for Apache:
  1. Edit the httpd.conf file in the apache/conf directory
  1. Uncomment the line to "LoadModule ssl\_module modules/mod\_ssl.so"
  1. Uncomment the line to "Include conf/extra/httpd-ssl.conf"
  1. Generate a private key; Note: On Windows Vista, I had to run these commands from some place other than apache (i.e., my documents directory) due to permission issues
```
openssl genrsa -rand file1:file2:file3:file4:file5 -out server.key 1024 

note: file1, etc. are some random files on your system
```
  1. Make it so that the private key isn't passcode protected (this makes it easier to start up; you wouldn't want to do it on a production system)
```
openssl rsa -in server.key -out server.pem 
```
  1. Create a CSR (certificate signing request)
```
openssl req -config "c:\program files\apache software foundation\apache2.2\conf\openssl.cnf" -new -key server.key -out server.csr 

Note: Country = US (or 2 letter code for your country); Common name = fully qualified domain name for server
```
  1. Generate the certificate (must be administrator)
```
openssl x509 -req -days 60 -in server.csr -signkey server.key -out server.crt 
```
  1. Copy the server.pem and server.crt files into your apache\conf directory
  1. Edit the httpd-ssl.conf file in the apache\conf\extra directory
  1. Change the reference to server.key to server.pem
  1. Replace the general setup for the virtual host section with:
```
ServerName <fullyqualified server name from above>:443 
  
DocumentRoot <path>/public 
```
  1. Add the following:
```
RewriteEngine on
RewriteRule ^/$ http://127.0.0.1:3000/index.html [P,QSA,L]
RewriteRule ^/(.*)$ http://127.0.0.1:3000/$1 [P,QSA,L]
```

# Using Eclipse (Optional) #

Eclipse - http://www.eclipse.org/
  * Plain Java version is fine.
  * Use any workspace location.

Plugins to load after Eclipse is installed.  (Use the Find and Install option in the Help menu.)

Aptana RadRails (http://www.radrails.org/)

Subversion (http://subclipse.tigris.org/)
Note: Do not install the Integrations when picking which features to install.

SQL Explorer (http://eclipsesql.sourceforge.net/)
  * This driver must be installed: MySQL JDBC driver from http://dev.mysql.com/downloads/connector/j/5.0.html
  * Once installed, Eclipse preferences must be set for the MySQL to include an extra class path for the driver (after expanding it from the download zip).

Eclipse setup:

  1. Create new SVN Project (Other).
    * https://planigle.googlecode.com/svn
  1. To setup Flex to run in Eclipse, download and install the Flex plugin (http://www.adobe.com/cfusion/tdrc/index.cfm?product=flex_eclipse&loc=en_us)

To enable Flex Eclipse Module in your Ruby on Rails project:
  1. Right Click on Planigle Ruby Project in Eclipse
  1. Select Flex Project Nature>>Add Flex Project Nature
  1. Leave Application Server type as none.
  1. Click on Next>
  1. Add public to the Source path.
  1. Change Output folder to public
  1. Click on Finish
  1. You’ll also need to change the runable application file by right clicking on the project, selecting properties, going to Flex Applications, adding src/Main.mxml and clicking Set as Default.

To Debug or Profile the Flex application:
  1. Right click on Planigle Project
  1. Select Run As>>Rails Application
  1. Right click on Planigle Project
  1. Select Run As>>Open Run Dialog...
  1. Go to Flex Application>>planigle
  1. Uncheck Use defaults
  1. Change ...\planigle.html to ...\index.html for all 3 fields (debug, profile and run).
  1. Click on Run
Note: After this, you'll be able to just do Run As>>Flex Application (same for Debug As and Profile As).

You can build in Eclipse by:
  * Rake build:test

To create a test database for Planigle:
  1. Open a command line
  1. mysql -u root -p [password](password.md)
  1. create database planigle\_test;
  1. exit

To run Planigle in test mode on your development box (necessary to run the Flex automation tests):
  1. Go to the Servers view in Eclipse (if not open, select Window>>Show View>>Servers)
  1. Click on the arrow next to the Add Server button
  1. Select Connect to Rails Server
  1. Change name to Planigle-Test
  1. Change type to Mongrel
  1. Change port to 3000
  1. Change environment to Test
  1. Click on OK
  1. Now you can click on that server row and select run or debug like you normally would

To run the Flex tests, you’ll need to install FunFX 0.0.4
  1. Download http://rubyforge.org/frs/download.php/35506/FunFX-0.0.4.zip.
  1. Extract the FunFX-0.0.4.gem file
  1. From the same directory, execute gem install FunFX