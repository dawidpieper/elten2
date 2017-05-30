#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module Network
    def download(source,destination)
  source.delete!("\r\n")
  destination.delete!("\r\n")
  $downloadcount = 0 if $downloadcount == nil
    source.sub!("?","?eltc=#{$downloadcount.to_s(36)}\&") if source.include?($url)
  $downloadcount += 1
    ef = 0
  begin
  ef = Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,utf8(source),utf8(destination),0,nil)
rescue Exception
  Graphics.update
  retry
end
  Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(utf8(source))
  if FileTest.exist?(destination) == false and source.include?("php")
    writefile(destination,-4)
  else
    if File.extname(destination).downcase == ".php"
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
      def connect(ip,port,data,len=2048)
    addr = Socket.sockaddr_in(port.to_i, ip)
  sock = Socket.new(2,0,0)
sock.connect(addr).to_s
t = 0
ti = Time.now.to_i
s = false
if data.size <= 1048576
begin
s = sock.send(data) if s == false
rescue Exception
  loop_update
  retry
end
else
  speech("Wysyłanie...")
    places = []
  plc = (data.size / 524288).to_i
for i in 0..plc-1
  places.push(data[i*524288..((i+1)*524288)-1])
end
places.push(data[(plc)*524288..data.size-1])
speech_wait
sent = ""
  for i in 0..places.size-1
                loop_update
        speech(((i.to_f/(plc.to_f+1.0))*100.0).to_i.to_s+"%") if speech_actived == false
                  s = false
  begin
s = sock.send(places[i]) if s == false
sent += places[i]
rescue Exception
  loop_update
  retry
end
end
end
b = ""
t = 0
b = sock.recv(len)
sock.close
return b
end
          def hexspecial(t)
            if $interface_hexspecial == 1
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
          
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper