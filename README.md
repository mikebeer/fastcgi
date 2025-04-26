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



Tested with Apache 2.4.63 win 64 and mod_fcgi (https://www.apachelounge.com/download/)
