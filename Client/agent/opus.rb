module Opus
Opus=Fiddle.dlopen("opus.dll")

Encoder_create = Fiddle::Function.new(Opus['opus_encoder_create'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
Encoder_destroy = Fiddle::Function.new(Opus['opus_encoder_destroy'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
Encode = Fiddle::Function.new(Opus['opus_encode'], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
Encoder_ctl = Fiddle::Function.new(Opus['opus_encoder_ctl'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

Decoder_create = Fiddle::Function.new(Opus['opus_decoder_create'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
Decoder_destroy = Fiddle::Function.new(Opus['opus_decoder_destroy'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
Decode = Fiddle::Function.new(Opus['opus_decode'], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
Decoder_ctl = Fiddle::Function.new(Opus['opus_decoder_ctl'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

class Encoder
attr_reader :freq
attr_reader :ch
attr_reader :app
def initialize(freq=48000, ch=2, app=:audio)
@freq, @ch, @app = freq, ch, app
if app==:voip
app=2048
else
app=2049
end
err=[0].pack("i")
@encoder=Encoder_create.call(freq, ch, app, err)
end
def free
Encoder_destroy.call(@encoder)
@encoder=nil
end
def reset
Encoder_ctl.call(@encoder,4028,[0].pack("i"))
end
def bitrate
r=[0].pack("i")
Encoder_ctl.call(@encoder,4003,r)
r.unpack("i").first
end
def bitrate=(b)
Encoder_ctl.call(@encoder,4002,b)
end
def vbr
r=[0].pack("i")
Encoder_ctl.call(@encoder,4007,r)
r.unpack("i").first
end
def vbr=(v)
Encoder_ctl.call(@encoder,4006,v)
end
def complexity
r=[0].pack("i")
Encoder_ctl.call(@encoder,4011,r)
r.unpack("i").first
end
def complexity=(c)
Encoder_ctl.call(@encoder,4010,c)
end
def packetloss
r=[0].pack("i")
Encoder_ctl.call(@encoder,4015,r)
r.unpack("i").first
end
def packetloss=(a)
Encoder_ctl.call(@encoder,4014,a)
end
def signal
r=[0].pack("i")
Encoder_ctl.call(@encoder,4025,r)
case r.unpack("i").first
when -1000
return :auto
when 3001
return :voice
when 3002
return :music
end
end
def signal=(s)
g=-1000
g=3001 if s==:voice
g=3002 if s==:music
Encoder_ctl.call(@encoder,4024,g)
end
def encode(data,fs=20)
fs=@freq*fs/1000
out="\0"*1280
sz=Encode.call(@encoder, data, fs, out, 1280)
return "" if sz<0
return out.byteslice(0...sz)
end
end

class Decoder
attr_reader :fs
attr_reader :ch
def initialize(freq=48000, ch=2)
@freq, @ch = freq, ch
err=[0].pack("i")
@decoder=Decoder_create.call(freq, ch, err)
end
def free
Decoder_destroy.call(@decoder)
@decoder=nil
end
def reset
Decoder_ctl.call(@decoder,4028,[0].pack("i"))
end
def decode(data)
toc=data.getbyte(0)
c=toc>>3
fs=2.5 if [16,20,24,28].include?(c)
fs=5 if [17,21,25,29].include?(c)
fs=10 if [0,4,8,12,14,18,22,26,30].include?(c)
fs=20 if [1,5,9,13,15,19,23,27,31].include?(c)
fs=40 if [2,6,10].include?(c)
fs=60 if [3,7,11].include?(c)
if (toc&1)==0 and (toc&2)==0
sz=@freq*@ch*fs/1000
elsif ((toc&1)==1 and (toc&2)==0) or ((toc&1)==0 and (toc&2)==2)
sz=@freq*@ch*fs*2/1000
elsif (toc&1)==1 and (toc&2)==2
b=data.getbyte(1)
n=(b&1)+(b&2)+(b&4)+(b&8)+(b&16)
sz=@freq*@ch*fs*n/1000
end
out="\0"*sz*2
Decode.call(@decoder, data, data.bytesize, out, @freq, 0)
return out
end
end

end