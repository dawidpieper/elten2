# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

module Bass
  ENV['path']+=";.\\bin"
  BassLib="bin\\bass"
  BassfxLib="bin\\bass_fx"
  BassmixLib="bin\\bassmix"
  BASS_GetVersion = Win32API.new(BassLib, "BASS_GetVersion", "", "I")
  BASS_ErrorGetCode = Win32API.new(BassLib, "BASS_ErrorGetCode", "", "I")
  BASS_Init = Win32API.new(BassLib, "BASS_Init", "IIII", "I")
  BASS_RecordInit = Win32API.new(BassLib, "BASS_RecordInit", "I", "I")
  BASS_GetConfig = Win32API.new(BassLib, "BASS_GetConfig", "I", "I")
  BASS_SetConfig = Win32API.new(BassLib, "BASS_SetConfig", "II", "I")
  BASS_SetConfigPtr = Win32API.new(BassLib,"BASS_SetConfigPtr",'ip','l')
  BASS_SetDevice = Win32API.new(BassLib,"BASS_SetDevice",'i','i')
  BASS_GetDeviceInfo = Win32API.new(BassLib,"BASS_GetDeviceInfo",'ip','i')
  BASS_RecordGetDeviceInfo = Win32API.new(BassLib,"BASS_RecordGetDeviceInfo",'ip','i')
  BASS_PluginLoad = Win32API.new(BassLib,"BASS_PluginLoad",'p','i')
  BASS_Free = Win32API.new(BassLib, "BASS_Free", "", "I")
  BASS_RecordFree = Win32API.new(BassLib, "BASS_RecordFree", "", "I")
  BASS_Apply3D = Win32API.new(BassLib,"BASS_Apply3D",'','i')
  BASS_Start = Win32API.new(BassLib, "BASS_Start", "", "I")
  BASS_Stop = Win32API.new(BassLib, "BASS_Stop", "", "I")
  BASS_Pause = Win32API.new(BassLib, "BASS_Pause", "", "I")
  BASS_SetVolume = Win32API.new(BassLib, "BASS_SetVolume", "I", "I")
  BASS_GetVolume = Win32API.new(BassLib, "BASS_GetVolume", "", "I")
  BASS_RecordStart = Win32API.new(BassLib, "BASS_RecordStart", "IIIIII", "I")
  BASS_SampleLoad = Win32API.new(BassLib, "BASS_SampleLoad", "IPIIIII", "I")
  BASS_SampleCreate = Win32API.new(BassLib, "BASS_SampleCreate", "IIIII", "I")
  BASS_SampleFree = Win32API.new(BassLib, "BASS_SampleFree", "I", "I")
  BASS_SampleGetChannel = Win32API.new(BassLib, "BASS_SampleGetChannel", "II", "I")
  BASS_SampleStop = Win32API.new(BassLib, "BASS_SampleStop", "I", "I")
  BASS_StreamCreateFile = Win32API.new(BassLib, "BASS_StreamCreateFile", "IPLIIII", "I")
  BASS_StreamCreateURL = Win32API.new(BassLib, "BASS_StreamCreateURL", "PIIII", "I")
  BASS_StreamFree = Win32API.new(BassLib, "BASS_StreamFree", "I", "I")
  BASS_ChannelFlags = Win32API.new(BassLib, "BASS_ChannelFlags", "III", "I")
  BASS_ChannelPlay = Win32API.new(BassLib, "BASS_ChannelPlay", "II", "I")
  BASS_ChannelStop = Win32API.new(BassLib, "BASS_ChannelStop", "I", "I")
  BASS_ChannelPause = Win32API.new(BassLib, "BASS_ChannelPause", "I", "I")
  BASS_ChannelGetData = Win32API.new(BassLib, "BASS_ChannelGetData", "IPI", "I")
  BASS_ChannelGetLength = Win32API.new(BassLib, "BASS_ChannelGetLength", "II", "L")
  BASS_ChannelGetAttribute = Win32API.new(BassLib, "BASS_ChannelGetAttribute", "IIP", "I")
  BASS_ChannelSetAttribute = Win32API.new(BassLib, "BASS_ChannelSetAttribute", "III", "I")
  BASS_ChannelSlideAttribute = Win32API.new(BassLib, "BASS_ChannelSlideAttribute", "IIII", "I")
  BASS_ChannelIsSliding = Win32API.new(BassLib, "BASS_ChannelIsSliding", "II", "I")
  BASS_ChannelIsActive = Win32API.new(BassLib, "BASS_ChannelIsActive", "I", "I")
  BASS_ChannelSeconds2Bytes = Win32API.new(BassLib, "BASS_ChannelSeconds2Bytes", "III", "I")
  BASS_ChannelBytes2Seconds = Win32API.new(BassLib, "BASS_ChannelBytes2Seconds", "IL", "I")
  BASS_ChannelGetPosition = Win32API.new(BassLib, "BASS_ChannelGetPosition", "II", "I")
  BASS_ChannelGetInfo = Win32API.new(BassLib, "BASS_ChannelGetInfo", "IP", "I")
  BASS_ChannelSetPosition = Win32API.new(BassLib, "BASS_ChannelSetPosition", "ILLL", "I")
  BASS_ChannelSet3DPosition = Win32API.new(BassLib, "BASS_ChannelSet3DPosition", "IPPP", "I")
  BASS_StreamGetFilePosition = Win32API.new(BassLib, "BASS_StreamGetFilePosition", "II", "I")
  BASS_Mixer_StreamCreate = Win32API.new(BassmixLib, "BASS_Mixer_StreamCreate", 'iii', 'i')
  BASS_Mixer_StreamAddChannel = Win32API.new(BassmixLib, "BASS_Mixer_StreamAddChannel", 'iii', 'i')
  
  Errmsg = {
    1=>"MEM",2=>"FILEOPEN",3=>"DRIVER",4=>"BUFLOST",5=>"HANDLE",6=>"FORMAT",7=>"POSITION",8=>"INIT",
    9=>"START",14=>"ALREADY",18=>"NOCHAN",19=>"ILLTYPE",20=>"ILLPARAM",21=>"NO3D",22=>"NOEAX",23=>"DEVICE",
    24=>"NOPLAY",25=>"FREQ",27=>"NOTFILE",29=>"NOHW",31=>"EMPTY",32=>"NONET",33=>"CREATE",34=>"NOFX",
    37=>"NOTAVAIL",38=>"DECODE",39=>"DX",40=>"TIMEOUT",41=>"FILEFORM",42=>"SPEAKER",43=>"VERSION",44=>"CODEC",
    45=>"ENDED",-1=>" UNKNOWN"
  }

  def self.soundcards
    BASS_SetConfig.call(36, 1)
    BASS_SetConfig.call(42, 1)
    ret=[]
    index=0
      tmp=[nil,nil,0].pack("ppi")
      while BASS_GetDeviceInfo.call(index,tmp)>0
        a=tmp.unpack("ii")
        o="\0"*1024
        Win32API.new("msvcrt","strcpy",'pp','i').call(o,a[0])
                sc=(o[0...o.index("\0")])
                name=sc.delete("\0")
                       ret.push(name)
        index+=1
      end
    return ret
    end

    def self.microphones
      microphones=[]
        index=0
      tmp=[nil,nil,0].pack("ppi")
      while BASS_RecordGetDeviceInfo.call(index,tmp)>0
        a=tmp.unpack("iii")
                o="\0"*1024
        Win32API.new("msvcrt","wcscpy",'pp','i').call(o,a[0])
                sc=o[0...o.index("\0")||-1]
        microphones.push(sc)
               index+=1
             end
                          return microphones
    end
    
    def self.setdevice(d,hWnd=nil, samplerate=48000)
      $soundthemesounds.values.each {|g| g.close if g!=nil and !g.closed} if $soundthemesounds!=nil
      $soundthemesounds={}
            hWnd||=$wnd||0
            @@device=d
            if @init==true
            BASS_Free.call
      BASS_Init.call(d, samplerate, 4, hWnd)
      BASS_SetDevice.call(d)
    else
      @setdeviceoninit=d
      end
    end
    
    @@recorddevice=-1
    @@recordinit=false
    def self.setrecorddevice(i)
      @@recorddevice=i
      BASS_RecordFree.call if @@recordinit
      @@recordinit=false
      end
    
    def self.reset
      self.setdevice(@@device)
    end
    
    def self.test
      filename="Audio/BGS/waiting.ogg"
      h=BASS_StreamCreateFile.call(0, unicode(filename), 0, 0, 0, 0, 0x80000000|0x200000)
      if h==0
        return false
      end
      BASS_StreamFree.call(h)
      return true
    end
    
    def self.record_prepare
      if @@recordinit==false
              BASS_RecordInit.call(@@recorddevice)
              @@recordinit=true
              end
      end
    
  def self.init(hWnd, samplerate = 48000)
