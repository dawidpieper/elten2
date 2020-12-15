# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

module OpusRecorder
    class OpusRecording
      def initialize(file, bitrate=64, framesize=60, application=2048, usevbr=1)
        @paused=false
        init=Win32API.new($eltenlib, "OpusRecorderInit", 'piiiiiii', 'i')
        @rproc=init.call(unicode(file), 48000, 2, bitrate*1000, [framesize].pack("f").unpack("i").first, application, usevbr, (Configuration.usedenoising==2)?(1):(0))
Bass.record_prepare
        dll = Win32API.new("kernel32", "LoadLibrary", 'p', 'i').call($eltenlib)
proc = Win32API.new("kernel32", "GetProcAddress", 'ip', 'i').call(dll, "_OpusRecordProc@16")
@channel = Bass::BASS_RecordStart.call(48000, 2, 0, proc, @rproc, 0)
end
def stop
  Bass::BASS_ChannelStop.call(@channel)
  sleep(0.1)
Win32API.new($eltenlib, "OpusRecorderClose", 'i', 'i').call(@rproc)
end
def pause
  @paused=true
  Bass::BASS_ChannelPause.call(@channel)
end
def resume
  @paused=false
  Bass::BASS_ChannelPlay.call(@channel, 0)
  end
def paused
  @paused==true
  end
end
class <<self
  def start(file, bitrate=64, framesize=60, application=2048, usevbr=1)
    OpusRecording.new(file, bitrate, framesize, application, usevbr)
  end
        def encode_file(file, output, bitrate=64, framesize=60, application=2048, usevbr=1)
  w=Win32API.new($eltenlib, "OpusRecorderInit", 'piiiiiii', 'i')
pr=Win32API.new($eltenlib, "_OpusRecordProc@16", 'ipii', 'i')
if file[0..4]=="http:" || file[0..5]=="https:"
  cha = Bass::BASS_StreamCreateURL.call(unicode(file), 0, 0x80000000|0x200000|131072, 0, 0)
else
cha = Bass::BASS_StreamCreateFile.call(0, unicode(file), 0, 0, 0, 0, 0x80000000|0x200000|131072)
end
rinfo=[0, 0, 0, 0, 0, 0, 0, ''].pack("iiiiiiip")
           Bass::BASS_ChannelGetInfo.call(cha, rinfo)
           info=rinfo.unpack("iiiiiii")
           channels=info[1]
              r=w.call(unicode(output), 48000, channels, bitrate*1000, [framesize].pack("f").unpack("i").first, application, usevbr, 0)
                mx=Bass::BASS_Mixer_StreamCreate.call(48000, channels, 0x200000|0x10000)
                Bass::BASS_Mixer_StreamAddChannel.call(mx, cha, 0x10000|0x4000|0x800000)
                cha=mx
bufsize = 2097152
buf="\0"*bufsize
t=0
while (sz=Bass::BASS_ChannelGetData.call(cha, buf, bufsize))>0
  loop_update
    pr.call(0, buf, sz, r)
  t+=sz
end
Bass::BASS_StreamFree.call(cha)
Win32API.new($eltenlib, "OpusRecorderClose", 'i', 'i').call(r)
return t
        end
  end
end

module VorbisRecorder
    class VorbisRecording
      def initialize(file, bitrate=64)
        @paused=false
        init=Win32API.new($eltenlib, "VorbisRecorderInit", 'piii', 'i')
        @rproc=init.call(unicode(file), 48000, 2, bitrate*1000)
Bass.record_prepare
        dll = Win32API.new("kernel32", "LoadLibrary", 'p', 'i').call($eltenlib)
proc = Win32API.new("kernel32", "GetProcAddress", 'ip', 'i').call(dll, "_VorbisRecordProc@16")
@channel = Bass::BASS_RecordStart.call(48000, 2, 256, proc, @rproc, 0)
end
def stop
  Bass::BASS_ChannelStop.call(@channel)
  sleep(0.1)
Win32API.new($eltenlib, "VorbisRecorderClose", 'i', 'i').call(@rproc)
end
def pause
  @paused=true
  Bass::BASS_ChannelPause.call(@channel)
end
def resume
  @paused=false
  Bass::BASS_ChannelPlay.call(@channel, 0)
  end
