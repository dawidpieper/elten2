# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module Bass
  BASS = Fiddle.dlopen("bass")
  BASSMIX = Fiddle.dlopen("bassmix")
  BASSVST = Fiddle.dlopen("bass_vst")
  BASSENC = Fiddle.dlopen("bassenc")
  BASSENCMP3 = Fiddle.dlopen("bassenc_mp3")
  BASS_GetVersion = Fiddle::Function.new(BASS["BASS_GetVersion"], [], Fiddle::TYPE_INT)
  BASS_ErrorGetCode = Fiddle::Function.new(BASS["BASS_ErrorGetCode"], [], Fiddle::TYPE_INT)
  BASS_Init = Fiddle::Function.new(BASS["BASS_Init"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_RecordGetDeviceInfo = Fiddle::Function.new(BASS["BASS_RecordGetDeviceInfo"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_RecordGetInput = Fiddle::Function.new(BASS["BASS_RecordGetInput"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_RecordSetInput = Fiddle::Function.new(BASS["BASS_RecordSetInput"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_RecordInit = Fiddle::Function.new(BASS["BASS_RecordInit"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_RecordGetDevice = Fiddle::Function.new(BASS["BASS_RecordGetDevice"], [], Fiddle::TYPE_INT)
  BASS_RecordSetDevice = Fiddle::Function.new(BASS["BASS_RecordSetDevice"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_RecordStart = Fiddle::Function.new(BASS["BASS_RecordStart"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_RecordFree = Fiddle::Function.new(BASS["BASS_RecordFree"], [], Fiddle::TYPE_INT)
  BASS_GetConfig = Fiddle::Function.new(BASS["BASS_GetConfig"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_SetConfig = Fiddle::Function.new(BASS["BASS_SetConfig"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_SetDevice = Fiddle::Function.new(BASS["BASS_SetDevice"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_GetDeviceInfo = Fiddle::Function.new(BASS["BASS_GetDeviceInfo"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_SetConfigPtr = Fiddle::Function.new(BASS["BASS_SetConfigPtr"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_Free = Fiddle::Function.new(BASS["BASS_Free"], [], Fiddle::TYPE_INT)
  BASS_PluginLoad = Fiddle::Function.new(BASS["BASS_PluginLoad"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
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
  BASS_StreamCreate = Fiddle::Function.new(BASS["BASS_StreamCreate"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_StreamCreateFile = Fiddle::Function.new(BASS["BASS_StreamCreateFile"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamCreateURL = Fiddle::Function.new(BASS["BASS_StreamCreateURL"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamFree = Fiddle::Function.new(BASS["BASS_StreamFree"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelFlags = Fiddle::Function.new(BASS["BASS_ChannelFlags"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelPlay = Fiddle::Function.new(BASS["BASS_ChannelPlay"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelStop = Fiddle::Function.new(BASS["BASS_ChannelStop"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelPause = Fiddle::Function.new(BASS["BASS_ChannelPause"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelSetDevice = Fiddle::Function.new(BASS["BASS_ChannelSetDevice"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamPutData = Fiddle::Function.new(BASS["BASS_StreamPutData"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelGetData = Fiddle::Function.new(BASS["BASS_ChannelGetData"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelGetLength = Fiddle::Function.new(BASS["BASS_ChannelGetLength"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelGetInfo = Fiddle::Function.new(BASS["BASS_ChannelGetInfo"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_ChannelGetAttribute = Fiddle::Function.new(BASS["BASS_ChannelGetAttribute"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_ChannelSetAttribute = Fiddle::Function.new(BASS["BASS_ChannelSetAttribute"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelSlideAttribute = Fiddle::Function.new(BASS["BASS_ChannelSlideAttribute"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelIsSliding = Fiddle::Function.new(BASS["BASS_ChannelIsSliding"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelIsActive = Fiddle::Function.new(BASS["BASS_ChannelIsActive"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_ChannelSeconds2Bytes = Fiddle::Function.new(BASS["BASS_ChannelSeconds2Bytes"], [Fiddle::TYPE_INT, Fiddle::TYPE_DOUBLE], Fiddle::TYPE_LONG_LONG)
  BASS_ChannelBytes2Seconds = Fiddle::Function.new(BASS["BASS_ChannelBytes2Seconds"], [Fiddle::TYPE_INT, Fiddle::TYPE_LONG_LONG], Fiddle::TYPE_DOUBLE)
  BASS_ChannelGetPosition = Fiddle::Function.new(BASS["BASS_ChannelGetPosition"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_LONG_LONG)
  BASS_ChannelSetPosition = Fiddle::Function.new(BASS["BASS_ChannelSetPosition"], [Fiddle::TYPE_INT, Fiddle::TYPE_LONG_LONG, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_StreamGetFilePosition = Fiddle::Function.new(BASS["BASS_StreamGetFilePosition"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_FXSetPriority = Fiddle::Function.new(BASS["BASS_FXSetPriority"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Mixer_StreamCreate = Fiddle::Function.new(BASSMIX["BASS_Mixer_StreamCreate"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Mixer_StreamAddChannel = Fiddle::Function.new(BASSMIX["BASS_Mixer_StreamAddChannel"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Mixer_ChannelRemove = Fiddle::Function.new(BASSMIX["BASS_Mixer_ChannelRemove"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Mixer_ChannelGetData = Fiddle::Function.new(BASSMIX["BASS_Mixer_ChannelGetData"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Split_StreamCreate = Fiddle::Function.new(BASSMIX["BASS_Split_StreamCreate"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_VST_ChannelSetDSP = Fiddle::Function.new(BASSVST["BASS_VST_ChannelSetDSP"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_ChannelSetDSPEx = Fiddle::Function.new(BASSVST["BASS_VST_ChannelSetDSPEx"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_ChannelRemoveDSP = Fiddle::Function.new(BASSVST["BASS_VST_ChannelRemoveDSP"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_GetBypass = Fiddle::Function.new(BASSVST["BASS_VST_GetBypass"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_SetBypass = Fiddle::Function.new(BASSVST["BASS_VST_SetBypass"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_GetParamCount = Fiddle::Function.new(BASSVST["BASS_VST_GetParamCount"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_GetParam = Fiddle::Function.new(BASSVST["BASS_VST_GetParam"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_FLOAT)
  BASS_VST_SetParam = Fiddle::Function.new(BASSVST["BASS_VST_SetParam"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_FLOAT], Fiddle::TYPE_INT)
  BASS_VST_GetParamInfo = Fiddle::Function.new(BASSVST["BASS_VST_GetParamInfo"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_VST_GetInfo = Fiddle::Function.new(BASSVST["BASS_VST_GetInfo"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_VST_GetProgramCount = Fiddle::Function.new(BASSVST["BASS_VST_GetProgramCount"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_GetProgram = Fiddle::Function.new(BASSVST["BASS_VST_GetProgram"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_SetProgram = Fiddle::Function.new(BASSVST["BASS_VST_SetProgram"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_GetProgramName = Fiddle::Function.new(BASSVST["BASS_VST_GetProgramName"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_EmbedEditor = Fiddle::Function.new(BASSVST["BASS_VST_EmbedEditor"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_VST_GetChunk = Fiddle::Function.new(BASSVST["BASS_VST_GetChunk"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_VST_SetChunk = Fiddle::Function.new(BASSVST["BASS_VST_SetChunk"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Encode_Start = Fiddle::Function.new(BASSENC["BASS_Encode_Start"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  BASS_Encode_Stop = Fiddle::Function.new(BASSENC["BASS_Encode_Stop"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Encode_CastInit = Fiddle::Function.new(BASSENC["BASS_Encode_CastInit"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Encode_Write = Fiddle::Function.new(BASSENC["BASS_Encode_Write"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  BASS_Encode_MP3_Start = Fiddle::Function.new(BASSENCMP3["BASS_Encode_MP3_Start"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

  Errmsg = {
    1 => "MEM", 2 => "FILEOPEN", 3 => "DRIVER", 4 => "BUFLOST", 5 => "HANDLE", 6 => "FORMAT", 7 => "POSITION", 8 => "INIT",
    9 => "START", 14 => "ALREADY", 18 => "NOCHAN", 19 => "ILLTYPE", 20 => "ILLPARAM", 21 => "NO3D", 22 => "NOEAX", 23 => "DEVICE",
    24 => "NOPLAY", 25 => "FREQ", 27 => "NOTFILE", 29 => "NOHW", 31 => "EMPTY", 32 => "NONET", 33 => "CREATE", 34 => "NOFX",
    37 => "NOTAVAIL", 38 => "DECODE", 39 => "DX", 40 => "TIMEOUT", 41 => "FILEFORM", 42 => "SPEAKER", 43 => "VERSION", 44 => "CODEC",
    45 => "ENDED", -1 => " UNKNOWN"
  }

  @@cardid = 1

  def self.cardid
    @@cardid
  end

  def self.set_card(card, hWnd, samplerate = 48000)
    BASS_SetConfig.call(36, 1)
    c = 1
    if card != nil
      cards = self.soundcards
      c = cards.map { |c| c.name }.index(card) || 1
    end
    BASS_Init.call(c, samplerate, 4, hWnd, nil)
    BASS_SetDevice.call(c)
    @@cardid = c
  end

  class Device
    attr_accessor :name, :driver, :flags

    def initialize(name = "", driver = "", flags = 0)
      @name = name
      @driver = driver
      @flags = flags
    end

    def enabled?
      (@flags & 1) != 0
    end

    def disabled?
      !enabled?
    end

    def default?
      (@flags & 2) != 0
    end
  end

  def self.soundcards
    BASS_SetConfig.call(36, 1)
    devs = []
    index = 0
    tmp = [nil, nil, 0].pack("ppi")
    cds = {}
    while BASS_GetDeviceInfo.call(index, tmp) > 0
      a = tmp.unpack("ii")
      o = "\0" * 1024
      $strcpy.call(o, a[0])
      sc = o[0...(o.index("\0") || -1)]
      b = sc.force_encoding("UTF-8")
      driver = ""
      if a[1] != 0
        o = "\0" * 1024
        $strcpy.call(o, a[1])
        tm = o[0...(o.index("\0") || -1)]
        driver = tm.force_encoding("UTF-8")
      end
      cds[b] ||= 0
      cds[b] += 1
      b += " (#{cds[b]})" if cds[b] > 1
      devs[index] = Device.new(b, driver, a[2])
      index += 1
    end
    return devs
  end

  def self.microphones
    BASS_SetConfig.call(36, 1)
    microphones = []
    index = 0
    tmp = [nil, nil, 0].pack("ppi")
    cds = {}
    while BASS_RecordGetDeviceInfo.call(index, tmp) > 0
      a = tmp.unpack("iii")
      o = "\0" * 1024
      $strcpy.call(o, a[0])
      sc = o[0...(o.index("\0") || -1)].force_encoding("UTF-8")
      driver = ""
      if a[1] != 0
        o = "\0" * 1024
        $strcpy.call(o, a[1])
        driver = o[0...(o.index("\0") || -1)].force_encoding("UTF-8")
      end
      cds[sc] ||= 0
      cds[sc] += 1
      sc += " (#{cds[sc]})" if cds[sc] > 1
      microphones.push(Device.new(sc, driver, a[2]))
      index += 1
    end
    return microphones
  end

  @@recorddevice = -1
  @@recordinit = false
  def self.setrecorddevice(i)
    @@recorddevice = i
    BASS_RecordFree.call if @@recordinit
    @@recordinit = false
  end
  def self.record_prepare
    if @@recordinit == false
      r = BASS_RecordInit.call(@@recorddevice)
      if r == 0
        fl = BASS_GetConfig.call(66)
        t = 0
        t = 1 if fl == 0
        BASS_SetConfig.call(66, t)
        log(1, "Record fallback to Wasapi") if fl == 0
        log(1, "Record fallback to DirectSound") if fl == 1
        r = BASS_RecordInit.call(@@recorddevice)
        BASS_SetConfig.call(66, fl)
      end
      if @@recorddevice == -1
        @@recorddevice = BASS_RecordGetDevice.call
      end
      BASS_RecordSetDevice.call(@@recorddevice)
      @@recordinit = true
    end
  rescue Exception
    log(2, $!.to_s)
  end

  def self.record_resetdevice
    BASS_RecordSetDevice.call(@@recorddevice)
  end

  def self.init(hWnd, samplerate = 48000)
    return if @init == true
    @init = true
    BASS_SetConfig.call(1, 25)
    BASS_SetConfig.call(36, 1)
    BASS_SetConfig.call(42, 1)
    BASS_SetConfig.call(66, 1)
    if (BASS_GetVersion.call >> 16) != 0x0204
      raise("bass.dll 2.4")
    end
    if BASS_Init.call(1, samplerate, 4, hWnd, nil) == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
    plugins = ["bassopus", "bassflac", "bassmidi", "basswebm", "basswma", "bass_aac", "bass_ac3", "bass_spx"]
    mandatory = ["bassopus"]
    for pl in plugins
      if BASS_PluginLoad.call("bin\\#{pl}.dll") == 0
        level = 1
        level = 2 if mandatory.include?(pl)
        begin
          log(level, "Plugin #{pl} returned BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        rescue Exception
        end
      end
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
    BASS_Free.call
  end

  def self.loadSample(filename, max = 1)
    return Sample.new(filename, max)
  end

  def self.loadStream(filename, stream = nil, autofree = false)
    return Stream.new(filename, 0, stream, autofree)
  end

  class Sample
    attr_reader :ch

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
      Bass::BASS_ChannelSetDevice.call(@ch, Bass.cardid)
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

    def initialize(filename, pos = 0, stream = nil, autofree = false)
      @stream = stream
      pos = pos.to_i
      flags = 0
      flags |= 0x40000 if autofree
      if filename != nil
        if filename[0..3] == "http"
          @ch = BASS_StreamCreateURL.call((filename), pos, flags, 0, 0)
        else
          @ch = BASS_StreamCreateFile.call(0, filename, pos, 0, 0, 0, flags)
        end
      else
        @ch = BASS_StreamCreateFile.call(1, @stream, 0, 0, @stream.bytesize, 0, 0)
      end
      Bass::BASS_ChannelSetDevice.call(@ch, Bass.cardid)
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

    def initialize(file, type = 1, looper = false, u3d = false, stream = nil, autofree = false)
      @file = file
      @startposition = 0
      ext = ""
      if file != nil
        ext = File.extname(file).downcase
        type = 1 if file[0..3] == "http"
      else
        type = 1 if file == nil
      end
      @type = type
      case type
      when 1
        @cls = Bass.loadStream(file, stream, autofree)
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
      return BASS_ChannelBytes2Seconds.call(@channel, bts) if @type == 0
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

  class VST
    @@shown = 0

    class Parameter
      attr_reader :name, :unit, :display, :default, :value

      def initialize(vst, index)
        @vst, @index = vst, index
        reload
      end

      def value=(v)
        BASS_VST_SetParam.call(@vst, @index, v)
        reload
        @value
      end

      def reload
        pc = "A16A16A16f"
        n = ["", "", "", 0.0].pack(pc)
        BASS_VST_GetParamInfo.call(@vst, @index, n)
        @name, @unit, @display, @default = n.unpack(pc)
        @value = BASS_VST_GetParam.call(@vst, @index)
      end
    end

    def initialize(file, channel, priority = 0)
      @file = file
      @priority = priority
      @vst = BASS_VST_ChannelSetDSP.call(channel, unicode(file), [0x80000000 | 0x1].pack("I").unpack("i").first, priority)
      @channel = channel
    end

    def priority
      @priority
    end

    def priority=(pr)
      h = info[17]
      BASS_FXSetPriority.call(h, pr)
      @priority = pr
    end

    def loaded?
      @vst != 0
    end

    def free
      BASS_VST_ChannelRemoveDSP.call(@channel, @vst)
      @channel = @vst = 0
    end

    def parameters
      cnt = BASS_VST_GetParamCount.call(@vst)
      params = []
      for i in 0...cnt
        params.push(Parameter.new(@vst, i))
      end
      params
    end

    def bypass
      BASS_VST_GetBypass.call(@vst) != 0
    end

    def bypass=(b)
      bp = 0
      bp = 1 if b == true
      BASS_VST_SetBypass.call(@vst, bp)
      bypass
    end

    def program
      BASS_VST_GetProgram.call(@vst)
    end

    def program=(g)
      BASS_VST_SetProgram.call(@vst, g)
      program
    end

    def name
      info[2]
    end

    def version
      info[3]
    end

    def unique_id
      info[1]
    end

    def version
      info[3]
    end

    def editor?
      info[12] != 0
    end

    def editor_shown?
      @editor_shown == true
    end

    def editor_show
      editor_hide
      if @@shown == 0
        $showemptywindow.call
        sleep(0.25)
      end
      @@shown += 1
      @editor_shown = true
      BASS_VST_EmbedEditor.call(@vst, $ag_wnd)
    end

    def editor_hide
      return if @editor_shown != true
      BASS_VST_EmbedEditor.call(@vst, 0)
      @@shown -= 1
      @editor_shown = false
      if @@shown == 0
        $hideemptywindow.call()
      end
    end

    def file
      @file
    end

    def programs
      count = BASS_VST_GetProgramCount.call(@vst)
      programs = []
      for i in 0...count
        a = BASS_VST_GetProgramName.call(@vst, i)
        programs[i] = "\0" * 24
        $strcpy.call(programs[i], a)
        programs[i].delete!("\0")
      end
      programs
    end

    def export(type = :preset)
      return nil if type != :preset and type != :bank
      pr = 1
      pr = 0 if type == :bank
      pt = [0].pack("I")
      a = BASS_VST_GetChunk.call(@vst, pr, pt)
      len = pt.unpack("I").first
      ex = "\0" * len
      $rtlmovememory.call(ex, a, len)
      return ex
    end

    def import(type = :preset, value)
      return nil if type != :preset and type != :bank
      pr = 1
      pr = 0 if type == :bank
      BASS_VST_SetChunk.call(@vst, pr, value, value.bytesize)
    end

    private

    def info
      pc = "IIA80IIIA80A80IIIIIIIIIi"
      nfo = [0, 0, "\0" * 80, 0, 0, 0, "\0" * 80, "\0" * 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].pack(pc)
      BASS_VST_GetInfo.call(@vst, nfo)
      return nfo.unpack(pc)
    end
  end
end
