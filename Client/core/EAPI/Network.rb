#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  # The Network related functions
  module Network
    # Downloads a file
    #
    # @param source [String] an URL of a file to download
    # @param destination [String] the file destination
    # @param threading [Boolean] use threading to download, recommended for large files
    # @return [Numeric] if the function succeeds, the return value is 0. Otherwise, the return value is an urlmon error code.
    # @example Downloading Onet main page with threading enabled
    #  download("http://onet.pl","onet.html",true)
    def download(source,destination,threading=false)
        source.delete!("\r\n")
  destination.delete!("\r\n")
  $downloadcount = 0 if $downloadcount == nil
    source.sub!("?","?eltc=#{$downloadcount.to_s(36)}\&") if source.include?($url)
  $downloadcount += 1
    $ef = -1
  $downloading = true
  ef=0
    begin
      if threading==true
  Thread.new do
    begin
      $ef = Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,utf8(source),utf8(destination),0,nil)
          rescue Exception
      retry
      end
    end
i=0
    while $ef == -1
    i+=1
return -1 if i > 100  
  end
    ef=$ef
  else
    $ef = Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,utf8(source),utf8(destination),0,nil)
    end
rescue Exception
    Graphics.update
  retry
end
$downloading = false
  Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(utf8(source))
  if FileTest.exist?(destination) == false and (source.include?("php"))
    writefile(destination,-4)
  else
    if source.downcase.include?(".php") or source.downcase.include?(".eapi")
          des = read(destination)
    if des[0] == 239 and des[1] == 187 and des[2] == 191
            des = des[3..des.size-1]
      File.delete(destination)
      writefile(destination,des)
            end
        end
end
        return ef
      end
      
      # @deprecated use WinSock interface instead
      def connect(ip,port,data,len=2048,msg="Wysyłanie...")
            addr = Socket.sockaddr_in(port.to_i, ip)
          sock = Socket.new(2,0,0)
sock.connect(addr).to_s
sock
t = 0
ti = Time.now.to_i
s = false
if data.size <= 1048576
  begin
if $ruby != true
  s = sock.send(data) if s == false
else
  s = sock.write(data) if s == false
  end
#rescue Exception
  #loop_update
  #retry
end
else
  speech(msg)
  waiting  
  places = []
until data.empty?
  places << data.slice!(0..524287)
end
  sent = ""
begin
for i in 0..places.size-1
    loop_update
        speech(((i.to_f/(places.size.to_f+1.0))*100.0).to_i.to_s+"%") if speech_actived == false
        if $ruby != true                    
        s = sock.send(places[i])
      else
        s = sock.write(places[i])
        end
end
rescue Exception
loop_update
sock = Socket.new(2,0,0)
sock.connect(addr).to_s
retry
end
waiting_end
end
b = ""
t = 0
b = sock.recv(len)
sock.close
return b
end

# @deprecated use {#urlenc} instead.
          def hexspecial(t)
            if $advanced_hexspecial == 1
            t = t.gsub("ą","%C4%85")
            t = t.gsub("ć","%C4%87")
            t = t.gsub("ę","%C4%99")
            t = t.gsub("ł","%C5%82")
            t = t.gsub("ń","%C5%84")
            t = t.gsub("ó","%C3%B3")
            t = t.gsub("ś","%C5%9B")
            t = t.gsub("ź","%C5%BA")
            t = t.gsub("ż","%C5%BC")
            t = t.gsub("Ą","%C4%84")
            t = t.gsub("Ć","%C4%86")
            t = t.gsub("Ę","%C4%98")
            t = t.gsub("Ł","%C5%81")
            t = t.gsub("Ń","%C5%83")
            t = t.gsub("Ó","%C3%B2")
            t = t.gsub("Ś","%C5%9A")
            t = t.gsub("Ź","%C5%B9")
            t = t.gsub("Ż","%C5%BB")
            end
            return t
          end
          
          # @deprecated use {#urlenc} instead.
          def hexstring(stri)
            stro = ""
t = 0
            for i in 0..stri.size-1
              t = t + 1
              if t > 10000
                loop_update
                play("list_focus")
                t = 0
                end
              stro += "%" + stri[i].to_s(16)
              end
            return stro
          end
          
          # Downloads a file, creates download progress dialog
          #
          # @param url [String] an URL of a file to download
          # @param destination [String] location to an output file
          # @param msg [String] downloading dialog header
          def downloadfile(url,destination,msg="Pobieranie...",msgcomplete=nil)
            host=$url
            port=80
          cnt=""
          if (/https?:\/\/([a-zA-Z0-9\-.,ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]+)([\:0-9]+)?\/([a-zA-Z0-9\-.,\/\?_\+\=\&ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]+)/=~url)!=nil
                        host=$1
            port=$2.to_i if $2.to_i!=0
                        cnt = $3
                      end
                                            addr = Socket.sockaddr_in(port.to_i, host)
                                            sock = Socket.new(2,0,0)
sock.connect(addr).to_s
data = "GET /#{cnt} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\n\r\n"
if $ruby != true
  s = sock.send(utf8(data))
else
  s = sock.write(data)
end
ans={}
o=""
loop do
  b=""
  while b.include?("\n")==false
  s=sock.recv(1)
  b+=s if s!=nil and s!="\0"
end
o+=b
break if b=="\n" or b=="\r\n"
key=""
  val=""
  if (/([a-zA-Z0-9\-]+)\: ([a-zA-Z0-9\/\:\-,.\/\\_\+!@ ]+)\r?\n/=~b)!=nil
  key=$1
  val=$2
    end
    ans[key.downcase]=val if key!=""
  end
      l=ans["content-length"].to_i
tx=""
waiting
speech(msg)
sptm=Time.now.to_i
i=0
while i<l
  b=""
  while b==nil or b==""
    sz=262144
    sz=l-i if l-i<sz
    b=sock.recv(sz)
                end
  i+=b.size
    loop_update
    if sptm+3<Time.now.to_i
    sptm=Time.now.to_i
    speech("#{((i.to_f/l.to_f*100.0).round).to_s}%") if speech_actived==false
    end
      tx+=b
  end
tx=tx[0..l-1]
  writefile(destination,tx)
  waiting_end
  speech(msgcomplete) if msgcomplete!=nil
end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper