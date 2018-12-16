#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

$usebass=true
module Bass
  BASS_GetVersion = Win32API.new("bass", "BASS_GetVersion", "", "I")
  BASS_ErrorGetCode = Win32API.new("bass", "BASS_ErrorGetCode", "", "I")
  BASS_Init = Win32API.new("bass", "BASS_Init", "IIIIP", "I")
  BASS_RecordInit = Win32API.new("bass", "BASS_RecordInit", "I", "I")
  BASS_GetConfig = Win32API.new("bass", "BASS_GetConfig", "I", "I")
  BASS_SetConfig = Win32API.new("bass", "BASS_SetConfig", "II", "I")
  BASS_SetConfigPtr = Win32API.new("bass","BASS_SetConfigPtr",'ip','l')
  BASS_PluginLoad = Win32API.new("bass","BASS_PluginLoad",'p','i')
  BASS_Free = Win32API.new("bass", "BASS_Free", "", "I")
  BASS_Start = Win32API.new("bass", "BASS_Start", "", "I")
  BASS_Stop = Win32API.new("bass", "BASS_Stop", "", "I")
  BASS_Pause = Win32API.new("bass", "BASS_Pause", "", "I")
  BASS_SetVolume = Win32API.new("bass", "BASS_SetVolume", "I", "I")
  BASS_GetVolume = Win32API.new("bass", "BASS_GetVolume", "", "I")
  BASS_RecordStart = Win32API.new("bass", "BASS_RecordStart", "IIIIII", "I")
  BASS_Encode_Start = Win32API.new("bassenc", "BASS_Encode_Start", "IPIIII", "I")
  BASS_Encode_Stop = Win32API.new("bassenc", "BASS_Encode_Stop", "I", "I")
  BASS_SampleLoad = Win32API.new("bass", "BASS_SampleLoad", "IPIIIII", "I")
  BASS_SampleCreate = Win32API.new("bass", "BASS_SampleCreate", "IIIII", "I")
  BASS_SampleFree = Win32API.new("bass", "BASS_SampleFree", "I", "I")
  BASS_SampleGetChannel = Win32API.new("bass", "BASS_SampleGetChannel", "II", "I")
  BASS_SampleStop = Win32API.new("bass", "BASS_SampleStop", "I", "I")
  BASS_StreamCreateFile = Win32API.new("bass", "BASS_StreamCreateFile", "IPLIIII", "I")
  BASS_StreamCreateURL = Win32API.new("bass", "BASS_StreamCreateURL", "PIIII", "I")
  BASS_StreamFree = Win32API.new("bass", "BASS_StreamFree", "I", "I")
  BASS_ChannelFlags = Win32API.new("bass", "BASS_ChannelFlags", "III", "I")
  BASS_ChannelPlay = Win32API.new("bass", "BASS_ChannelPlay", "II", "I")
  BASS_ChannelStop = Win32API.new("bass", "BASS_ChannelStop", "I", "I")
  BASS_ChannelPause = Win32API.new("bass", "BASS_ChannelPause", "I", "I")
  BASS_ChannelGetData = Win32API.new("bass", "BASS_ChannelGetData", "IPI", "I")
  BASS_ChannelGetLength = Win32API.new("bass", "BASS_ChannelGetLength", "II", "I")
  BASS_ChannelGetAttribute = Win32API.new("bass", "BASS_ChannelGetAttribute", "IIP", "I")
  BASS_ChannelSetAttribute = Win32API.new("bass", "BASS_ChannelSetAttribute", "III", "I")
  BASS_ChannelSlideAttribute = Win32API.new("bass", "BASS_ChannelSlideAttribute", "IIII", "I")
  BASS_ChannelIsSliding = Win32API.new("bass", "BASS_ChannelIsSliding", "II", "I")
  BASS_ChannelIsActive = Win32API.new("bass", "BASS_ChannelIsActive", "I", "I")
  BASS_ChannelSeconds2Bytes = Win32API.new("bass", "BASS_ChannelSeconds2Bytes", "II", "I")
  BASS_ChannelBytes2Seconds = Win32API.new("bass", "BASS_ChannelBytes2Seconds", "IL", "I")
  BASS_ChannelGetPosition = Win32API.new("bass", "BASS_ChannelGetPosition", "II", "I")
  BASS_ChannelSetPosition = Win32API.new("bass", "BASS_ChannelSetPosition", "III", "I")
  BASS_StreamGetFilePosition = Win32API.new("bass", "BASS_StreamGetFilePosition", "II", "I")
  Errmsg = {
    1=>"MEM",2=>"FILEOPEN",3=>"DRIVER",4=>"BUFLOST",5=>"HANDLE",6=>"FORMAT",7=>"POSITION",8=>"INIT",
    9=>"START",14=>"ALREADY",18=>"NOCHAN",19=>"ILLTYPE",20=>"ILLPARAM",21=>"NO3D",22=>"NOEAX",23=>"DEVICE",
    24=>"NOPLAY",25=>"FREQ",27=>"NOTFILE",29=>"NOHW",31=>"EMPTY",32=>"NONET",33=>"CREATE",34=>"NOFX",
    37=>"NOTAVAIL",38=>"DECODE",39=>"DX",40=>"TIMEOUT",41=>"FILEFORM",42=>"SPEAKER",43=>"VERSION",44=>"CODEC",
    45=>"ENDED",-1=>" UNKNOWN"
  }

  def self.init(hWnd, samplerate = 44100)
