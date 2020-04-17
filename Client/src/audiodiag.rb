#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

  class ADIAG
    def inspect
      "Audio diagnosis copied to clipboard"
      end
    end
def audiodiag
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
  s+=" \"#{$tempdir}\\test.opus\""
  ret+=s+"\r\n"
  f=ChildProc.new("cmd /c "+s+" 2>\&1")
  delay(1)
  ret+=f.read
  f.write("q")
  delay(1)
  ret+=f.read
  Clipboard.set_data(unicode(ret), 13)
  waiting_end
  return ADIAG.new
  end