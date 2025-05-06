/************************************************/
/*                                              */
/*      fastcgi/REX  V1.0 (2025-05-26)          */
/*       REGINA Version                         */
/*      (c) by Michael Beer, 2025               */
/*                                              */
/************************************************/


call RxFuncAdd 'SockLoadFuncs', 'rxsock', 'SockLoadFuncs'   /* load socket support */
call SockLoadFuncs
call SockVariable 'respectlength', 1

port = 9000                                                 /* use PORT 8000 */
BUFSIZE = 4096                                             /* Buffer Size   */
CRLF = "0d0a"x
parms. = ""
sock. = ""
requests = ""  /* list of open requests */
env = "REGINA"

socket = SockSocket('AF_INET', 'SOCK_STREAM', 0)
if socket < 0 then do
   say "SockSocket() failed." sockpsock_errno()
   exit 2;
end


                                                           /* set socket options */

if SockSetSockOpt(socket, 'SOL_SOCKET', 'SO_REUSEADDR', 1) < 0 then do  /* reuse */
   say "SockSetSockOpt() failed" sockpsock_errno()
   exit 3;
end

server.!family = 'AF_INET';
server.!port = port;
server.!addr = 'INADDR_ANY';

if SockBind(socket, 'server.!') < 0 then do
   say "SockBind() failed" sockpsock_errno()
   exit 4;
end

if SockListen(socket, 1) \= 0 then do
   say "SockListen() failed" sockpsock_errno()
   exit 5;
end

say "************************************************"
say "*                                              *"
say "*      fastcgi/REXX up and running             *"
say "* PORT: "port "                                *"
say "* ENV : "env  "                                *"
say "*                                              *"
say "************************************************"

do forever
   ns = SockAccept(socket)
   if ns = -1 then do
      say "SockAccept() failed" sockpsock_errno()
      exit 6;
   end
   say "socket" ns "accepted"
   bytes  = SockRecv(ns, 'buf', BUFSIZE)
   if bytes  = -1 then do
      say "SockRecv() failed" sockpsock_errno()
      exit 7;
    end

/*
    do while bytes=BUFSIZE
       bytes  = SockRecv(ns, 'bufext', BUFSIZE)
       buf = buf || bufext
    end
*/

    do while length(buf)>0
       ret = read_fastcgi(ns)    /* read one record */
       parse var ret type id
    end

end

call SockClose socket

say "************************************************"
say "*                                              *"
say "*      fastcgi/REXX shutting down              *"
say "*                                              *"
say "************************************************"


exit



read_fastcgi: procedure expose buf parms. requests sock.
parse arg client_socket
/* returns request id */

say "REQUESTS:" requests

ret=read_hdr(buf)                                    /* header = 8 bytes */
parse var ret type len padlen id
buf = substr(buf,9)  /* remove header */

select
   when type=1 then do                               /* BEGIN REQUEST */
      s = left(buf,8)
      buf=substr(buf,9)
      role  = c2d(substr(s,1,1))*256 + c2d(substr(s,2,1))
      flags = c2d(substr(s,3,1))
      if wordpos(id,requests)=0 then requests=requests id
      sock.id = client_socket
      say "TYPE=1, ROLE="role "FLAGS="flags
      end

   when type=4 then do                                /* FCGI_PARAMS */
      say "TYPE=4"
      data = left(buf,len)
      buf = substr(buf, len + padlen +1)

      do while data<>""
         s=data
         l=1
         namlen = c2d(left(s,1))
         if namlen > 127 then do
            namlen  = (namlen-128)*256**3 + c2d(substr(s,2,1))*256**2 + c2d(substr(s,3,1))*256 + c2d(substr(s,4,1))
            l=4
         end
         data = substr(data,l+1)

         s=data
         l=1
         vallen = c2d(left(s,1))
         if vallen > 127 then do
            vallen  = (vallen-128)*256**3 + c2d(substr(s,2,1))*256**2 + c2d(substr(s,3,1))*256 + c2d(substr(s,4,1))
            l=4
         end
         data = substr(data,l+1)

         name  = left(data,namlen)
         data  = substr(data,namlen+1)
         value = left(data,vallen)
         data  = substr(data,vallen+1)
         say name " : " value
         parms.id.name = value
      end /* do while data... */
   end  /* when type 4 */

   when type=5 & len=0 then do                        /* end request */
      ret=action(id)
      end

   when type=5  then do                               /* get data from stdin */
      say "TYPE 5 (STDIN)"
      data = left(buf,len)
      buf = substr(buf, len + padlen +1)
      say ">"data"<"
      parms.id.QUERY_STRING = parms.id.QUERY_STRING"&"data
      end
   otherwise nop
end  /* select */
return type id

                                                      /* read header subroutine */
read_hdr:   procedure
parse arg s

version = c2d(substr(s,1,1))
type    = c2d(substr(s,2,1))
reqid   = c2d(substr(s,3,1))*256 + c2d(substr(s,4,1))
len     = c2d(substr(s,5,1))*256 + c2d(substr(s,6,1))
padlen  = c2d(substr(s,7,1))

say
say "Version:" version
say "Type:   " type
say "ID:     " reqid
say "len:    " len
say "padlen: " padlen

return type len padlen reqid


out: procedure
parse arg id,s                                        /* output to Apache */
version = 1
type    = 6   /*FCGI_STDOUT */
len     = length(s)
padlen  = 0
hi_byte = 0
lo_byte = 0
if len<256 then lo_byte=len
else do
   hi_byte = len % 256
   lo_byte = len // 256
end

s = d2c(version)||d2c(type)||d2c(0)||d2c(id)||d2c(hi_byte)||d2c(lo_byte)||d2c(padlen)||d2c(0)||s
return s

end_request: procedure
parse arg id                                          /* send send of request */
version = 1
type    = 3   /*END_REQUEST */
len     = 0
padlen  = 0

s = d2c(version)||d2c(type)||d2c(0)||d2c(id)||d2c(0)||d2c(len)||d2c(padlen)||d2c(0)
return s


/*********************************************/

action:                                           /* execute function and send result to Apache */
parse arg id

ns = sock.id   /* get client socket */

dir = parms.id.DOCUMENT_ROOT
pgm = parms.id.SCRIPT_NAME
pgm = changestr(".rexx",pgm,"")
pgm = changestr(".REXX",pgm,"")
if left(pgm,1)="/" then pgm=substr(pgm,2)
parms=parms.id.QUERY_STRING                   /* get parms for function call */
s="ret="pgm"('"parms"')"                      /* prepare REXX function call */
currdir=directory()
ret=directory(dir)
interpret s                                   /* execute function with parms */

s = ret
say "send to id" id "via socket" ns
s=out(id,s)                    /* send to id returned before from read_fastcgi */

ret=SockSend(ns, s)
s=out(id,"")
ret=SockSend(ns, s)

s=end_request(id)
ret=SockSend(ns, s)

say "socksend to" ns "ret=" ret
  if ret<0 then do
     say "SockSend() failed" sockpsock_errno()
     exit;
  end

call SockClose ns

pos = wordpos(id,requests)
requests = delword(requests,pos,1)
parms.id = ""

return ns
