# fastcgi
Fastcgi written in REXX for Apache
tested with OOREXX and REGINA 64bit (both Win 11 - 64bit)

Prerequ:
Install OOREXX and have .REXX associated with OOREXX programs
AND / OR
Install REGINA and RXSOCK 64bit and have .REX associated with REGINE

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
for OOREXX:
ProxyPassMatch "^/(.*\.rexx(/.*)?)$" "fcgi://127.0.0.1:8000/Users/MikeBeer/htdocs" enablereuse=on
for REGINA: 
ProxyPassMatch "^/(.*\.rex(/.*)?)$" "fcgi://127.0.0.1:9000/Users/MikeBeer/htdocs" enablereuse=on


How are parameters sent to the called Program?
string with the following format:
&var1=contents1&var2=contents2....
you may want to use the getvar function to read a variable

8000 is the port number and must match the port in FASTCGI.REXX or FASTCGI.REX
after that: your APACHE DocumentRoot



Tested with Apache 2.4.63 win 64 and mod_fcgi (https://www.apachelounge.com/download/)