def paused
  @paused==true
  end
end
class <<self
  def start(file, bitrate=64)
    VorbisRecording.new(file, bitrate)
  end
        def encode_file(file, output, bitrate=64)
  w=Win32API.new($eltenlib, "VorbisRecorderInit", 'piii', 'i')
pr=Win32API.new($eltenlib, "_VorbisRecordProc@16", 'ipii', 'i')
if file[0..4]=="http:" || file[0..5]=="https:"
  cha = Bass::BASS_StreamCreateURL.call(unicode(file), 0, 256|0x80000000|0x200000|131072, 0, 0)
else
cha = Bass::BASS_StreamCreateFile.call(0, unicode(file), 0, 0, 0, 0, 256|0x80000000|0x200000|131072)
end
rinfo=[0, 0, 0, 0, 0, 0, 0, ''].pack("iiiiiiip")
           Bass::BASS_ChannelGetInfo.call(cha, rinfo)
           info=rinfo.unpack("iiiiiii")
           channels=info[1]
frq=[0].pack('f')
              Bass::BASS_ChannelGetAttribute.call(cha,1,frq)
       freq=frq.unpack("f")[0].to_i
              r=w.call(unicode(output), freq, channels, bitrate*1000)
bufsize = 2097152
buf="\0"*bufsize
t=0
while (sz=Bass::BASS_ChannelGetData.call(cha, buf, bufsize))>0
  loop_update
    pr.call(0, buf, sz, r)
  t+=sz
end
Bass::BASS_StreamFree.call(cha)
Win32API.new($eltenlib, "VorbisRecorderClose", 'i', 'i').call(r)
return t
        end
  end
end

module WaveRecorder
    class WaveRecording
      def initialize(file)
        @paused=false
        init=Win32API.new($eltenlib, "WaveRecorderInit", 'pii', 'i')
        @rproc=init.call(unicode(file), 48000, 2)
Bass.record_prepare
        dll = Win32API.new("kernel32", "LoadLibrary", 'p', 'i').call($eltenlib)
proc = Win32API.new("kernel32", "GetProcAddress", 'ip', 'i').call(dll, "_WaveRecordProc@16")
@channel = Bass::BASS_RecordStart.call(48000, 2, 0, proc, @rproc, 0)
end
def stop
  Bass::BASS_ChannelStop.call(@channel)
  sleep(0.1)
Win32API.new($eltenlib, "WaveRecorderClose", 'i', 'i').call(@rproc)
end
def pause
  @paused=true
  Bass::BASS_ChannelPause.call(@channel)
end
def resume
  @paused=false
  Bass::BASS_ChannelPlay.call(@channel, 0)
  end
def paused
  @paused==true
  end
end
class <<self
  def start(file)
    WaveRecording.new(file)
  end
        def encode_file(file, output)
  w=Win32API.new($eltenlib, "WaveRecorderInit", 'pii', 'i')
pr=Win32API.new($eltenlib, "_WaveRecordProc@16", 'ipii', 'i')
if file[0..4]=="http:" || file[0..5]=="https:"
  cha = Bass::BASS_StreamCreateURL.call(unicode(file), 0, 0x80000000|0x200000|131072, 0, 0)
else
cha = Bass::BASS_StreamCreateFile.call(0, unicode(file), 0, 0, 0, 0, 0x80000000|0x200000|131072)
end
rinfo=[0, 0, 0, 0, 0, 0, 0, ''].pack("iiiiiiip")
           Bass::BASS_ChannelGetInfo.call(cha, rinfo)
           info=rinfo.unpack("iiiiiii")
           channels=info[1]
frq=[0].pack('f')
              Bass::BASS_ChannelGetAttribute.call(cha,1,frq)
       freq=frq.unpack("f")[0].to_i
              r=w.call(unicode(output), freq, channels)
bufsize = 2097152
buf="\0"*bufsize
t=0
while (sz=Bass::BASS_ChannelGetData.call(cha, buf, bufsize))>0
  loop_update
    pr.call(0, buf, sz, r)
  t+=sz
end
Bass::BASS_StreamFree.call(cha)
Win32API.new($eltenlib, "WaveRecorderClose", 'i', 'i').call(r)
return t
        end
  end
end