return if @init==true
    @init=true
    BASS_SetConfig.call(36, 1)
    if (BASS_GetVersion.call >> 16) != 0x0204 then
      raise("bass.dllバージョン2.4系以外には対応しておりません")
    end
      devs=[]
     card=-1
     card=@setdeviceoninit if @setdeviceoninit!=nil
    @@device=card
        if BASS_Init.call(card, samplerate, 4, hWnd) == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
    plugins = ["bassopus", "bassflac", "bassmidi", "basswebm", "basswma", "bass_aac", "bass_ac3", "bass_spx"]
    for pl in plugins
          if BASS_PluginLoad.call("bin\\#{pl}.dll") == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
    end
        BASS_SetConfig.call(0, 1000)
BASS_SetConfig.call(1, 100)
BASS_SetConfig.call(11, 3000)
BASS_SetConfig.call(12, 10000)
BASS_SetConfig.call(15, 25)
BASS_SetConfigPtr.call(16, "Elten")
BASS_SetConfig.call(21, 1)
BASS_SetConfig.call(0x20000, 0)    
BASS_SetDevice.call(card) if card>0
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

  def self.loadStream(filename,pos=0, u3d=false,stream=nil)
    return Stream.new(filename,pos, 10, u3d,stream)
  end
  
  
    class Sample
    @@exiters={}
    attr_reader :ch
        def initialize(filename, max = 1)
                    ObjectSpace.define_finalizer(self,
          self.class.method(:finalize).to_proc)
           if filename[0..3]=="http"
        return Bass::Stream.new(filename)
      else
        @handle = BASS_SampleLoad.call(0, unicode(filename), 0, 0, 0, max, 0x20000|0x80000000|0x200000)
      end
      @@exiters[self.id]=[@handle]
      @ch=BASS_SampleGetChannel.call(@handle,0)
      if @handle == 0 then
        return Bass::Stream.new(filename)        
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
            end

            def newchannel
              @ch=BASS_SampleGetChannel.call(@handle,0)
              end
    def free
      BASS_SampleFree.call(@handle)
        @@exiters[self.id]=nil
    end

    def self.finalize(id)
      if @@exiters[id].is_a?(Array)
        for e in @@exiters[id]
  BASS_SampleFree.call(e)
