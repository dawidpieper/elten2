# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

require "openssl"
require "socket"

class VoIP
  module Type
    Transmitter = 0x11
    Listener = 0x12
  end

  module MSGType
    Transmission = 0x21
  end

  module Command
    Handshake = 0x90
    NewUser = 0x91
    LoginUser = 0x92
    ListChannels = 0x93
    JoinChannel = 0x94
    CreateChannel = 0x95
    EditChannel = 0x96
    RegisterClient = 0x97
    ListChannelUsers = 0x98

    Disconnect = 0x9F
  end

  module Response
    OK = 0x80
    Error = 0x81
    Unknown = 0x82
    Continue = 0x83
    Elapsed = 0x84
    Changed = 0x85
  end

  def makebyte(i)
    [i].pack("c")
  end

  def makeint(b)
    b.unpack("c").first
  end

  Bitrates = [6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 160, 192, 256, 320, 448, 512]
  FrameSizes = [2.5, 5, 10, 20, 40, 60]

  def decode_quality(quality)
    framesize = FrameSizes[(quality >> 1 & 1) + (quality >> 1 & 2) + (quality >> 1 & 4)]
    bitrate = Bitrates[(quality >> 4 & 1) + (quality >> 4 & 2) + (quality >> 4 & 4) + (quality >> 4 & 8)]
    return nil if framesize == nil || bitrate == nil
    return bitrate, framesize
  end

  def encode_quality(bitrate, framesize)
    b = Bitrates.index(bitrate)
    f = FrameSizes.index(framesize)
    return nil if b == nil || f == nil
    return b * 16 + f * 2
  end

  class AudioStream
    attr_reader :socket

    def initialize(key, secret)
      @key = key
      @udp = UDPSocket.new
      @udp.connect("elten-net.eu", 8133)
      @socket.send(secret, 0)
      return nil if makeint(@socket.recvfrom(1)) != Response::Ok
      @cipher = OpenSSL::Cipher::AES256.new :XTS
      @cipher.key = key
    end

    def send(frame)
      return false if !@cipher
      @cipher.encrypt
      data = @cipher.random_iv + @cipher.update(frame + Digest::CRC8.digest(frame)) + @cipher.final
      @socket.send(data, 0)
      return true
    rescue Exception
      return false
    end

    def receive
      return nil if !@cipher
      data = @socket.recvfrom(1048576)
      @cipher.decrypt
      @cipher.iv = data.byteslice(0..15)
      msg = @cipher.update(data.byteslice(16..-1)) + @cipher.final
      return nil if Digest::CRC8.checksum(msg.byteslice(0...-1)) != msg.getbyte(-1)
      return msg.byteslice(0..-2)
    rescue Exception
      return nil
    end
  end

  attr_reader :connected

  def initialize
    @transmitter = nil
    @listeners = []
    @uid = nil
    @chid = nil
    @connected = false
  end

  def connect(username)
    @socket = TCPSocket.new("elten-net.eu", 8133)
    @ssl = OpenSSL::SSL::SSLSocket.new(@socket, OpenSSL::SSL::SSLContext.new)
    @ssl.connect
    @ssl.write(makebyte(Command::Handshake))
    return false if makeint(@ssl.read(1)) != Response::OK
    @ssl.write(makebyte(Command::NewUser))
    return false if makeint(@ssl.read(1)) != Response::Continue
    @ssl.write(makebyte(username.size))
    @ssl.write(username)
    return false if makeint(@ssl.read(1)) != Response::OK
    @uid = @ssl.read(16)
    @thread = Thread.new { thread }
    @connected = true
    return true
  rescue Exception
    return false
  end

  def joinchannel(chid, name = "", quality = 64, framesize = 10)
    return false if !@connected
    if chid == nil
      @ssl.write(makebyte(Command::CreateChannel))
      return false if makeint(@ssl.read(1)) != Response::Continue
      @ssl.write(makebyte(name.size))
      @ssl.write(name)
      @ssl.write(makebyte(Codec::OPUS))
      @ssl.write(makebyte(bitrate))
      @ssl.write(makebyte(framesize))
      @ssl.write(makebyte(0))
      return false if makeint(@ssl.read(1)) != Response::OK
      @chid = @ssl.read(16)
      @codec = Codec::OPUS
      @bitrate = bitrate
      @framesize = framesize
      @flags = 0
      @chid = chid
    else
      @ssl.write(makebyte(Command::JoinChannel))
      return false if makeint(@ssl.read(1)) != Response::Continue
      @ssl.write(chid)
      return false if makeint(@ssl.read(1)) != Response::OK
      @codec = makeint(@ssl.read(1))
      @bitrate = makeint(@ssl.read(1))
      @framesize = makeint(@ssl.read(1))
      @flags = makeint(@ssl.read(1))
    end
    return true
  rescue Exception
    return false
  end

  def list_users
    @ssl.write(Command::ListChannelUsers)
    return false if @ssl.read(1) != Response::OK
    @chid = @ssl.read(16)
    chusers = {}
    @ssl.read(1).unpack("c").first.times {
      k = @ssl.read(16)
      sz = @ssl.read(1).unpack("c").first
      v = @ssl.read(sz)
      chusers[k] = v
    }
    return chusers
  end

  def thread
    loop do
      if @connected == false
        @ssl.write(Command::Disconnect)
        @ssl.close
        break
      end
    end
  end

  def disconnect
    @connected = false
  end
end
