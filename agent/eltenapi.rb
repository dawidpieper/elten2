# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

require("./bass.rb")

def cryptmessage(msg)
  buf = "\0" * (msg.bytesize + 18)
  begin
    $cryptmessage.call(msg, buf, buf.bytesize)
    return buf
  rescue Exception
    return ""
  end
end

def unicode(str)
  return nil if str == nil
  buf = "\0" * $multibytetowidechar.call(65001, 0, str, str.bytesize, nil, 0) * 2
  $multibytetowidechar.call(65001, 0, str, str.bytesize, buf, buf.bytesize / 2)
  return buf << "\0"
end

def deunicode(str)
  return "" if str == nil
  str << "\0\0"
  buf = "\0" * $widechartomultibyte.call(65001, 0, str, -1, nil, 0, 0, nil)
  $widechartomultibyte.call(65001, 0, str, -1, buf, buf.bytesize, nil, nil)
  return buf[0..buf.index("\0") - 1]
end

def readini(file, group, key, default = "")
  r = "\0" * 16384
  sz = $getprivateprofilestring.call(unicode(group), unicode(key), unicode(default), r, r.bytesize, unicode(file))
  return deunicode(r[0..(sz * 2)]).delete("\0")
end

def readconfig(group, key, val = "")
  r = readini($eltendata + "\\elten.ini", group, key, val.to_s)
  return r.to_i if val.is_a?(Integer)
  return r
end

def speech(text, method = 0)
  text = text.to_s
  text = text.gsub("\004LINE\004") { "\r\n" }
  $speech_lasttext = text
  if $voice == -1
    $saystring.call(unicode(text), method)
  else
    ssml = "<pitch absmiddle=\"#{((($sapipitch || 50) / 5.0) - 10.0).to_i}\"/>"
    ssml += text.gsub("<", "&lt;").gsub(">", "&gt;")
    $sapispeakssml.call(unicode(ssml))
  end
  $speech_lasttime = Time.now.to_f
  return text
end

def speech_stop
  (($voice != -1) ? $sapistopspeech : $stopspeech).call
end

def speech_actived
  ($voice == -1) ? false : (($sapiisspeaking.call == 1) ? true : false)
end

def speech_wait
  sleep 0.01 while speech_actived
end

def run(file, hide = false)
  env = 0
  env = "Windows".split(File::PATH_SEPARATOR) << nil
  env = env.pack("p*").unpack("L").first
  startinfo = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  startinfo = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0] if hide
  startinfo = startinfo.pack("LLLLLLLLLLLLSSLLLL")
  procinfo = [0, 0, 0, 0].pack("LLLL")
  pr = $createprocess.call(0, (file), 0, 0, 0, 0, 0, 0, startinfo, procinfo)
  procinfo[0, 4].unpack("L").first # pid
  return procinfo.unpack("llll")[0]
end

def getdirectory(type)
  dr = "\0" * 520
  $shgetfolderpath.call(0, type, 0, 0, dr)
  fdr = deunicode(dr)
  return fdr[0..fdr.index("\0") || -1]
end

DRAFT = "h2".freeze

def init
  $sockthread.exit if $sockthread != nil
  $sock = TCPSocket.new("elten-net.eu", 443)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.alpn_protocols = [DRAFT]
  $ssl = OpenSSL::SSL::SSLSocket.new($sock, ctx)
  $ssl.sync_close = true
  $ssl.hostname = "elten-net.eu"
  $ssl.connect
  $http = HTTP2::Client.new
  $http.on(:frame) { |bytes|
    $ssl.print bytes
    $ssl.flush
  }
  $sockthread = Thread.new {
    while !$ssl.closed? && !$ssl.eof?
      data = $ssl.read_nonblock(1024)
      $http << data
    end
  }
  $http.on(:error) { |error| init if error.is_a?(Errno::ECONNRESET) or error.is_a?(SocketError) }
rescue Exception
end

