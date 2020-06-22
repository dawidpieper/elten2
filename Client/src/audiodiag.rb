#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class AudioDiagnosis
  include Bass
    class ADIAG
    def inspect
      "Audio diagnosis copied to clipboard"
      end
    end
      class ADIAG2
    def inspect
      "Audio diagnosis saved on Desktop"
      end
    end
def self.in
  waiting
  ret=""
  f=ChildProc.new("cmd /c bin\\ffmpeg -list_devices true -f dshow -i dummy 2>\&1")
  r=""
    loop_update while f.avail==0
    t=Time.now.to_f
              while !r.include?("dummy: Immediate exit requested")
        loop_update
        r+=f.read if f.avail>0
        break if Time.now.to_f-t>5
                end
  ret="*** DEVICES ***\r\n"
  ret+=r
  ret+="\r\n\r\n"
  ret+="*** RECORDING ***"
        dev=nil
      for i in 0..10
      d=Recorder.devices
      break if d.size>0
      end
      d.keys.each {|k| dev=k if d[k]==$interface_microphone or (["",nil].include?($interface_microphone) and d[k]==Bass.default_microphone)}
      dev=d.keys[0] if dev==nil
        s="bin\\ffmpeg -y -f dshow -i audio=\"#{dev}\" "
  s+="-b:a 96k"
  s+=" \"#{Dirs.temp}\\test.opus\""
  ret+=s+"\r\n"
  f=ChildProc.new("cmd /c "+s+" 2>\&1")
  delay(1)
  ret+=f.read
  f.write("q")
  delay(1)
  ret+=f.read
  Clipboard.text=ret
  waiting_end
  return ADIAG.new
end
def self.wi(text)
  text+="\r\n"
writefile(@@file, readfile(@@file)+text)
end
def self.out
  @@file=Dirs.desktop+"\\elten_outdiag.txt"
  wi "-- Audio diagnosis test at "+sprintf("%04d-%02d-%02d %02d:%02d:%02d", Time.now.year, Time.now.month, Time.now.day, Time.now.hour, Time.now.min, Time.now.sec)
wi "Creating stream"
filename="https://elten-net.eu/srv/avatars/pajper"
@cha = BASS_StreamCreateURL.call(unicode(filename), 0, 0x80000000|0x200000, 0, 0)
wi "Stream created #{@cha}"
if @cha==0
  wi("Error code #{BASS_ErrorGetCode.call}")
  end
wi "Creating tempo"
@ch = BASS_FX_TempoCreate.call(@cha, 0)
wi "Tempo created #{@ch}"
if @ch==0
  wi("Error code #{BASS_ErrorGetCode.call}")
  end
@channel=@ch
wi "Getting frequency"
       frq=[0].pack('f')
              BASS_ChannelGetAttribute.call(@channel,1,frq)
       f=frq.unpack("f")[0].to_i
       wi "Frequency #{f}"
       wi "Setting flag 0x200000"
BASS_ChannelFlags.call(@channel, 0x200000, 0x200000)
wi "Setting flag 4"
BASS_ChannelFlags.call(@channel, 4, 4)
wi "Playing"
BASS_ChannelPlay.call(@channel, 0)
delay 5
wi "Stopping"
BASS_ChannelStop.call(@channel)
wi "Cleaning"
BASS_StreamFree.call(@cha)
BASS_StreamFree.call(@ch)
return ADIAG2.new
end
end