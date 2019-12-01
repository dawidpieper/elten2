#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
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
    ef = -1
  $downloading = true
  ef=0
    begin
      if threading==true
  Thread.new do
    begin
      ef = Win32API.new("urlmon","URLDownloadToFileW",'pppip','i').call(nil,unicode(source),unicode(destination),0,nil)
          rescue Exception
      #retry
      end
    end
i=0
    while ef == -1
    i+=1
return -1 if i > 100  
  end
      else
            ef = Win32API.new("urlmon","URLDownloadToFileW",'pppip','i').call(nil,unicode(source),unicode(destination),0,nil)
    end
rescue Exception
    Graphics.update
  #retry
end
play("signal") if $netsignal==true
$downloading = false
  Win32API.new("wininet","DeleteUrlCacheEntryW",'p','i').call(unicode(source))
  if FileTest.exist?(destination) == false and (source.include?("php"))
    writefile(destination,-4)
  else
    if source.downcase.include?(".php") or source.downcase.include?(".eapi")
          des = readfile(destination)
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
      def connect(ip,port,data,len=2048,msg=_("EAPI_Network:wait_sending"))
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
b
return b
end
          
          # Downloads a file, creates download progress dialog
          #
          # @param url [String] an URL of a file to download
          # @param destination [String] location to an output file
          # @param msg [String] downloading dialog header
          def downloadfile(url,destination,msg="",msgcomplete=nil, override=nil)
                        return if override==nil and FileTest.exists?(destination) and confirm(_("EAPI_Network:alert_override"))==0
                        Log.debug("Downloading file: #{url}")
            play("signal") if $netsignal==true
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
  s = sock.send(data)
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
waiting if msg!=nil
speech(msg)
sptm=Time.now.to_i
i=0
sil=false
cf = Win32API.new("kernel32","CreateFileW",'piipiip','i')
handle = cf.call(unicode(destination),2,1|2|4,nil,2,0,nil)
wrfile = Win32API.new("kernel32","WriteFile",'ipipi','I')
bp = [0].pack("l")
while i<l
  b=""
  while b==nil or b==""
    sz=262144
    sz=l-i if l-i<sz
    b=sock.recv(sz)
                end
  i+=b.size
    loop_update
    if space
    if sil==false
      sil=true
      alert(_("EAPI_Network:info_progressdonotread"))
    else
      sil=false
      alert(_("EAPI_Network:info_readprogress"))
    end
    end
    if sptm+3<Time.now.to_i
    sptm=Time.now.to_i
    speech("#{((i.to_f/l.to_f*100.0).round).to_s}%") if speech_actived==false and sil==false
    end
    tx+=b  
    if tx.size>16*1048576 or i>=l
          r = wrfile.call(handle,tx,tx.size,bp,0)
            tx=""
      end
      b=""
        end
  Win32API.new("kernel32","CloseHandle",'i','i').call(handle)
  #writefile(destination,tx)
  waiting_end if msg!=nil
  speech(msgcomplete) if msgcomplete!=nil
end
  end
end
#Copyright (C) 2014-2019 Dawid Pieper