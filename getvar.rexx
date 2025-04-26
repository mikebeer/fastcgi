/* getvar - get data from buffer */
parse arg buf,varname,default,no_urldecode

if right(buf,1)<>"&" then buf=buf||"&"
if left(buf,1)<>"&" then buf="&"||buf

if varname<>"REFERER" then do
   end=pos("&REFERER",buf)
   if end>0 then buf=left(buf,end-1)
   end

p=pos("&"||varname||"=",buf)

/* check, if variable is part of buffer */

if p<1 then do
   if default<>"" then return default
   else return ""
end


str=substr(buf,p+1)
p=pos("=",str)
q=pos("&",str)
str=substr(str,p+1,q-p-1)

if no_urldecode="" then str=url2text(str) /*urlencode->text */

return str
