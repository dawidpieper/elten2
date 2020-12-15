# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

module SpeexDSP
SpeexDSP=Fiddle.dlopen("libspeexdsp.dll")

Preprocess_state_init = Fiddle::Function.new(SpeexDSP['speex_preprocess_state_init'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
Preprocess_ctl = Fiddle::Function.new(SpeexDSP['speex_preprocess_ctl'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
Preprocess_run = Fiddle::Function.new(SpeexDSP['speex_preprocess_run'], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
Preprocess_state_destroy = Fiddle::Function.new(SpeexDSP['speex_preprocess_state_destroy'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)

SPEEX_PREPROCESS_GET_AGC=3
SPEEX_PREPROCESS_GET_AGC_DECREMENT=29
SPEEX_PREPROCESS_GET_AGC_INCREMENT=27
SPEEX_PREPROCESS_GET_AGC_LEVEL=7
SPEEX_PREPROCESS_GET_AGC_MAX_GAIN=31
SPEEX_PREPROCESS_GET_DENOISE=1
SPEEX_PREPROCESS_GET_DEREVERB=9
SPEEX_PREPROCESS_GET_DEREVERB_DECAY=13
SPEEX_PREPROCESS_GET_DEREVERB_LEVEL=11
SPEEX_PREPROCESS_GET_ECHO_STATE=25
SPEEX_PREPROCESS_GET_ECHO_SUPPRESS=21
SPEEX_PREPROCESS_GET_ECHO_SUPPRESS_ACTIVE=23
SPEEX_PREPROCESS_GET_NOISE_SUPPRESS=19 
SPEEX_PREPROCESS_GET_PROB_CONTINUE=17 
SPEEX_PREPROCESS_GET_PROB_START=15 
SPEEX_PREPROCESS_GET_VAD=5 
SPEEX_PREPROCESS_SET_AGC=2 
SPEEX_PREPROCESS_SET_AGC_DECREMENT=28 
SPEEX_PREPROCESS_SET_AGC_INCREMENT=26 
SPEEX_PREPROCESS_SET_AGC_LEVEL=6 
SPEEX_PREPROCESS_SET_AGC_MAX_GAIN=30 
SPEEX_PREPROCESS_SET_DENOISE=0 
SPEEX_PREPROCESS_SET_DEREVERB=8 
SPEEX_PREPROCESS_SET_DEREVERB_DECAY=12 
SPEEX_PREPROCESS_SET_DEREVERB_LEVEL=10 
SPEEX_PREPROCESS_SET_ECHO_STATE=24 
SPEEX_PREPROCESS_SET_ECHO_SUPPRESS=20 
SPEEX_PREPROCESS_SET_ECHO_SUPPRESS_ACTIVE=22 
SPEEX_PREPROCESS_SET_NOISE_SUPPRESS=18 
SPEEX_PREPROCESS_SET_PROB_CONTINUE=16 
SPEEX_PREPROCESS_SET_PROB_START=14 
SPEEX_PREPROCESS_SET_VAD=4 

class Processor
attr_reader :freq
attr_reader :ch
attr_reader :framesize
def initialize(freq=48000, ch=2, framesize=20)
@queue=""
@freq, @ch, @framesize = freq, ch, framesize
@stepsize=@ch*@framesize*2*@freq/1000
@preprocessors=[]
ch.times {@preprocessors.push(Preprocess_state_init.call(@framesize*@freq/1000, @freq))}
setctl_int(SPEEX_PREPROCESS_SET_DENOISE, 0)
setctl_int(SPEEX_PREPROCESS_SET_AGC, 0)
setctl_int(SPEEX_PREPROCESS_SET_AGC_LEVEL, @freq)
setctl_int(SPEEX_PREPROCESS_SET_DEREVERB, 0)
setctl_float(SPEEX_PREPROCESS_SET_DEREVERB_DECAY, 0)
setctl_float(SPEEX_PREPROCESS_SET_DEREVERB_LEVEL, 0)
end
def noise_reduction
return getctl_int(SPEEX_PREPROCESS_GET_DENOISE)==1
end
def noise_reduction=(b)
setctl_int(SPEEX_PREPROCESS_SET_DENOISE, (b)?(1):(0))
return b
end
def free
@preprocessors.each {|pr|Preprocess_state_destroy.call(pr)}
@preprocessors=nil
end
def process(data)
audio=@queue+data+""
index=0
ret=""
while (audio.bytesize-index)>=@stepsize
frg=audio.byteslice(index...index+@stepsize)
out=("\0"*@stepsize).b
for c in 0...@ch
frame=("\0"*(@stepsize/@ch)).b
for i in 0...(@stepsize/@ch/2)
frame.setbyte(i*2, frg.getbyte(2*(@ch*i+c)))
frame.setbyte(i*2+1, frg.getbyte(2*(@ch*i+c)+1))
end
Preprocess_run.call(@preprocessors[c], frame)
for i in 0...@stepsize/@ch/2
out.setbyte(2*(@ch*i+c), frame.getbyte(i*2))
out.setbyte(2*(@ch*i+c)+1, frame.getbyte(i*2+1))
end
end
ret+=out
index+=@stepsize
end
@queue=audio.byteslice(index..-1)
return ret
end
private
def setctl_int(flag, value)
for pr in @preprocessors
pc=[value].pack("i")
Preprocess_ctl.call(pr, flag, pc)
end
end
def getctl_int(flag)
pc=[0].pack("i")
Preprocess_ctl.call(@preprocessors[0], flag, pc)
return pc.unpack("i").first
end
def setctl_float(flag, value)
for pr in @preprocessors
pc=[value].pack("f")
Preprocess_ctl.call(pr, flag, pc)
end
end
def getctl_float(flag)
pc=[0.0].pack("f")
Preprocess_ctl.call(@preprocessor[0], flag, pc)
return pc.unpack("f").first
end
end

end