# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class SteamAudio
class SAEffect
attr_accessor :heffect, :effect, :ain, :aout, :channels
end
@@lib=nil
@@instances=[]
def initialize(freq, framesize)
fail(RuntimeError, "SteamAudio not loaded") if @@lib==nil
@freq=freq
@framesize=framesize
@@instances.push(self)
init
@mutex=Mutex.new
end
def init
settings = [@freq, (@freq*@framesize/1000.0).to_i, 0]
hrtfParams = [0, nil, nil]
@hrenderer=[0].pack("i")
@@iplCreateBinauralRenderer.call(@@context, *settings, *hrtfParams, @hrenderer)
@renderer = @hrenderer.unpack("i").first
@effects=[]
@loaded=true
end
def add_effect(channels=2)
return -1 if @loaded!=true
r=-1
@mutex.synchronize {
ch=0
ch=1 if channels==2
ch=2 if channels==4
ain=[0, ch, channels, nil, 0, 0, 0, 0]
aout=[0, 1, 2, nil, 0, 0, 0, 0]
heffect=[0].pack("i")
@@iplCreateBinauralEffect.call(@renderer, *ain, *aout, heffect)
effect=heffect.unpack("i").first
if effect!=0
sa=SAEffect.new
sa.effect=effect
sa.heffect=heffect
sa.ain=ain
sa.aout=aout
sa.channels=channels
@effects.push(sa)
r=@effects.index(sa)
end
}
return r
end
def remove_effect(ef)
@mutex.synchronize {
sa=@effects[ef]
if sa!=nil
@@iplDestroyBinauralEffect.call(sa.heffect)
@effects[ef]=nil
end
}
end
def free
@mutex.synchronize {
for sa in @effects
@@iplDestroyBinauralEffect.call(sa.heffect) if sa!=nil
end
@effects=[]
@@iplDestroyBinauralRenderer.call(@hrenderer)
@loaded=false
}
end
def process(effect,audio, x, y, z)
ob=""
@mutex.synchronize {
if @loaded==false || !effect.is_a?(Integer)
ob=audio
else
sa=@effects[effect]
if sa==nil
ob=audio
else
ob="\0"*(audio.bytesize/sa.channels*2)
inbuf=[*sa.ain, audio.bytesize/4/sa.channels, audio, nil]
outbuf=[*sa.aout, ob.bytesize/4/2, ob, nil]
@@iplApplyBinauralEffect.call(sa.effect, @renderer, *inbuf, *([x,y,z].pack("fff").unpack("iii")), 0, [1].pack("f").unpack("i").first, *outbuf)
end
end
}
return ob
end
def self.load(file)
return if @@lib!=nil
@@lib = Fiddle.dlopen(file)
@@iplCreateContext = Fiddle::Function.new(@@lib['iplCreateContext'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
@@iplCreateBinauralRenderer = Fiddle::Function.new(@@lib['iplCreateBinauralRenderer'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
audioformat=[Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT]
@@iplCreateBinauralEffect = Fiddle::Function.new(@@lib['iplCreateBinauralEffect'], [Fiddle::TYPE_INT, *audioformat, *audioformat, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
audiobuffer=[*audioformat, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
@@iplApplyBinauralEffect = Fiddle::Function.new(@@lib['iplApplyBinauralEffect'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, *audiobuffer, *[Fiddle::TYPE_INT]*3, Fiddle::TYPE_INT, Fiddle::TYPE_INT, *audiobuffer], Fiddle::TYPE_INT)
@@iplDestroyBinauralEffect = Fiddle::Function.new(@@lib['iplDestroyBinauralEffect'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
@@iplDestroyBinauralRenderer = Fiddle::Function.new(@@lib['iplDestroyBinauralRenderer'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
@@iplDestroyContext = Fiddle::Function.new(@@lib['iplDestroyContext'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
@@iplCleanup = Fiddle::Function.new(@@lib['iplCleanup'], [], Fiddle::TYPE_INT)
@@hcontext=[0].pack("i")
@@iplCreateContext.call(nil, nil, nil, @@hcontext)
@@context=@@hcontext.unpack("i").first
return true
rescue Exception
@@lib=nil
return false
end
def self.free
if @@lib!=nil
@@instances.each{|n|n.free}
@@instances=[]
@@iplDestroyContext.call(@@hcontext)
@@lib.close
@@lib=nil
end
end
def self.loaded?
return (@@lib!=nil)
end
end