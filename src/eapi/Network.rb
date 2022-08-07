# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2022 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module Network
    private

    # The Network related functions
    # Downloads a file
    #
    # @param source [String] an URL of a file to download
    # @param destination [String] the file destination
    # @param threading [Boolean] use threading to download, recommended for large files
    # @return [Numeric] if the function succeeds, the return value is 0. Otherwise, the return value is an urlmon error code.
    # @example Downloading Onet main page with threading enabled
    #  download("http://onet.pl","onet.html",true)
    def download(source, destination, threading = false)
      source.delete!("\r\n")
      destination.delete!("\r\n")
      $downloadcount = 0 if $downloadcount == nil
      source.sub!("?", "?eltc=#{$downloadcount.to_s(36)}\&") if source.include?($url)
      $downloadcount += 1
      ef = -1
      $downloading = true
      ef = 0
      begin
        if threading == true
          Thread.new do
            begin
              ef = Win32API.new("urlmon", "URLDownloadToFileW", "pppip", "i").call(nil, unicode(source), unicode(destination), 0, nil)
            rescue Exception
              #retry
            end
          end
          i = 0
          while ef == -1
            i += 1
            return -1 if i > 100
          end
        else
          ef = Win32API.new("urlmon", "URLDownloadToFileW", "pppip", "i").call(nil, unicode(source), unicode(destination), 0, nil)
        end
      rescue Exception
        Graphics.update
        #retry
      end
      play("signal") if $netsignal == true
      $downloading = false
      Win32API.new("wininet", "DeleteUrlCacheEntryW", "p", "i").call(unicode(source))
      if FileTest.exist?(destination) == false and (source.include?("php"))
        writefile(destination, -4)
      else
        if source.downcase.include?(".php") or source.downcase.include?(".eapi")
          des = readfile(destination)
          if des[0] == 239 and des[1] == 187 and des[2] == 191
            des = des[3..des.size - 1]
            File.delete(destination)
            writefile(destination, des)
          end
        end
      end
      return ef
    end

    # @deprecated use WinSock interface instead
    def elconnect(data, len = 2048, msg = p_("EAPI_Network", "sending..."))
      id = rand(10 ** 8)
      $eltsocks_create ||= {}
      $eltsocks_write ||= {}
      $eltsocks_read ||= {}
      $eltsocks_close ||= {}
      $agent.write(Marshal.dump({ "func" => "eltsock_create", "id" => id }))
      while $eltsocks_create[id] == nil
        loop_update
      end
      sockid = $eltsocks_create[id]["sockid"]
      $eltsocks_create[id] = nil
      t = 0
      ti = Time.now.to_i
      s = false
      if data.size <= 1048576
        $agent.write(Marshal.dump({ "func" => "eltsock_write", "sockid" => sockid, "message" => data, "id" => id }))
        while $eltsocks_write[id] == nil
          loop_update
        end
        $eltsocks_write[id] = nil
      else
        speech(msg)
        waiting {
          places = []
          until data.empty?
            places << data.slice!(0..524287)
          end
          sent = ""
          for i in 0..places.size - 1
            loop_update
            speech(((i.to_f / (places.size.to_f + 1.0)) * 100.0).to_i.to_s + "%") if speech_actived == false
            $agent.write(Marshal.dump({ "func" => "eltsock_write", "id" => id, "message" => places[i], "sockid" => sockid }))
            while $eltsocks_write[id] == nil
              loop_update
            end
            $eltsocks_write[id] = nil
          end
        }
      end
      b = ""
      t = 0
      $agent.write(Marshal.dump({ "func" => "eltsock_read", "sockid" => sockid, "id" => id, "size" => len }))
      while $eltsocks_read[id] == nil
        loop_update
      end
      b = $eltsocks_read[id]["message"]
      $eltsocks_read[id] = nil
      $agent.write(Marshal.dump({ "func" => "eltsock_close", "sockid" => sockid, "id" => id }))
      while $eltsocks_close[id] == nil
        loop_update
      end
      $eltsocks_close[id] = nil
      return b
    end

    def read_url(url, method = :get, body = nil, headers = nil)
      Log.debug("Read URL #{url}")
      play("signal") if $netsignal
      headers = {} if headers == nil
      if body != nil && body.is_a?(Hash)
        boundary = ""
        while boundary == "" || post.include?(boundary)
          boundary = "----EltBoundary" + rand(36 ** 32).to_s(36)
        end
        txt = ""
        for h in data.keys
          txt += "--" + boundary + "\r\nContent-Disposition: form-data; name=\"#{h}\"\r\n\r\n#{post[h]}\r\n"
        end
        txt += "--#{boundary}--"
        body = txt
        headers["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      end
      if $agent != nil
        id = rand(1e16)
        $agent.write(Marshal.dump({ "func" => "readurl", "url" => url, "id" => id, "headers" => headers, "body" => body, "method" => method.to_s }))
        $agids ||= []
        $agids.push(id)
        t = Time.now.to_f
        w = false
        while $eresps[id] == nil
          loop_update(false)
          if Time.now.to_f - t > 2 and w == false
            waiting
            w = true
          elsif Time.now.to_f - t > 30
            Log.warning("Session timed out for URL read from #{url}")
            waiting_end
            return nil
          end
          if escape and w
            play("cancel")
            Log.debug("URL read request from #{url} cancelled by user")
            waiting_end
            return nil
          end
        end
        waiting_end if w
        rsp = $eresps[id]
        $eresps.delete(id)
        return nil if rsp == nil
        if headers != nil
          headers.clear
          j = JSON.load(rsp["headers"])
          if j.is_a?(Hash)
            for k, v in j
              headers[k] = v
            end
          end
        end
        return rsp["body"]
      end
      return nil
    end

    def download_file(source, destination, useWaiting = true, canCancel = true, override = false)
      return if override == false and FileTest.exists?(destination) and confirm(p_("EAPI_Network", "The file already exists. Do you want to override it?")) == 0
      Log.debug("Downloading file #{source}")
      play("signal") if $netsignal
      if $agent != nil
        id = rand(1e16)
        $agent.write(Marshal.dump({ "func" => "downloadfile", "source" => source, "destination" => destination, "id" => id }))
        $agids ||= []
        $agids.push(id)
        t = Time.now.to_f
        w = false
        while $eresps[id] == nil
          loop_update(false)
          if $eprogresses[id].is_a?(Integer) && useWaiting
            speak($eprogresses[id].to_s + "%")
            $eprogresses[id] = nil
          end
          if Time.now.to_f - t > 1 and w == false
            waiting if useWaiting
            w = true
          end
          if escape and w and canCancel
            eplay("cancel")
            Log.debug("Download of #{source} cancelled by user")
            waiting_end if useWaiting
            return false
          end
        end
        waiting_end if w && useWaiting
        rsp = $eresps[id]
        if rsp["size"].is_a?(Integer)
          return true
        else
          return false
        end
      end
    end

    alias downloadfile download_file

    # Downloads a file, creates download progress dialog
    #
    # @param url [String] an URL of a file to download
    # @param destination [String] location to an output file
    # @param msg [String] downloading dialog header
    def adownloadfile(url, destination, msg = "", msgcomplete = nil, override = nil, progress = true)
      return if override == nil and FileTest.exists?(destination) and confirm(p_("EAPI_Network", "The file already exists. Do you want to override it?")) == 0
      Log.debug("Downloading file: #{url}")
      play("signal") if $netsignal == true
      host = $url
      port = 80
      cnt = ""
      if (/https?:\/\/([a-zA-Z0-9\.\-]+)([\:0-9]+)?\/([^$]+)/ =~ url) != nil
        host = $1
        port = $2.to_i if $2.to_i != 0
        cnt = $3
      end
      addr = Socket.sockaddr_in(port.to_i, host)
      sock = Socket.new(2, 0, 0)
      sock.connect(addr).to_s
      data = "GET /#{cnt} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\n\r\n"
      if $ruby != true
        s = sock.send(data)
      else
        s = sock.write(data)
      end
      ans = {}
      o = ""
      loop do
        b = ""
        while b.include?("\n") == false
          s = sock.recv(1)
          b += s if s != nil and s != "\0"
        end
        o += b
        break if b == "\n" or b == "\r\n"
        key = ""
        val = ""
        if (/([a-zA-Z0-9\-]+)\: ([a-zA-Z0-9\/\:\-,.\/\\_\+!@ ]+)\r?\n/ =~ b) != nil
          key = $1
          val = $2
        end
        ans[key.downcase] = val if key != ""
      end
      l = ans["content-length"].to_i
      tx = ""
      waiting if msg != nil
      speech(msg)
      sptm = Time.now.to_i
      i = 0
      sil = false
      cf = Win32API.new("kernel32", "CreateFileW", "piipiip", "i")
      handle = cf.call(unicode(destination), 2, 1 | 2 | 4, nil, 2, 0, nil)
      wrfile = Win32API.new("kernel32", "WriteFile", "ipipi", "I")
      bp = [0].pack("l")
      while i < l
        b = ""
        while b == nil or b == ""
          sz = 262144
          sz = l - i if l - i < sz
          b = sock.recv(sz)
        end
        i += b.size
        loop_update
        if progress
          if space
            if sil == false
              sil = true
              alert(p_("EAPI_Network", "Do not report progress bar changes."))
            else
              sil = false
              alert(p_("EAPI_Network", "Read progress bar changes."))
            end
          end
          if sptm + 3 < Time.now.to_i
            sptm = Time.now.to_i
            speech("#{((i.to_f / l.to_f * 100.0).round).to_s}%") if speech_actived == false and sil == false
          end
        end
        tx += b
        if tx.size > 16 * 1048576 or i >= l
          r = wrfile.call(handle, tx, tx.size, bp, 0)
          tx = ""
        end
        b = ""
      end
      Win32API.new("kernel32", "CloseHandle", "i", "i").call(handle)
      waiting_end if msg != nil
      speech(msgcomplete) if msgcomplete != nil
    end

    HTML_PreCodes = {
      "&quot;" => "&#34;",
      "&amp;" => "&#38;",
      "&apos;" => "&#39;",
      "&lt;" => "&#60;",
      "&gt;" => "&#62;",
      "&Agrave;" => "&#192;",
      "&Aacute;" => "&#193;",
      "&Acirc;" => "&#194;",
      "&Atilde;" => "&#195;",
      "&Auml;" => "&#196;",
      "&Aring;" => "&#197;",
      "&AElig;" => "&#198;",
      "&Ccedil;" => "&#199;",
      "&Egrave;" => "&#200;",
      "&Eacute;" => "&#201;",
      "&Ecirc;" => "&#202;",
      "&Euml;" => "&#203;",
      "&Igrave;" => "&#204;",
      "&Iacute;" => "&#205;",
      "&Icirc;" => "&#206;",
      "&Iuml;" => "&#207;",
      "&ETH;" => "&#208;",
      "&Ntilde;" => "&#209;",
      "&Ograve;" => "&#210;",
      "&Oacute;" => "&#211;",
      "&Ocirc;" => "&#212;",
      "&Otilde;" => "&#213;",
      "&Ouml;" => "&#214;",
      "&Oslash;" => "&#216;",
      "&Ugrave;" => "&#217;",
      "&Uacute;" => "&#218;",
      "&Ucirc;" => "&#219;",
      "&Uuml;" => "&#220;",
      "&Yacute;" => "&#221;",
      "&THORN;" => "&#222;",
      "&szlig;" => "&#223;",
      "&agrave;" => "&#224;",
      "&aacute;" => "&#225;",
      "&acirc;" => "&#226;",
      "&atilde;" => "&#227;",
      "&auml;" => "&#228;",
      "&aring;" => "&#229;",
      "&aelig;" => "&#230;",
      "&ccedil;" => "&#231;",
      "&egrave;" => "&#232;",
      "&eacute;" => "&#233;",
      "&ecirc;" => "&#234;",
      "&euml;" => "&#235;",
      "&igrave;" => "&#236;",
      "&iacute;" => "&#237;",
      "&icirc;" => "&#238;",
      "&iuml;" => "&#239;",
      "&eth;" => "&#240;",
      "&ntilde;" => "&#241;",
      "&ograve;" => "&#242;",
      "&oacute;" => "&#243;",
      "&ocirc;" => "&#244;",
      "&otilde;" => "&#245;",
      "&ouml;" => "&#246;",
      "&oslash;" => "&#248;",
      "&ugrave;" => "&#249;",
      "&uacute;" => "&#250;",
      "&ucirc;" => "&#251;",
      "&uuml;" => "&#252;",
      "&yacute;" => "&#253;",
      "&thorn;" => "&#254;",
      "&yuml;" => "&#255;",
      "&nbsp;" => "&#160;",
      "&iexcl;" => "&#161;",
      "&cent;" => "&#162;",
      "&pound;" => "&#163;",
      "&curren;" => "&#164;",
      "&yen;" => "&#165;",
      "&brvbar;" => "&#166;",
      "&sect;" => "&#167;",
      "&uml;" => "&#168;",
      "&copy;" => "&#169;",
      "&ordf;" => "&#170;",
      "&laquo;" => "&#171;",
      "&not;" => "&#172;",
      "&shy;" => "&#173;",
      "&reg;" => "&#174;",
      "&macr;" => "&#175;",
      "&deg;" => "&#176;",
      "&plusmn;" => "&#177;",
      "&sup2;" => "&#178;",
      "&sup3;" => "&#179;",
      "&acute;" => "&#180;",
      "&micro;" => "&#181;",
      "&para;" => "&#182;",
      "&cedil;" => "&#184;",
      "&sup1;" => "&#185;",
      "&ordm;" => "&#186;",
      "&raquo;" => "&#187;",
      "&frac14;" => "&#188;",
      "&frac12;" => "&#189;",
      "&frac34;" => "&#190;",
      "&iquest;" => "&#191;",
      "&times;" => "&#215;",
      "&divide;" => "&#247;",
      "&forall;" => "&#8704;",
      "&part;" => "&#8706;",
      "&exist;" => "&#8707;",
      "&empty;" => "&#8709;",
      "&nabla;" => "&#8711;",
      "&isin;" => "&#8712;",
      "&notin;" => "&#8713;",
      "&ni;" => "&#8715;",
      "&prod;" => "&#8719;",
      "&sum;" => "&#8721;",
      "&minus;" => "&#8722;",
      "&lowast;" => "&#8727;",
      "&radic;" => "&#8730;",
      "&prop;" => "&#8733;",
      "&infin;" => "&#8734;",
      "&ang;" => "&#8736;",
      "&and;" => "&#8743;",
      "&or;" => "&#8744;",
      "&cap;" => "&#8745;",
      "&cup;" => "&#8746;",
      "&int;" => "&#8747;",
      "&there4;" => "&#8756;",
      "&sim;" => "&#8764;",
      "&cong;" => "&#8773;",
      "&asymp;" => "&#8776;",
      "&ne;" => "&#8800;",
      "&equiv;" => "&#8801;",
      "&le;" => "&#8804;",
      "&ge;" => "&#8805;",
      "&sub;" => "&#8834;",
      "&sup;" => "&#8835;",
      "&nsub;" => "&#8836;",
      "&sube;" => "&#8838;",
      "&supe;" => "&#8839;",
      "&oplus;" => "&#8853;",
      "&otimes;" => "&#8855;",
      "&perp;" => "&#8869;",
      "&sdot;" => "&#8901;",
      "&Alpha;" => "&#913;",
      "&Beta;" => "&#914;",
      "&Gamma;" => "&#915;",
      "&Delta;" => "&#916;",
      "&Epsilon;" => "&#917;",
      "&Zeta;" => "&#918;",
      "&Eta;" => "&#919;",
      "&Theta;" => "&#920;",
      "&Iota;" => "&#921;",
      "&Kappa;" => "&#922;",
      "&Lambda;" => "&#923;",
      "&Mu;" => "&#924;",
      "&Nu;" => "&#925;",
      "&Xi;" => "&#926;",
      "&Omicron;" => "&#927;",
      "&Pi;" => "&#928;",
      "&Rho;" => "&#929;",
      "&Sigma;" => "&#931;",
      "&Tau;" => "&#932;",
      "&Upsilon;" => "&#933;",
      "&Phi;" => "&#934;",
      "&Chi;" => "&#935;",
      "&Psi;" => "&#936;",
      "&Omega;" => "&#937;",
      "&alpha;" => "&#945;",
      "&beta;" => "&#946;",
      "&gamma;" => "&#947;",
      "&delta;" => "&#948;",
      "&epsilon;" => "&",
      "&zeta;" => "&#950;",
      "&eta;" => "&#951;",
      "&theta;" => "&#952;",
      "&iota;" => "&#953;",
      "&kappa;" => "&#954;",
      "&lambda;" => "&#955;",
      "&mu;" => "&#956;",
      "&nu;" => "&#957;",
      "&xi;" => "&#958;",
      "&omicron;" => "&#959;",
      "&pi;" => "&#960;",
      "&rho;" => "&#961;",
      "&sigmaf;" => "&#962;",
      "&sigma;" => "&#963;",
      "&tau;" => "&#964;",
      "&upsilon;" => "&#965;",
      "&phi;" => "&#966;",
      "&chi;" => "&#967;",
      "&psi;" => "&#968;",
      "&omega;" => "&#969;",
      "&thetasym;" => "&#977;",
      "&upsih;" => "&#978;",
      "&piv;" => "&#982;",
      "&OElig;" => "&#338;",
      "&oelig;" => "&#339;",
      "&Scaron;" => "&#352;",
      "&scaron;" => "&#353;",
      "&Yuml;" => "&#376;",
      "&fnof;" => "&#402;",
      "&circ;" => "&#710;",
      "&tilde;" => "&#732;",
      "&ensp;" => "&#8194;",
      "&emsp;" => "&#8195;",
      "&thinsp;" => "&#8201;",
      "&zwnj;" => "&#8204;",
      "&zwj;" => "&#8205;",
      "&lrm;" => "&#8206;",
      "&rlm;" => "&#8207;",
      "&ndash;" => "&#8211;",
      "&mdash;" => "&#8212;",
      "&lsquo;" => "&#8216;",
      "&rsquo;" => "&#8217;",
      "&sbquo;" => "&#8218;",
      "&ldquo;" => "&#8220;",
      "&rdquo;" => "&#8221;",
      "&bdquo;" => "&#8222;",
      "&dagger;" => "&#8224;",
      "&Dagger;" => "&#8225;",
      "&bull;" => "&#8226;",
      "&hellip;" => "&#8230;",
      "&permil;" => "&#8240;",
      "&prime;" => "&#8242;",
      "&Prime;" => "&#8243;",
      "&lsaquo;" => "&#8249;",
      "&rsaquo;" => "&#8250;",
      "&oline;" => "&#8254;",
      "&euro;" => "&#8364;",
      "&trade;" => "&#8482;",
      "&larr;" => "&#8592;",
      "&uarr;" => "&#8593;",
      "&rarr;" => "&#8594;",
      "&darr;" => "&#8595;",
      "&harr;" => "&#8596;",
      "&crarr;" => "&#8629;",
      "&lceil;" => "&#8968;",
      "&rceil;" => "&#8969;",
      "&lfloor;" => "&#8970;",
      "&rfloor;" => "&#8971;",
      "&loz;" => "&#9674;",
      "&spades;" => "&#9824;",
      "&clubs;" => "&#9827;",
      "&hearts;" => "&#9829;",
      "&diams;" => "&#9830;"
    }

    def html_decode(text)
      t = text + ""
      for k in HTML_PreCodes.keys
        t.gsub!(k, HTML_PreCodes[k])
      end
      t.gsub!(/\&\#(\d+)\;/) {
        code_to_char($1.to_i)
      }
      return t
    end

    def html_encode(text)
      t = text.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;")
      return t
    end
  end

  include Network
end
