/* url2text.rexx - translate special chars */
parse arg data
CR='0d'x
LF='0a'x

data=changestr("+",data," ")

data=changestr("%C3%A4",data,"ä")
data=changestr("%C3%B6",data,"ö")
data=changestr("%C3%BC",data,"ü")

data=changestr("%C3%84",data,"Ä")
data=changestr("%C3%96",data,"Ö")
data=changestr("%C3%9C",data,"Ü")
data=changestr("%C3%9F",data,"ß")

/*
data=changestr("%C3%A4",data,"ae")
data=changestr("%C3%B6",data,"oe")
data=changestr("%C3%BC",data,"ue")
data=changestr("%C3%9F",data,"Ae")
data=changestr("%C3%84",data,"Oe")
data=changestr("%C3%96",data,"Ue")
data=changestr("%C3%9C",data,"ss")
*/

/*
data=changestr("%C3%A4",data,"„")
data=changestr("%C3%B6",data,"”")
data=changestr("%C3%BC",data,"")
data=changestr("%C3%9F",data,"á")
data=changestr("%C3%84",data,"Ž")
data=changestr("%C3%96",data,"™")
data=changestr("%C3%9C",data,"š")
*/
data=changestr("%E4",data,"„")
data=changestr("%C4",data,"Ž")
data=changestr("%F6",data,"”")
data=changestr("%D6",data,"™")
data=changestr("%FC",data,"")
data=changestr("%DC",data,"š")
data=changestr("%DF",data,"á")
data=changestr("%0D",data,CR)
data=changestr("%0A",data,LF)
data=changestr("%20",data," ")
data=changestr("%27",data,"'")
data=changestr("%2A",data,"*")
data=changestr("%DC",data,"š")
data=changestr("%3C",data,"<")
data=changestr("%3B",data,";")
data=changestr("%3D",data,"=")
data=changestr("%3E",data,">")
data=changestr("%3A",data,":")
data=changestr("%2F",data,"/")
data=changestr("%3F",data,"?")
data=changestr("%21",data,"!")
data=changestr("%22",data,'"')
data=changestr("%23",data,'#')
data=changestr("%24",data,'$')
data=changestr("%25",data,'%')
data=changestr("%26",data,'&')
data=changestr("%28",data,"(")
data=changestr("%29",data,")")
data=changestr("%2C",data,",")
data=changestr("%2B",data,"+")
data=changestr("%40",data,"@")
data=changestr("%26",data,"&")
data=changestr("%5B",data,"[")
data=changestr("%5D",data,"]")
data=changestr("%7B",data,"{")
data=changestr("%7C",data,"|")
data=changestr("%7D",data,"}")
return data