end
@@exiters[id]=nil
end
end
    
    def play(option = {})
      ch = @ch||BASS_SampleGetChannel.call(@handle, 1)
      if ch == 0 then
        return
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end

      if false
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
      end
#BASS_ChannelSetAttribute.call(ch, 2, [0.1].pack("f").unpack("I")[0])
      if BASS_ChannelPlay.call(ch, 0) == 0 then
        err=BASS_ErrorGetCode.call
          if err==9
            Bass.reset
            return
            end
        raise("BASS_ERROR_#{Errmsg[err]}")
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
        @@exiters={}
        
    attr_reader :ch
    def initialize(filename,pos=0,tries=10, u3d=false, stream=nil)
      ObjectSpace.define_finalizer(self,
  self.class.method(:finalize).to_proc)
      pos=pos.to_i          
      flags=0
      flags|=0x200000 if Configuration.usefx==1
      @stream=stream
      @@exiters[self.id]=[]
            if filename==nil && stream!=nil
                                    @cha = BASS_StreamCreateFile.call(1,@stream, 0, 0, @stream.bytesize, 0, flags)
                                                        elsif filename[0..3]=="http"
                      @cha = BASS_StreamCreateURL.call(unicode(filename), pos, 0x80000000|flags, 0, 0)
                else
                  for i in 1..10      
                                      @cha = BASS_StreamCreateFile.call(0, unicode(filename), pos, 0, 0, 0, flags|0x80000000|flags|0x20000)
                  if @cha==0
                                        Bass.init($wnd)
                  else
                    break
                  end
                  end
                end
                      if @cha == 0
        return initialize(filename,pos=0,tries-1) if tries>0 and !$DEBUG
                #print("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
              end
              @@exiters[self.id].push(@cha)
              if Configuration.usefx == 1
              @@BASS_FX_TempoCreate ||= Win32API.new(BassfxLib, "BASS_FX_TempoCreate", 'ii', 'i')
                      @ch = @@BASS_FX_TempoCreate.call(@cha, 0)
                      @@exiters[self.id].push(@ch)
                    else
                      @ch=@cha
                      end
                                                                  end

    def free
      return if @ch==0
      if BASS_StreamFree.call(@ch) == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
      if @ch!=@cha
        if BASS_StreamFree.call(@cha) == 0 then
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
        end
      end
      
      def self.finalize(id)
              if @@exiters[id].is_a?(Array)
        for e in @@exiters[id]
  BASS_StreamFree.call(e)
