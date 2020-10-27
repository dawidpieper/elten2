require 'securerandom'
secret=""
str='#ifndef ELTAUTOGEN_SIG
#define ELTAUTOGEN_SIG
#define SHA_SIG1 "'
b=IO.binread("sha_sig1.txt")
for i in 0..19
str+="\\x"+b.getbyte(i).to_s(16).rjust(2,"0")
end
str += '"
#define SHA_SIG2 "'
b=IO.binread("sha_sig2.txt")
for i in 0..19
str+="\\x"+b.getbyte(i).to_s(16).rjust(2,"0")
end
str += '"
#define SHA_SIG3 "'
b=IO.binread("sha_sig3.txt")
for i in 0..19
str+="\\x"+b.getbyte(i).to_s(16).rjust(2,"0")
end
str += '"
#define SHA_SIG4 "'
b=IO.binread("sha_sig4.txt")
for i in 0..19
str+="\\x"+b.getbyte(i).to_s(16).rjust(2,"0")
end
str += '"
#endif'
IO.write("autogen_sig.h",str)

if $*.include?("/n")
str='#ifndef ELTAUTOGEN_SEC
#define ELTAUTOGEN_SEC
#define SECR "'
b=SecureRandom.bytes(16380)
for i in 0...b.bytesize
str+="\\x"+b.getbyte(i).to_s(16).rjust(2,"0")
end
str+='"
#define genkey(s,key) ({'
secs=[]
for i in 0..31
secs[i]=rand(b.bytesize)
str+="key[#{i.to_s}]=s[#{secs[i].to_s}];"
secret+=b[secs[i]]
end
str+='})
#endif'
str.delete!("\r")
IO.write("autogen_secr.h",str)
IO.write("secret.txt",secret)
p secret
end