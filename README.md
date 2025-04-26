# fastcgi
Fastcgi written in REXX for Apache

Prerequ:
Install OOREXX and have .REXX associated with OOREXX programs
Install APACHE
Install mod_fcgid (if not already installed)


Installation:
Download FASTCGI.REXX into CGI-BIN

Configure Apache:
In conf/httpd.conf enable (i.e. remove comment #)
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so

After
<Directory />
    AllowOverride none
    Require all denied
</Directory>

ADD:
ProxyPassMatch "^/(.*\.rexx(/.*)?)$" "fcgi://127.0.0.1:8000/Users/MikeBeer/htdocs" enablereuse=on

8000 is the port number and must match the port in FASTCGI.REXX
after that: your APACHE DocumentRoot



Tested with Apache 2.4.63 win 64 and mod_fcgi (https://www.apachelounge.com/download/)