end
@@exiters[id]=nil
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
        if BASS_ChannelSetAttribute.call(@ch, 4, [option[:volume]].pack("f").unpack("I")[0]) == -1 then
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if BASS_ChannelPlay.call(@ch, 0) == 0 then
        return nil
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
      #print("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}") if Win32API.new(BassLib,"BASS_ChannelSetPosition",'iil','i').call(@ch,0,flags)==0
      end
    end
    
   class Sound
     attr_reader :file
     attr_reader :channel
     attr_reader :type
     attr_reader :cls
     include Bass
     attr_reader :file
     attr_reader :basefrequency
     def initialize(file,type=1, looper=false, u3d=false, stream=nil)
       @looper=looper
              @file=file
       @startposition=0
       if file!=nil
       ext=File.extname(file).downcase
       type=1 if file[0..3]=="http"
     else
       type=1
       end
       @type=type
              case type
              when 1         
                         begin
         @cls=Bass.loadStream(file,0,u3d,stream)
                rescue Exception
         Log.error("Cannot play audio file: #{file}")
       end
         else
                      @cls=Bass.loadSample(file)
                                          end
                    return nil if @cls==nil
                  @channel=@cls.ch
                                    @basefrequency=frequency
                                    BASS_ChannelFlags.call(@channel, 0x200000, 0x200000)
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
         def channels
           rinfo=[0, 0, 0, 0, 0, 0, 0, ''].pack("iiiiiiip")
           BASS_ChannelGetInfo.call(@channel, rinfo)
           info=rinfo.unpack("iiiiiii")
           return info[1]
         end
         def data(len=length(true))
           buf="\0"*len
           BASS_ChannelGetData.call(@channel,len,len.size)
           end
       def status
         @lastupdate=0 if @lastupdate==nil
         return 1 if @lastupdate<Time.now.to_i*1000000+Time.now.usec+50000
         BASS_ChannelIsActive.call(@cls)
         end
     def play
              #@cls.play if @cls!=nil
              BASS_ChannelPlay.call(@channel, 0) if @cls!=nil
     end
     def stop
       @cls.stop if @cls!=nil
     end
     def pause
       BASS_ChannelPause.call(@channel) if @cls!=nil
       end
     def free
       @stream=nil
       if @closed!=true and @cls!=nil
         @cls.free
         end
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
               def tempo
       tm=[0].pack('f')
       BASS_ChannelGetAttribute.call(@channel,0x10000,tm)
       return tm.unpack("f")[0]
       end
     def tempo=(n)
       if @tempo==nil
         @tempo=n
         BASS_ChannelSetAttribute.call(@channel, 65555, 60)
         BASS_ChannelSetAttribute.call(@channel, 65554, 1)
         end
              tm=[n].pack('f').unpack('i')[0]
       BASS_ChannelSetAttribute.call(@channel,0x10000,tm)
       return tm
     end
     def set3d(a1=nil,a2=nil,a3=nil,b1=nil,b2=nil,b3=nil,c1=nil,c2=nil,c3=nil)
       a,b,c=nil,nil,nil
       if a1!=nil&&a2!=nil&&a3!=nil
                a=[a1,a2,a3].pack("fff")
     end
     if b1!=nil&&b2!=nil&&b3!=nil
              b=[b1,b2,b3].pack("fff")
            end
            if c1!=nil&&c2!=nil&&c3!=nil
              c=[c1,c2,c3].pack("fff")
            end
                                 BASS_ChannelSet3DPosition.call(@channel,a,b,c)
                                 BASS_Apply3D.call
            end
     def volume
       vol=[0].pack('f')
       BASS_ChannelGetAttribute.call(@channel,2,vol)
              return vol.unpack("f")[0]
            end
            def newchannel
              @channel=@cls.newchannel
              BASS_ChannelFlags.call(@channel, 4, 4) if @looper==true
              end
     def volume=(v)
              vol=[v].pack('f').unpack('i')[0]
       BASS_ChannelSetAttribute.call(@channel,2,vol)
                     return vol
     end
def length(bytes=false)
            bts=BASS_ChannelGetLength.call(@channel,0)+@startposition*@basefrequency*4
            return 0 if bts<=0
                     return bts if bytes==true
return [BASS_ChannelBytes2Seconds.call(@channel,bts)].pack("i").unpack("d")[0] if @type==0
return bts.to_f/(@basefrequency*4)
rescue Exception
  return 0
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
  if bytes==false
        val = val*@basefrequency*4
                            end
        val=0 if val < 0
        val=val.to_i
                a=BASS_ChannelSetPosition.call(@channel,val,0,0)
            return val     
    end
     
    def wait
      ld=0
            while length(true)==-1
        sleep(0.025)
        ld+=1
        break if (ld==400 and position<=0) or length(true)>=0
                end
      while position(true)<length(true)-@basefrequency*4/1000*100 or length(true)==0 or position(true)==0
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

