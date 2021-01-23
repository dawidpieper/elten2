# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class VoIP
  class MessageType
    Audio = 1
    Text = 2
    Whisper = 3
    Reemit = 201
  end

  attr_reader :connected, :latency, :uid

  def initialize
    @latency = 0
    @sendtimes = {}
    @receivetimes = {}
    @sendbytes = 0
    @receivedbytes = 0
    @cur_rx_packets = 0
    @cur_lostpackets = 0
    @starttime = Time.now.to_f
    @tcp = nil
    @udp = nil
    @uid = nil
    @secret = nil
    @chid = 0
    @connected = false
    @cipher_mutex = Mutex.new
    @cipher = OpenSSL::Cipher::AES256.new :CTR
    @channel_secrets = []
    @received = {}
    @tcp_mutex = Mutex.new
    @receive_hooks = []
    @params_hooks = []
    @status_hooks = []
  end

  def connect(username, token)
    tcp = TCPSocket.new("conferencing.elten.link", 8133)
    ctx = OpenSSL::SSL::SSLContext.new()
    @tcp = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
    @tcp.sync_close = true
    @tcp.connect
    resp = command("login", { "login" => username, "token" => token })
    if resp != false
      @uid = resp["id"]
      @secret = Base64.strict_decode64(resp["secret"])
      @tcpthread.exit if @tcpthread != nil
      @tcpthread = Thread.new {
        loop {
          sleep(1)
          update
        }
      }
      connect_udp
      @connected = true
    else
      return false
    end
    return true
  rescue Exception
    return false
  end

  def create_channel(name, public = true, framesize = 60, bitrate = 64, password = nil, spatialization = 0, channels = 2, lang = "", width = 15, height = 15)
    st = command("create", { "name" => name, "public" => public, "framesize" => framesize, "bitrate" => bitrate, "password" => password, "spatialization" => spatialization, "channels" => channels, "lang" => lang, "width" => width, "height" => height })
    log(-1, "Conference: created channel of id #{st["id"]}")
    return st
  end

  def join_channel(id, password = nil)
    log(-1, "Conference: joining channel #{id}")
    r = command("join", { "channel" => id, "password" => password })
    update
    st = r != false && r["status"] == "success"
    if st == true
      log(-1, "Conference: joined channel #{id}")
    else
      log(-1, "Conference: failed to join channel #{id}")
    end
    return st
  end

  def leave_channel
    log(-1, "Conference: leaving channel")
    r = command("leave")
    update
    return r != false && r["status"] == "success"
  end

  def list_channels
    cmd = command("list")
    return {} if cmd == false
    return cmd["channels"]
  end

  def update
    resp = command("update")
    if resp.is_a?(Hash) && resp["updated"]
      log(-1, "Conference: updating parameters")
      @chid = resp["channel"]
      @stamp = resp["channel_stamp"]
      @cur_rx_packets = 0
      @cur_lostpackets = 0
      @index = 1
      @channel_secrets[@stamp] = Base64.strict_decode64(resp["channel_secret"]) if resp["channel_secret"] != nil
      @received = {}
      if resp["params"] != nil
        @params_hooks.each { |h| Thread.new { h.call(resp["params"]) } }
      end
    end
  end

  def disconnect
    log(0, "Conference: disconnecting from server")
    if @udpthread != nil
      @udpthread.exit
      @udpthread = nil
    end
    if @tcpthread != nil
      @tcpthread.exit
      @tcpthread = nil
    end
    if @tcp != nil
      executecommand("close")
      @tcp.close
    end
    @cipher_mutex.synchronize {
      @tcp_mutex.synchronize {
        @tcp = @udp = nil
      }
    }
    @connected = false
  end

  def send(type, message, p1 = 0, p2 = 0)
    return if @chid == 0
    return if message == "" || !message.is_a?(String)
    message = message + ""
    return false if @channel_secrets[@stamp] == nil
    crc = Zlib.crc32(message)
    bytes = [@uid % 256, @uid / 256, @stamp % 256, (@stamp / 256) % 256, @stamp / 256 / 256, @index % 256, @index / 256, type, p1, p2, 0, 0, crc % 256, (crc / 256) % 256, (crc / 256 / 256) % 256, crc / 256 / 256 / 256]
    @index += 1
    data = ("\0" * 16).b
    for i in 0...16
      return false if bytes[i] > 255
      data.setbyte(i, bytes[i])
    end
    @cipher_mutex.synchronize {
      @cipher.encrypt
      @cipher.key = @channel_secrets[@stamp]
      @cipher.iv = data
      data += @cipher.update(message.b).b + @cipher.final.b
    }
    @sendtimes[@index - 1] = Time.now.to_f
    @sendbytes += data.bytesize
    @udp.send(data, 0, "conferencing.elten.link", 8133)
    return true
  end

  def on_params(&block)
    @params_hooks.push(block) if block != nil
  end

  def on_receive(&block)
    @receive_hooks.push(block) if block != nil
  end

  def on_status(&block)
    @status_hooks.push(block) if block != nil
  end

  def mute(user)
    log(-1, "Conference: muting user #{user}")
    command("mute", { "user" => user })
  end

  def unmute(user)
    log(-1, "Conference: unmuting user #{user}")
    command("unmute", { "user" => user })
  end

  def object_add(resid, name, x, y)
    return command("object_add", { "resid" => resid, "name" => name, "x" => x, "y" => y })["id"]
  end

  def object_remove(id)
    command("object_remove", { "id" => id })
  end

  private

  def connect_udp
    log(0, "Conference: connecting to server")
    @udpthread.exit if @udpthread != nil
    @udp = UDPSocket.new()
    @udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVBUF, 16777216)
    @udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, 16777216)
    @sendbytes += @secret.bytesize
    @udp.send(@secret, 0, "conferencing.elten.link", 8133)
    @udpthread = Thread.new {
      loop {
        begin
          data, addr = @udp.recvfrom_nonblock(65536)
          @receivedbytes += data.bytesize
          if @chid != 0
            receive(data)
          end
        rescue IO::EWOULDBLOCKWaitReadable
          IO.select([@udp], nil, nil, 0.01)
        rescue IO::EWOULDBLOCKWaitWritable
          IO.select(nil, [@udp], nil, 0.01)
        rescue Exception
          log(2, "VoIP UDP: " + $!.to_s + " " + $@.to_s)
        end
      }
    }
  end

  def extract(data)
    userid = data.getbyte(0) + data.getbyte(1) * 256
    stamp = data.getbyte(2) + data.getbyte(3) * 256 + data.getbyte(4) * 256 ** 2
    index = data.getbyte(5) + data.getbyte(6) * 256
    type = data.getbyte(7)
    return [userid, stamp, index, type]
  end

  def receive(data)
    data = data + ""
    data = data.b
    userid, stamp, index, type = extract(data)
    @received[userid] ||= []
    @cur_rx_packets += 1
    if index > 10
      cr = index - (@received[userid].max || 0) - 1
      @cur_lostpackets += cr if cr > 0 && cr < 5
    end
    return if userid != 0 && @received[userid].include?(index)
    @received[userid].push(index) if userid != 0
    message = ""
    crc = data.getbyte(12) + data.getbyte(13) * 256 + data.getbyte(14) * 256 ** 2 + data.getbyte(15) * 256 ** 3
    p1 = data.getbyte(8)
    p2 = data.getbyte(9)
    if data.bytesize > 16
      @cipher_mutex.synchronize {
        @cipher.decrypt
        @cipher.iv = data.byteslice(0...16)
        @cipher.key = @channel_secrets[stamp] || @channel_secrets[@stamp]
        message = @cipher.update(data.byteslice(16..-1)).b + @cipher.final
      }
    end
    if userid == @uid
      @receivetimes[index] = Time.now.to_f
      if @receivetimes.size > 50
        s = 0
        r = 0
        c = 0
        for ind in @receivetimes.keys
          if @sendtimes[ind] != nil
            r += @receivetimes[ind]
            s += @sendtimes[ind]
            c += 1
          end
        end
        @receivetimes.clear
        @sendtimes.clear
        @latency = (r - s) / c.to_f
      end
    end
    if Time.now.to_f - (@statustime || 0) > 5
      @status_hooks.each { |h| h.call(@latency, @sendbytes, @receivedbytes, @cur_lostpackets, @cur_rx_packets, Time.now.to_f - @starttime) }
      @statustime = Time.now.to_f
    end
    @receive_hooks.each { |h| h.call(userid, type, message, p1, p2) } if Zlib.crc32(message) == crc
  rescue Exception
    log(2, "VoIP Receive: " + $!.to_s + " " + $@.to_s)
  end

  def executecommand(cmd, params = {})
    return false if @tcp == false
    json = { ":command" => cmd }
    for k in params.keys
      json[k] = params[k]
    end
    for k in json.keys
      if json[k].is_a?(String)
        json[k] = json[k] + ""
        json[k].force_encoding("UTF-8")
      end
    end
    ans = nil
    rec = false
    txt = JSON.generate(json)
    @tcp_mutex.synchronize {
      begin
        @sendbytes += txt.bytesize + 1
        @tcp.write(txt.b + "\n")
      rescue Exception
        rec = true
      end
    }
    return rec
  end

  def command(cmd, params = {})
    executecommand(cmd, params)
    rec = false
    begin
      ans = @tcp.readline
      @receivedbytes += ans.bytesize
    rescue Exception
      rec = true
    end
    if rec == false
      json = JSON.load(ans)
      return false if json["status"] != "success"
      return json
    else
      disconnect
      return false
    end
  end
end
