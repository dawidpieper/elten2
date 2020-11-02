# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

module Bass
  BASS = Fiddle.dlopen("bass")
  BASS_GetVersion = Fiddle::Function.new(BASS["BASS_GetVersion"], [], Fiddle::TYPE_INT)
  BASS_ErrorGetCode = Fiddle::Function.new(BASS["BASS_ErrorGetCode"], [], Fiddle::TYPE_INT)
  BASS_Init = Fiddle::Function.new(BASS["BASS_Init"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_RecordInit = Fiddle::Function.new(BASS["BASS_RecordInit"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_RecordStart = Fiddle::Function.new(BASS["BASS_RecordStart"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_GetConfig = Fiddle::Function.new(BASS["BASS_GetConfig"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_SetConfig = Fiddle::Function.new(BASS["BASS_SetConfig"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
BASS_SetDevice = Fiddle::Function.new(BASS["BASS_SetDevice"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_GetDeviceInfo = Fiddle::Function.new(BASS["BASS_GetDeviceInfo"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_SetConfigPtr = Fiddle::Function.new(BASS["BASS_SetConfigPtr"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_Free = Fiddle::Function.new(BASS["BASS_Free"], [], Fiddle::TYPE_INT)
  BASS_Start = Fiddle::Function.new(BASS["BASS_Start"], [], Fiddle::TYPE_INT)
  BASS_Stop = Fiddle::Function.new(BASS["BASS_Stop"], [], Fiddle::TYPE_INT)
  BASS_Pause = Fiddle::Function.new(BASS["BASS_Pause"], [], Fiddle::TYPE_INT)
  BASS_SetVolume = Fiddle::Function.new(BASS["BASS_SetVolume"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_GetVolume = Fiddle::Function.new(BASS["BASS_GetVolume"], [], Fiddle::TYPE_INT)
  BASS_SampleLoad = Fiddle::Function.new(BASS["BASS_SampleLoad"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_SampleCreate = Fiddle::Function.new(BASS["BASS_SampleCreate"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_SampleFree = Fiddle::Function.new(BASS["BASS_SampleFree"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_SampleGetChannel = Fiddle::Function.new(BASS["BASS_SampleGetChannel"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_SampleStop = Fiddle::Function.new(BASS["BASS_SampleStop"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamCreateFile = Fiddle::Function.new(BASS["BASS_StreamCreateFile"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamCreateURL = Fiddle::Function.new(BASS["BASS_StreamCreateURL"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamFree = Fiddle::Function.new(BASS["BASS_StreamFree"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelFlags = Fiddle::Function.new(BASS["BASS_ChannelFlags"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelPlay = Fiddle::Function.new(BASS["BASS_ChannelPlay"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelStop = Fiddle::Function.new(BASS["BASS_ChannelStop"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelPause = Fiddle::Function.new(BASS["BASS_ChannelPause"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelGetData = Fiddle::Function.new(BASS["BASS_ChannelGetData"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelGetLength = Fiddle::Function.new(BASS["BASS_ChannelGetLength"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelGetAttribute = Fiddle::Function.new(BASS["BASS_ChannelGetAttribute"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_ChannelSetAttribute = Fiddle::Function.new(BASS["BASS_ChannelSetAttribute"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelSlideAttribute = Fiddle::Function.new(BASS["BASS_ChannelSlideAttribute"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelIsSliding = Fiddle::Function.new(BASS["BASS_ChannelIsSliding"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelIsActive = Fiddle::Function.new(BASS["BASS_ChannelIsActive"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelSeconds2Bytes = Fiddle::Function.new(BASS["BASS_ChannelSeconds2Bytes"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelBytes2Seconds = Fiddle::Function.new(BASS["BASS_ChannelBytes2Seconds"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelGetPosition = Fiddle::Function.new(BASS["BASS_ChannelGetPosition"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelSetPosition = Fiddle::Function.new(BASS["BASS_ChannelSetPosition"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamGetFilePosition = Fiddle::Function.new(BASS["BASS_StreamGetFilePosition"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  Errmsg = {
    1 => "MEM", 2 => "FILEOPEN", 3 => "DRIVER", 4 => "BUFLOST", 5 => "HANDLE", 6 => "FORMAT", 7 => "POSITION", 8 => "INIT",
    9 => "START", 14 => "ALREADY", 18 => "NOCHAN", 19 => "ILLTYPE", 20 => "ILLPARAM", 21 => "NO3D", 22 => "NOEAX", 23 => "DEVICE",
    24 => "NOPLAY", 25 => "FREQ", 27 => "NOTFILE", 29 => "NOHW", 31 => "EMPTY", 32 => "NONET", 33 => "CREATE", 34 => "NOFX",
    37 => "NOTAVAIL", 38 => "DECODE", 39 => "DX", 40 => "TIMEOUT", 41 => "FILEFORM", 42 => "SPEAKER", 43 => "VERSION", 44 => "CODEC",
    45 => "ENDED", -1 => " UNKNOWN",
  }

def self.set_card(card, hWnd, samplerate = 44100)
      devs=[]
      c=-1
      if card!=nil
      index=1
      tmp=[nil,nil,0].pack("ppi")
      while BASS_GetDeviceInfo.call(index,tmp)>0
        a=tmp.unpack("ii")
        o="\0"*1024
        $strcpy.call(o,a[0])
       sc=o[0...o.index("\0")]
Encoding.list.each {|a|
begin
b=sc.force_encoding(a).encode("UTF-8")
        c=index if card==b
rescue Exception
end
}
        index+=1
end
end
c=-1 if c==0
BASS_Init.call(c, samplerate, 4, hWnd, nil)
BASS_SetDevice.call(c)
end

  def self.init(hWnd, samplerate = 44100)
    return if @init == true
    @init = true
    if (BASS_GetVersion.call >> 16) != 0x0204
      raise("bass.dll 2.4")
    end
    if BASS_Init.call(-1, samplerate, 4, hWnd, nil) == 0
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
    @init = false
    if BASS_Free.call == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
  end

  def self.loadSample(filename, max = 1)
    return Sample.new(filename, max)
  end

  def self.loadStream(filename)
    return Stream.new(filename, 0)
  end

  class Sample
    attr_reader :ch

def set_card(name)

end

    def initialize(filename, max = 1)
      if filename[0..3] == "http"
        return Bass::Stream.new(filename)
      else
        @handle = BASS_SampleLoad.call(0, (filename), 0, 0, 0, max, 0x20000)
      end
      @ch = @handle
      if @handle == 0
        return Bass::Stream.new(filename)
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def free
      if BASS_SampleFree.call(@handle) == 0
        #raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def play(option = {})
      ch = BASS_SampleGetChannel.call(@handle, 0)
      if ch == 0
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end

      if option[:loop]
        if BASS_ChannelFlags.call(ch, 4, 4) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:pan]
        if BASS_ChannelSetAttribute.call(ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:volume]
        if BASS_ChannelSetAttribute.call(ch, 2, [option[:volume]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end

      if BASS_ChannelPlay.call(ch, 0) == 0
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
      return ch
    end

    def setPan(ch, pan)
      if BASS_ChannelSetAttribute.call(ch, 3, [pan].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def setVolume(ch, v)
      if BASS_ChannelSetAttribute.call(ch, 2, [v].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def stop(ch = nil)
      if ch == nil
        if BASS_SampleStop.call(@handle) == 0
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      else
        if BASS_ChannelStop.call(ch) == 0
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
    end
  end

  class Stream
    attr_reader :ch

    def initialize(filename, pos = 0)
      pos = pos.to_i
      if filename[0..3] == "http"
        @ch = BASS_StreamCreateURL.call((filename), pos, 0, 0, 0)
      else
        @ch = BASS_StreamCreateFile.call(0, filename, pos, 0, 0, 0, 0)
      end
      #    BASS_ChannelSetPosition.call(@ch,0,0)
    end

    def free
      if BASS_StreamFree.call(@ch) == 0
        #raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def play(option = {})
      if option[:loop]
        if BASS_ChannelFlags.call(@ch, 4, 4) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:pan]
        if BASS_ChannelSetAttribute.call(@ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:frequency]
        if BASS_ChannelSetAttribute.call(@ch, 3, [option[:frequency]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:volume]
        if BASS_ChannelSetAttribute.call(@ch, 2, [option[:volume]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if BASS_ChannelPlay.call(@ch, 0) == 0
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def pan=(pan)
      if BASS_ChannelSetAttribute.call(@ch, 3, [pan].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def volume=(v)
      if BASS_ChannelSetAttribute.call(@ch, 2, [v].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def stop
      if BASS_ChannelStop.call(@ch) == 0
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def seek(pt, flags = 0)
      print("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}") if Win32API.new("bass", "BASS_ChannelSetPosition", "iil", "i").call(@ch, 0, flags) == 0
    end
  end

  def free
    if BASS_SampleFree.call(@handle) == 0
      #raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
  end

  def play
    if BASS_ChannelPlay.call(@ch, 0) == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
    return ch
  end

  def stop(ch = nil)
    if BASS_ChannelStop.call(ch) == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
  end

  class Sound
    attr_reader :channel
    attr_reader :type
    attr_reader :cls
    include Bass
    attr_reader :file

    def initialize(file, type = 1, looper = false)
      @file = file
      @startposition = 0
      ext = File.extname(file).downcase
      type = 1 if file[0..3] == "http"
      @type = type
      case type
      when 1
        #         begin
        @cls = Bass.loadStream(file)
        #         rescue Exception
        #       end
        if @cls == nil or (@cl != nil and @cls.ch == nil)
        end
      else
        @cls = Bass.loadSample(file)
      end
      return nil if @cls == nil
      @channel = @cls.ch
      @basefrequency = frequency
      BASS_ChannelFlags.call(channel, 4, 4) if looper == true
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

    def data(len = length(true))
      buf = "\0" * len
      BASS_ChannelGetData.call(@channel, len, len.size)
    end

    def status
      @lastupdate = 0 if @lastupdate == nil
      return 1 if @lastupdate < Time.now.to_i * 1000000 + Time.now.usec + 50000
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
      @cls.free if @closed != true and @cls != nil
      @closed = true
    end

    def close
      free
    end

    def closed
      return true if @closed
      return false
    end

    def frequency
      frq = [0].pack("f")
      BASS_ChannelGetAttribute.call(@channel, 1, frq)
      return frq.unpack("f")[0].to_i
    end

    def frequency=(f)
      frq = [f].pack("f").unpack("i")[0]
      BASS_ChannelSetAttribute.call(@channel, 1, frq)
      return frq
    end

    def pan
      pn = [0].pack("f")
      BASS_ChannelGetAttribute.call(@channel, 3, pn)
      return pn.unpack("f")[0]
    end

    def pan=(n)
      pn = [n].pack("f").unpack("i")[0]
      BASS_ChannelSetAttribute.call(@channel, 3, pn)
      return pn
    end

    def volume
      vol = [0].pack("f")
      BASS_ChannelGetAttribute.call(@channel, 2, vol)
      return vol.unpack("f")[0]
    end

    def volume=(v)
      vol = [v].pack("f").unpack("i")[0]
      BASS_ChannelSetAttribute.call(@channel, 2, vol)
      return vol
    end

    def length(bytes = false)
      bts = BASS_ChannelGetLength.call(@channel, 0) + @startposition
      return bts if bytes == true
      return [BASS_ChannelBytes2Seconds.call(@channel, bts)].pack("i").unpack("f")[0] if @type == 0
      return bts.to_f / (@basefrequency * 4)
    end

    def position(bytes = false, useold = true)
      bts = BASS_ChannelGetPosition.call(@channel, 0)
      bts += @startposition if useold == true
      return bts if bytes == true
      @basefrequency = frequency if @basefrequency == 0
      return bts.to_f / (@basefrequency * 4)
    end

    def position=(val, bytes = false)
      val = 0.15 if val < 0.15
      return 0 if @closed
      @posupdated = true
      if @type == 100
        @updating = true
        val *= @basefrequency * 4 if bytes == false
        attribs = []
        for i in 1..4
          attribs[i] = [0].pack("f")
          BASS_ChannelGetAttribute.call(@channel, i, attribs[i])
          attribs[i] = attribs[i].unpack("i")[0]
        end
        pl = playing
        cmp = BASS_StreamGetFilePosition.call(@channel, 2).to_f / (length(true) - @startposition).to_f
        cmp = 1 if cmp == 1.0 / 0.0
        if val >= length(true)
          if val <= length(true) - frequency
            val = length(true) - frequency * 4
          else
            @updating = false
            @omit = true
            return
          end
        end
        @cls.stop
        @cls.free
        @cls = Bass::Stream.new(@file, val * cmp)
        @startposition = val
        @channel = @cls.ch
        for i in 1..attribs.size - 1
          BASS_ChannelSetAttribute.call(@channel, i, attribs[i])
        end
        @cls.play if pl == true
        @updating = false
      else
        val *= @basefrequency * 4 if bytes == false
        val = 0 if val < 0
        i = 0
        for i in 1..50
          if BASS_ChannelSetPosition.call(@channel, val, 0) > 0
            break
          else
            val -= (val.to_f / 10000.0).to_i
            sleep(0.001)
          end
        end
      end
      return val
    end

    def wait
      ld = 0
      while length(true) == -1
        sleep(0.025)
        ld += 1
        break if (ld == 400 and position <= 0) or length(true) >= 0
      end
      while position(true) < length(true) - 128 or length(true) == 0 or position(true) == 0
        sleep(0.05)
      end
      pos = position
      l = length
      return
      while position <= 0.03
        sleep(0.01)
      end
      BASS_ChannelFlags.call(@channel, 4, 4) if closed == false
      loop do
        sleep(0.01)
        sleep(0.01) while @updating
        BASS_ChannelFlags.call(@channel, 4, 4) if closed == false if @closed != true
        return if @omit
        @lastupdate = 0 if @lastupdate == nil
        sleep(0.07) if @lastupdate < Time.now.to_i * 1000000 + Time.now.usec + 70000
        @posupdated = false
        if position(false, false) <= 0.07 and BASS_ChannelIsActive.call(@channel) == 1
          break
        end
      end
      return
    end
  end
end
