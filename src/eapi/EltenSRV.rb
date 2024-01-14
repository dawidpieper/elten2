# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2022 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module EltenSRV
    private

    # Elten Server related functions
    # Makes a request to the Elten server
    #
    # @param mod [String] server module to request
    # @param param [String] & terminated parameters
    # @param output [Numeric] output type: 0 - Array of lines, 1 - string
    def srvproc(mod, param, output = 0, post = nil, useWaiting = true)
      Log.debug("Server request to module #{mod}")
      play("signal") if $netsignal
      preparam = param
      if param.is_a?(Hash)
        if Session.name != nil and Session.token != nil and param["name"] == nil
          param["name"] = Session.name
          param["token"] = Session.token
        end
        prm = ""
        for k in param.keys
          prm += "\&" if prm != ""
          prm += k + "=" + param[k].to_s.urlenc
        end
        param = prm
      end
      headers = {}
      if post != nil && post.is_a?(Hash)
        boundary = ""
        while boundary == "" || post.include?(boundary)
          boundary = "----EltBoundary" + rand(36 ** 32).to_s(36)
        end
        txt = ""
        for h in post.keys
          txt += "--" + boundary + "\r\nContent-Disposition: form-data; name=\"#{h}\"\r\n\r\n#{post[h]}\r\n"
        end
        txt += "--#{boundary}--"
        post = txt
        headers["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
        #writefile("post.dat", Marshal.dump({'mod'=>mod, 'param'=>param, 'post'=>post, 'headers'=>headers}))
      end
      if $agent != nil
        id = rand(1e16)
        $agent.write(Marshal.dump({ "func" => "srvproc", "mod" => mod, "param" => param, "id" => id, "headers" => headers, "post" => post }))
        $agids ||= []
        $agids.push(id)
        t = Time.now.to_f
        w = false
        while $eresps[id] == nil
          loop_update(false)
          if $eprogresses[id].is_a?(Integer)
            speak($eprogresses[id].to_s + "%")
            $eprogresses[id] = nil
          end
          if Time.now.to_f - t > 2 and w == false
            waiting if useWaiting
            w = true
          elsif Time.now.to_f - t > 15 && (!post.is_a?(String) || post.size < 1048576)
            Log.warning("Session timed out for request to module #{mod}")
            waiting_end if useWaiting
            break
          end
          if escape and w
            play("cancel")
            Log.debug("Server request to module #{mod} cancelled by user")
            waiting_end if useWaiting
            case output
            when 0
              return ["-1"]
            when 1
              return "-1"
            when 3
              return 0
            end
          end
        end
        waiting_end if w && useWaiting
        rsp = $eresps[id]
        rsp = { "resp" => "-4" } if rsp == nil
        case output
        when 0
          r = rsp["resp"].delete("\r").split("\n")
          for i in 0...r.size
            r[i] += "\r\n"
          end
          return r
        when 1
          return rsp["resp"]
        when 3
          return 0 if rsp["resptime"] == nil
          return rsp["resptime"] - rsp["reqtime"]
        end
      end
      if preparam.is_a?(String)
        rt = {}
        for r in preparam.split("\&")
          k, v = r.split("=")
          v = "" if v == nil
          v = v.urldec if v.include?("%")
          rt[k] = v
        end
        param = rt
        r = ""
        for k in param.keys
          r += "\&" if r != ""
          r += k + "=" + param[k].urlenc
        end
        param = r
      end
      url = $url + mod + ".php?" + param
      tmpname = Dirs.temp + "/eas#{(rand(36 ** 2).to_s(36))}.tmp"
      if post == nil
        if download(url, tmpname) != 0
          case output
          when 0
            return ["-1"]
          when 1
            return "-1"
          end
        end
      else
        q = "POST /leg1/#{mod}.php?#{param} HTTP/1.1\r\nHost: #{$srv}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\n"
        for h in headers.keys
          q += h + ": " + headers[h] + "\r\n"
        end
        q += "Content-Length: #{post.size}\r\n\r\n#{post}"
        a = elconnect(q)
        a.delete!("\0")
        for i in 0...a.size
          if a[i..i + 3] == "\r\n\r\n"
            s = i + 4
            break
          end
        end
        f = "-4"
        if s != nil
          s += 2 while a[s..s + 1] == "\r\n"
          a += 1 while a[s..s] == "\n"
          f = a[s..-1]
        end
        writefile(tmpname, f)
      end
      case output
      when 0
        r = IO.readlines(tmpname)
      when 1
        r = readfile(tmpname)
      end
      File.delete(tmpname) if $DEBUG == false
      return r
    end

    def jproc(method, path, params = nil)
      Log.debug("Server JSON request to #{path}")
      play("signal") if $netsignal
      params = {} if !params.is_a?(Hash)
      if Session.name != "" && Session.name != nil
        params["name"] = Session.name
        params["token"] = Session.token
      end
      if $agent != nil
        id = rand(1e16)
        $agent.write(Marshal.dump({ "func" => "jproc", "method" => method, "path" => path, "params" => params, "id" => id }))
        $agids ||= []
        $agids.push(id)
        t = Time.now.to_f
        w = false
        while $jresps[id] == nil
          loop_update(false)
          if Time.now.to_f - t > 2 and w == false
            waiting
            w = true
          elsif Time.now.to_f - t > 15
            Log.warning("Session timed out for JSON request to #{path}")
            waiting_end
            break
          end
          if escape and w
            play("cancel")
            Log.debug("Server JSON request to #{path} cancelled by user")
            waiting_end
            return nil
          end
        end
        waiting_end if w
        rsp = $jresps[id]
        return rsp["resp"]
      end
      return nil
    end

    def name_attachments(attachments, names = [])
      $attnames ||= {}
      return names if names != nil && names.size > 0
      for at in attachments
        if $attnames[at] != nil
          names.push($attnames[at])
        else
          ati = srvproc("attachments", { "info" => "1", "id" => at })
          if ati[0].to_i < 0 or ati.size == 1
            attachments.delete(at)
            next
          end
          names.push(ati[2].delete("\r\n"))
          $attnames[at] = names.last
        end
      end
      return names
    end

    def send_attachment(file)
      data = ""
      host = $srv
      host.delete!("/")
      fl = readfile(file)
      bt = srvproc("attachments", { "add" => 1, "filename" => File.basename(file) }, 0, { "data" => fl })
      err = bt[0].to_i
      if err < 0
        alert(_("Error"))
        return nil
      else
        return bt[1].delete("\r\n")
      end
    end

    # Gets the status of specified user
    #
    # @param name [String] username
    # @return [String] the status of the specified user, if user has no status, the return value is an empty string
    def getstatus(name, onl = true, spn = true)
      $statuslisttime = 0 if $statuslisttime == nil
      if Time.now.to_i - 15 > $statuslisttime
        $statuslisttime = Time.now.to_i
        statustemp = srvproc("status_list", {})
        err = statustemp[0].to_i
        if err != 0
          alert(_("Error"))
          $scene = Scene_Main.new
          return ""
        end
        for i in 1..statustemp.size - 1
          statustemp[i].delete!("\r\n")
        end
        i = 0
        l = 1
        usr = true
        @@statususers = []
        $statustexts = []
        tonline = srvproc("online", {})
        for i in 0..tonline.size - 1
          tonline[i].delete!("\r\n")
        end
        $statusonline = []
        for i in 1..tonline.size - 1
          $statusonline.push(tonline[i]) if tonline[i].size > 0
        end
        tsponsors = srvproc("admins", { "cat" => "sponsors" })
        $statussponsors = []
        for i in 1...tsponsors.size
          $statussponsors.push(tsponsors[i].delete("\r\n"))
        end
        loop do
          if usr == true
            @@statususers[i] = statustemp[l]
            usr = false
          else
            if statustemp[l] != "\004END\004"
              $statustexts[i] = "" if $statustexts[i] == nil
              $statustexts[i] += statustemp[l]
            else
              i += 1
              usr = true
            end
          end
          l += 1
          break if l >= statustemp.size
        end
      end
      st = ""
      return "" if @@statususers == nil or $statusonline == nil
      for i in 0...@@statususers.size
        if name == @@statususers[i]
          st = $statustexts[i]
        end
      end
      st = "\004ONLINE\004" + st if onl == true and $statusonline.include?(name)
      st = "\004SPONSOR\004" + st if $statussponsors.include?(name) && spn
      return st
    end

    # Sets the status of the user
    #
    # @param text [String] the status to set
    def setstatus(text)
      statustemp = srvproc("status_mod", { "text" => text })
      if statustemp[0].to_i != 0
        return statustemp[0].to_i
      else
        return 0
      end
    end

    # @note this function is reserved
    def buffer(data)
      id = rand(2000000000)
      bt = srvproc("buffer_post", { "id" => id }, 0, { "data" => data })
      if bt[0].to_i < 0
        alert(_("Error"))
        return
      end
      return id
    end

    # Returns the information about specified user
    #
    # @param user [String] username
    # @return [Array] return information indexed like:
    #  0: name
    #  1: last seen
    # 1: determines if user has a blog
    #  2: determines a count of contacts
    #  3: Users known by
    #  4: the amount of forum posts
    #  5: used Elten version
    #  6: registration date
    #   7. polls voted
    #  8. is in contacts
    #  9. deprecated
    #  10. is banned
    #  11. honors count
    def userinfo(user, stateonly = false)
      usrinf = []
      uit = srvproc("userinfo", { "searchname" => user, "stateonly" => stateonly.to_i })
      if uit[0].to_i < 0 || uit.size < 9
        alert(_("Error"))
        return -1
      end
      if uit[1].to_i > 1000000000 and uit[1].to_i < 2000000000
        uitt = Time.at(uit[1].to_i)
        usrinf[0] = format_date(uitt, false, false)
      else
        usrinf[0] = ""
      end
      usrinf[1] = uit[2].to_b
      usrinf[2] = uit[3].to_i
      usrinf[3] = uit[4].to_i
      usrinf[4] = uit[8].to_i
      usrinf[5] = uit[5].delete("\r\n")
      if uit[6].to_i == 0 or uit[6] == nil
        usrinf[6] = ""
      else
        uitt = Time.at(uit[6].to_i)
        usrinf[6] = format_date(uitt, false, false)
      end
      usrinf[7] = uit[7]
      usrinf[8] = uit[9].to_b
      usrinf[9] = uit[10].to_b
      usrinf[10] = uit[11].to_b
      usrinf[11] = uit[12].to_i
      usrinf[12] = uit[13].to_b
      usrinf[13] = uit[14].to_b
      usrinf[14] = uit[15].to_b
      usrinf[15] = uit[16].to_b
      return usrinf
    end

    # Checks if the specified user exists
    #
    # @param usr [String] user name
    # @return [Boolean] if the user with specified login exists, the return value is true. Otherwise, the return value is false.
    def user_exists(usr)
      ut = srvproc("user_exist", { "searchname" => usr })
      if ut[0].to_i < 0
        alert(_("Error"))
        return false
      end
      ret = false
      ret = true if ut[1].to_i == 1
      return ret
    end

    # Returns the signature of a specified user
    #
    # @param user [String] a name of the user
    # @return [String] the signature of the specified user, if the user doesn't have a signature, the return value is an empty String.
    def signature(user)
      sg = srvproc("signature", { "get" => "1", "searchname" => user })
      if sg[0].to_i < 0
        alert(_("Error"))
        return ""
      end
      text = ""
      for i in 1..sg.size - 1
        text += sg[i]
      end
      return "" if text.size < 4
      return text.gsub("\004LINE\004", "\r\n").chop.chop
    end

    def feed(message, response = 0)
      response = 0 if response <= 1
      return false if message == "" || !message.is_a?(String)
      message = message.split("")[0...300].join("")
      a = srvproc("feeds", { "ac" => "publish", "response" => response }, 0, "text" => message)
      if a[0].to_i == 0
        return true
      else
        return false
      end
    end

    def delete_feed(id)
      a = srvproc("feeds", { "ac" => "delete", "id" => id })
      return a[0].to_i == 0
    end

    def isbanned(user = Session.name)
      bt = srvproc("isbanned", { "searchname" => user })
      return false if bt[0].to_i < 0
      return true if bt[1].to_i == 1
      return false
    end

    def finduser(usr, type = 0)
      usf = srvproc("user_search", { "search" => usr })
      if usf[0].to_i < 0
        alert(_("Error"))
        if type < 2
          return ""
        else
          return []
        end
      end
      results = []
      if usf[1].to_i == 0
        if type <= 2
          return ""
        else
          return []
        end
      end
      for u in usf[2..1 + usf[1].to_i]
        results.push(u.delete("\r\n"))
      end
      return results[0] || "" if type == 0 or (type == 1 and results.size == 1)
      return results if type == 2
      index = selector(results, p_("EAPI_EltenSRV", "Select a user"), 0, -1)
      if index == -1
        return ""
      else
        return results[index] || ""
      end
    end

    def cryptmessage(msg)
      b = "\0" * 20
      b = "\0" * (msg.bytesize + 18) if msg != nil
      begin
        a = Win32API.new($eltenlib, "CryptMessage", "ppi", "i").call(msg, b, b.bytesize)
        return b
      rescue Exception
        return "err::#{$!.to_s}"
      end
    end

    def blogowners(user)
      if ($blogownerstime || 0) < Time.now.to_i - 10
        b = srvproc("blog_owners", {})
        return [] if b[0].to_i < 0
        $blogowners = {}
        k = nil
        for i in 2...b.size
          if i % 2 == 0
            k = b[i].delete("\r\n")
          else
            $blogowners[k] ||= []
            $blogowners[k].push(b[i].delete("\r\n"))
          end
        end
        $blogowners[user] = [user] if $blogowners[user] == nil and user_exists(user)
        $blogownerstime = Time.now.to_i
      end
      o = $blogowners[user]
      o = [user] if o == nil and user_exists(user)
      o = [] if o == nil
      return o
    end
  end

  include EltenSRV
end