def erequest(mod, param, post = nil, headers = {}, data = nil, ign = false, &b)
  headers = {} if headers == nil
  headers["User-Agent"] = "Elten #{$version} agent"
  init if $http == nil
  $lastrep ||= Time.now.to_i
  init if $lastrep < Time.now.to_i - 20
  begin
    if (t = Time.now).min % 15 == 14 and t.sec >= 58
      sleep(60 - t.sec + 2)
    end
    stream = $http.new_stream
    head = {
      ":scheme" => "https",
      ":authority" => "elten-net.eu:443",
      ":path" => "/srv/#{mod}.php?#{param}"
    }
    if post == nil
      head[":method"] = "GET"
    else
      head[":method"] = "POST"
      head["content-length"] = post.bytesize.to_s
    end
    headers.keys.each { |k| head[k] = headers[k] }
    stream.headers(head, end_stream: (post == nil || post == ""))
    if post != nil && post != ""
      until post.empty?
        ch = post.slice!(0...4096)
        stream.data(ch, end_stream: (post.empty?))
      end
    end
    body = ""
    stream.on(:data) { |ch| body += ch }
    stream.on(:half_close) { stream.close }
    stream.on(:close) { $eropened = nil; $lastrep = Time.now.to_i; b.call(body, data) }
  rescue Exception
    init
    retry if !ign
  end
end

def ejrequest(method, path, params, data = nil, &b)
  init if $http == nil
  $lastrep ||= Time.now.to_i
  init if $lastrep < Time.now.to_i - 20
  begin
    if (t = Time.now).min % 15 == 14 and t.sec >= 58
      sleep(60 - t.sec + 2)
    end
    stream = $http.new_stream
    j = JSON.generate(params)
    head = {
      ":scheme" => "https",
      ":authority" => "api.elten-net.eu:443",
      ":path" => path,
      "user-agent" => "Elten #{$version} agent",
      "content-type" => "application/json",
      ":method" => method,
      "content-length" => j.bytesize.to_s
    }
    stream.headers(head, end_stream: false)
    until j.empty?
      ch = j.slice!(0...4096)
      stream.data(ch, end_stream: (j.empty?))
    end
    body = ""
    stream.on(:headers) { |h| data["headers"] = h if data.is_a?(Hash) }
    stream.on(:data) { |ch| body += ch }
    stream.on(:half_close) { stream.close }
    stream.on(:close) {
      $eropened = nil
      $lastrep = Time.now.to_i
      b.call(body, data)
    }
  rescue Exception
    init
    retry
  end
end

class EltenSock
  def initialize
    @sock = TCPSocket.new("elten-net.eu", 80)
  end

  def write(wr)
    @sock.write(wr)
  end

  def read(rd = 1024)
    @sock.read(rd)
  end

  def close
    @sock.close
  end
end

def play(file, looper = false)
  begin
    if file[0..3] != "http"
      return if $SoundThemeActivation == 0
      f = ($soundthemepath || "Audio") + "\\SE\\#{file}.ogg"
      f = "Audio/SE/#{file}.ogg" if FileTest.exists?(f) == false
      f = "Audio/BGS/#{file}.ogg" if FileTest.exists?(f) == false
    else
      f = file
    end
    $plid ||= 0
    $players ||= []
    $plid = ($plid + 1) % 128
    plid = $plid
    begin
      pl = Bass::Sound.new(f, 1, looper)
      pl.volume = ($volume.to_f / 100.0)
      pl.play
      if looper
        $bgplayer.close if $bgplayer != nil
        $bgplayer = pl
      else
        $players[plid].close if $players[plid] != nil
        $players[plid] = pl
      end
    rescue Exception
      begin
        Bass.init($hwnd || 0)
      rescue Exception
      end
    end
  rescue Exception
  end
end

def log(level, msg)
  ewrite({ "func" => "log", "level" => level, "msg" => msg, "time" => Time.now.to_f })
end

def decrypt(data, code = nil)
  pin = [data.size, data].pack("ip")
  pout = [0, nil].pack("ip")
  pcode = nil
  pcode = [code.size, code].pack("ip") if code != nil
  $cryptunprotectdata.call(pin, nil, pcode, nil, nil, 0, pout)
  s, t = pout.unpack("ii")
  m = "\0" * s
  $rtlmovememory.call(m, t, s)
  $localfree.call(t)
  return m
end

def crypt(data, code = nil)
  pin = [data.size, data].pack("ip")
  pout = [0, nil].pack("ip")
  pcode = nil
  pcode = [code.size, code].pack("ip") if code != nil
  $cryptprotectdata.call(pin, nil, pcode, nil, nil, 0, pout)
  s, t = pout.unpack("ii")
  m = "\0" * s
  $rtlmovememory.call(m, t, s)
  $localfree.call(t)
  return m
end