return if @init==true
    @init=true
    if (BASS_GetVersion.call >> 16) != 0x0204 then
      raise("bass.dllバージョン2.4系以外には対応しておりません")
    end
    if BASS_Init.call(-1, samplerate, 4, hWnd, nil) == 0 then
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
      if BASS_PluginLoad.call("bassopus.dll") == 0 then
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
if BASS_PluginLoad.call("bassmidi.dll") == 0 then
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
    if BASS_PluginLoad.call("basswma.dll") == 0 then
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    if BASS_RecordInit.call(-1) == 0 then
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
        BASS_SetConfig.call(0, 1000)
BASS_SetConfig.call(1, 100)
BASS_SetConfig.call(11, 10000)
BASS_SetConfig.call(12, 10000)
BASS_SetConfig.call(15, 150)
BASS_SetConfig.call(21, 1)
BASS_SetConfig.call(24, 2)    
        end

  def self.free
    @init=false
    if BASS_Free.call == 0 then
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
  end

  def self.loadSample(filename, max = 1)
    return Sample.new(filename, max)
  end

  def self.loadStream(filename,pos=0)
    return Stream.new(filename,pos)
  end

  class Sample
    attr_reader :ch
    def initialize(filename, max = 1)
      if filename[0..3]=="http"
        return Bass::Stream.new(filename)
      else
        @handle = BASS_SampleLoad.call(0, utf8(filename), 0, 0, 0, max, 0x20000)
          end
      @ch=@handle
      if @handle == 0 then
        return Bass::Stream.new(filename)        
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
            end

    def free
      if BASS_SampleFree.call(@handle) == 0 then
        #raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def play(option = {})
      ch = BASS_SampleGetChannel.call(@handle, 0)
      if ch == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end

      if option[:loop] then
        if BASS_ChannelFlags.call(ch, 4, 4) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:pan] then
        if BASS_ChannelSetAttribute.call(ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:volume] then
        if BASS_ChannelSetAttribute.call(ch, 2, [option[:volume]].pack("f").unpack("I")[0]) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end

      if BASS_ChannelPlay.call(ch, 0) == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
      return ch
    end

    def setPan(ch, pan)
      if BASS_ChannelSetAttribute.call(ch, 3, [pan].pack("f").unpack("I")[0]) == -1 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def setVolume(ch, v)
      if BASS_ChannelSetAttribute.call(ch, 2, [v].pack("f").unpack("I")[0]) == -1 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def stop(ch = nil)
      if ch == nil then
        if BASS_SampleStop.call(@handle) == 0 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      else
        if BASS_ChannelStop.call(ch) == 0 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
    end
  end

  class Stream
    attr_reader :ch
    def initialize(filename,pos=0,tries=10)
      pos=pos.to_i          
            if filename[0..3]=="http"
        @ch = BASS_StreamCreateURL.call(utf8(filename), pos, 0, 0, 0)
                else
                  for i in 1..10      
                  @ch = BASS_StreamCreateFile.call(0, utf8(filename), pos, 0, 0, 0, 0)
                  if @ch==0
                                        Bass.init($wnd)
                  else
                    break
                  end
                  end
      end
      if @ch == 0 then
        return initialize(filename,pos=0,tries-1) if tries>0
                raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    BASS_ChannelSetPosition.call(@ch,0,1000000)
      end

    def free
      if BASS_StreamFree.call(@ch) == 0 then
        #raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def play(option = {})
      if option[:loop] then
        if BASS_ChannelFlags.call(@ch, 4, 4) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:pan] then
        if BASS_ChannelSetAttribute.call(@ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:frequency] then
        if BASS_ChannelSetAttribute.call(@ch, 3, [option[:frequency]].pack("f").unpack("I")[0]) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:volume] then
        if BASS_ChannelSetAttribute.call(@ch, 2, [option[:volume]].pack("f").unpack("I")[0]) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if BASS_ChannelPlay.call(@ch, 0) == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def pan=(pan)
      if BASS_ChannelSetAttribute.call(@ch, 3, [pan].pack("f").unpack("I")[0]) == -1 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def volume=(v)
      if BASS_ChannelSetAttribute.call(@ch, 2, [v].pack("f").unpack("I")[0]) == -1 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def stop
      if BASS_ChannelStop.call(@ch) == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end
    
    def seek(pt,flags=0)
      print("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}") if Win32API.new("bass","BASS_ChannelSetPosition",'iil','i').call(@ch,0,flags)==0
      end
    end
    
    class Record
    attr_reader :ch
    attr_reader :encoder
    def clb(param)
  p param
  end
    def initialize(file,freq=48000,quality=nil,flags=32768)
           @handle = BASS_RecordStart.call(freq, 2, flags, 0, 0, 0)
           @encoder = BASS_Encode_Start.call(@handle,"\"bin/opusenc.exe\" #{if quality!=nil;"--bitrate #{quality.to_s}";else;"";end} - \"#{file}\"",262144,0,0,0)
#@encoder = BASS_Encode_Start.call(@handle,"test.wav",64,0,0,0)
      @ch=@handle
      if @handle == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
      BASS_ChannelPlay.call(@handle,0)
      end

    def free
      if BASS_SampleFree.call(@handle) == 0 then
        #raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def play
            if BASS_ChannelPlay.call(@ch, 0) == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
      return ch
    end

    def stop(ch = nil)
        if BASS_ChannelStop.call(ch) == 0 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
        if BASS_Encode_Stop.call(@encoder) == 0 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end
  end
    
   class Sound
     attr_reader :channel
     attr_reader :type
     attr_reader :cls
     include Bass
     attr_reader :file
     def initialize(file,type=1, looper=false)
       @file=file
       @startposition=0
       ext=File.extname(file).downcase
              #type=0 if (ext==".wav" or ext==".opus" or ext==".m4a" or ext==".ogg" or ext==".mid") and getsize(file) < 16*1048576
       type=1 if file[0..3]=="http"
       @type=type
       case type
       when 1         
         begin
         @cls=Bass.loadStream(file)
         rescue Exception
       end
         if @cls==nil or (@cl != nil and @cls.ch==nil)
         if FileTest.exists?(file)
           waiting
loc="temp\\plr#{rand(36**6).to_s(36)}.wav"
           executeprocess("bin\\ffmpeg -y -i \"#{file}\" \"#{loc}\"",true)
                      waiting_end
           if FileTest.exists?(loc)
             file=loc
             @cls=Bass.loadStream(file)
             end
           end
         end
         when 4
           @cls=Bass::Record.new() #tu
         else
                      @cls=Bass.loadSample(file)
                    end
                    return nil if @cls==nil
                  @channel=@cls.ch
                                    @basefrequency=frequency
                                    BASS_ChannelFlags.call(channel, 4, 4) if looper==true
       end
       def playing?
                  playing
         end
       def playing
         if status == 1
           return true
         else
           return false
           end
         end
         def data(len=length(true))
           buf="\0"*len
           BASS_ChannelGetData.call(@channel,len,len.size)
           end
       def status
         @lastupdate=0 if @lastupdate==nil
         return 1 if @lastupdate<Time.now.to_i*1000000+Time.now.usec+50000
         BASS_ChannelIsActive.call(@channel)
         end
     def play
              @cls.play
     end
     def stop
       @cls.stop
     end
     def pause
       BASS_ChannelPause.call(@channel)
       end
     def free
       @cls.free if @closed!=true and @cls!=nil
       @closed=true
     end
     def close
       free
     end
     def closed
       return true if @closed
       return false
       end
     def frequency
       frq=[0].pack('f')
              BASS_ChannelGetAttribute.call(@channel,1,frq)
       return frq.unpack("f")[0].to_i
       end
     def frequency=(f)
              frq=[f].pack('f').unpack('i')[0]
       BASS_ChannelSetAttribute.call(@channel,1,frq)
       return frq
     end
          def pan
       pn=[0].pack('f')
       BASS_ChannelGetAttribute.call(@channel,3,pn)
       return pn.unpack("f")[0]
       end
     def pan=(n)
              pn=[n].pack('f').unpack('i')[0]
       BASS_ChannelSetAttribute.call(@channel,3,pn)
       return pn
     end
     def volume
       vol=[0].pack('f')
       BASS_ChannelGetAttribute.call(@channel,2,vol)
       return vol.unpack("f")[0]
       end
     def volume=(v)
              vol=[v].pack('f').unpack('i')[0]
       BASS_ChannelSetAttribute.call(@channel,2,vol)
       return vol
     end
def length(bytes=false)
            bts=BASS_ChannelGetLength.call(@channel,0)+@startposition
                     return bts if bytes==true
return [BASS_ChannelBytes2Seconds.call(@channel,bts)].pack("i").unpack("f")[0] if @type==0
return bts.to_f/(@basefrequency*4)
end
     def position(bytes=false,useold=true)
            bts=BASS_ChannelGetPosition.call(@channel,0)
            bts+=@startposition if useold==true
                     return bts if bytes==true
@basefrequency=frequency if @basefrequency==0                     
                    return bts.to_f/(@basefrequency*4)
end
def position=(val,bytes=false)
  val=0.15 if val<0.15
  return 0 if @closed
  @posupdated=true
  if @type == 100
    @updating=true
        val*=@basefrequency*4 if bytes==false
attribs=[]
for i in 1..4
  attribs[i]=[0].pack('f')
  BASS_ChannelGetAttribute.call(@channel,i,attribs[i])
  attribs[i]=attribs[i].unpack("i")[0]
end
        pl=playing
            cmp=BASS_StreamGetFilePosition.call(@channel,2).to_f/(length(true)-@startposition).to_f
                cmp=1 if cmp==1.0/0.0
                        if val>=length(true)
                  if val<=length(true)-frequency
          val=length(true)-frequency*4
        else
                    @updating=false
                    @omit=true
                    return
          end
                                                  end
                          @cls.stop
                  @cls.free
                                    @cls=Bass::Stream.new(@file,val*cmp)
                                        @startposition=val
    @channel=@cls.ch
for i in 1..attribs.size-1
    BASS_ChannelSetAttribute.call(@channel,i,attribs[i])
  end
      @cls.play if pl==true
      @updating=false
    else
        val*=@basefrequency*4 if bytes==false
        val=0 if val < 0
        i=0
        for i in 1..50
        if BASS_ChannelSetPosition.call(@channel,val,0) > 0
          break
        else
          val-=(val.to_f/10000.0).to_i
                    sleep(0.001)
          end
        end
    end
    return val     
    end
     
    def wait
      ld=0
            while length(true)==-1
        sleep(0.025)
        ld+=1
        break if (ld==400 and position<=0) or length(true)>=0
                end
      while position(true)<length(true)-128 or length(true)==0 or position(true)==0
        sleep(0.05)
                end
        pos=position
        l=length
        return
      while position<=0.03
        sleep(0.01)
        end
        BASS_ChannelFlags.call(@channel, 4, 4) if closed==false      
        loop do
                          sleep(0.01)
          sleep(0.01) while @updating  
            BASS_ChannelFlags.call(@channel, 4, 4) if closed==false if @closed!=true
                      return if @omit                                                  
                                                  @lastupdate=0 if @lastupdate==nil
         sleep(0.07) if @lastupdate<Time.now.to_i*1000000+Time.now.usec+70000
         @posupdated=false                               
         if position(false,false)<=0.07 and BASS_ChannelIsActive.call(@channel) == 1
                                                                                    break
                     end
           end
           return
      end
     
     end
end


#Copyright (C) 2014-2018 Dawid Pieper