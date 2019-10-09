#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  # Elten Server related functions
  module EltenSRV
    # Makes a request to the Elten server
    #
    # @param mod [String] server module to request
    # @param param [String] & terminated parameters
    # @param output [Numeric] output type: 0 - Array of lines, 1 - string
        def srvproc(mod,param,output=0)
          #speech(mod+": "+param.gsub("\&"," "))
          #speech_wait
          if $agent!=nil and $netuseold!=true
        id=rand(1e8)
            $agent.write(Marshal.dump({'func'=>'srvproc','mod'=>mod,'param'=>param,'id'=>id}))
            $agent_wait=true
            t=Time.now.to_f
            w=false
    while $eresps[id]==nil
      loop_update
      if Time.now.to_f-t>2 and w==false
        waiting
        w=true
      elsif Time.now.to_f-t>15
        waiting_end
        break
      end
      if escape and w
        waiting_end
                case output
        when 0
          return ["-1"]
          when 1
            return "-1"
        end
        end
      end
      waiting_end if w
            if $eresps[id]==nil||$eresps[id]['resp']==nil
              tid=rand(1e8)
              $agent.write(Marshal.dump({'func'=>'srvproc','mod'=>'active','param'=>"name=#{$name}\&token=#{$token}",'id'=>tid}))
              delay(1)
              $netuseold=true if $eresps[tid]!=nil
              return srvproc(mod,param,output)        
end
    case output
    when 0
r=$eresps[id]['resp'].delete("\r").split("\n")
    for i in 0...r.size
      r[i]+="\r\n"
    end
    $agent_wait=false
      return r
    when 1
      return $eresps[id]['resp']
      end
    end
        url = $url + mod + ".php?" + hexspecial(param)
tmpname = "temp/eas#{(rand(36**2).to_s(36))}.tmp"
    #tm=Time.now.to_i*1000000+Time.now.usec
 if download(url,tmpname) != 0
   case output
   when 0
return ["-1"]
when 1
  return "-1"
end
end
        #speech("#{read(tmpname,true)}B pobrano w "+((Time.now.to_i*1000000+Time.now.usec-tm)/1000).to_s+"ms (#{mod})");speech_wait
        case output
    when 0
          r = IO.readlines(tmpname)
          when 1
      r = read(tmpname)
      when 2
        r = readlines(tmpname)
      end
    File.delete(tmpname) if $DEBUG==false
        return r
      end
      
      def name_attachments(attachments, names=[])
  return names if names!=nil&&names.size>0
                      for at in attachments
                        at
                      ati=srvproc("attachments","name=#{$name}\&token=#{$token}\&info=1\&id=#{at}")
                      if ati[0].to_i<0 or ati.size==1
                        attachments.delete(at)
                        next
                      end
                      names.push(ati[2].delete("\r\n"))
                    end
                    return names
  end
      
      def send_attachment(file)
           data = ""
                                      host = $srv
  host.delete!("/")
        fl=read(file)
    boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"data\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
    q = "POST /srv/attachments.php?add=1\&filename=#{File.basename(file).urlenc}\&name=#{$name}\&token=#{$token} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary.to_s}\r\nContent-Length: #{length}\r\n\r\n#{data}"
  a = connect(host,80,q,2048,s_("Messages:wait_sendingfile",{'file'=>File.basename(file)}))
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech(_("General:error"))
    return nil
  end
  sn = a[s..a.size - 1]
    a = nil
        bt = strbyline(sn)
err = bt[0].to_i
            speech_wait
                        if err < 0
      speech(_("General:error"))
    speech_wait
return nil
else
      return bt[1].delete("\r\n")
    end
end
          
          # Gets the status of specified user
          #
          # @param name [String] username
          # @return [String] the status of the specified user, if user has no status, the return value is an empty string
    def getstatus(name,onl=true)
  $statuslisttime = 0 if $statuslisttime == nil
  if Time.now.to_i - 15 > $statuslisttime
    $statuslisttime = Time.now.to_i
  statustemp = srvproc("status_list","name=#{$name}\&token=#{$token}")
    err = statustemp[0].to_i
  if err != 0
    speech(_("General:error"))
    speech_wait
    $scene = Scene_Main.new
    return
  end
  for i in 1..statustemp.size - 1
    statustemp[i].delete!("\r\n")
  end
  i = 0
  l = 1
  usr = true
  $statususers = []
  $statustexts = []
      tonline = srvproc("online","name=#{$name}\&token=#{$token}")
            for i in 0..tonline.size - 1
      tonline[i].delete!("\r\n")
          end
        $statusonline = []
    for i in 1..tonline.size - 1
      $statusonline.push(tonline[i]) if tonline[i].size > 0
    end
          loop do
    if usr == true
      $statususers[i] = statustemp[l]
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
  return if $statususers==nil or $statusonline==nil
  for i in 0...$statususers.size
    if name == $statususers[i]
      st = $statustexts[i]
      end
    end
    st="(Online) "+st if onl == true and $statusonline.include?(name)
    return st
end

# Sets the status of the user
#
# @param text [String] the status to set
def setstatus(text)
  statustemp = srvproc("status_mod","name=#{$name}\&token=#{$token}\&text=#{text}")
    if statustemp[0].to_i != 0
    return statustemp[0].to_i
  else
    return 0
    end
  end
  
  # Creates a server buffer
  #
  # @param data [String] buffer input
  # @return [Numeric] a buffer id
  def buffer(data)
                                    return buffer_post(data)
        s=false
    while s==false
      s=true
      if dt[dt.size - 1..dt.size - 1] == "\004" and dt[dt.size - 6..dt.size - 6] == "\004"
        s=false
        for i in 1..6
        dt.chop!
        end
        end
      end
    bdt = dt
    bdt.gsub!("`","\006")
    bdt.gsub!("'","\007")
    bdt.gsub!("\\","\\\\")
    dt = bdt
        bufid = rand(2147483000) + 1
    bufdt = []
    r = 0
    t = 0
    bufdt[r] = ""
    i = 0
    loop do
            t += 1
      if dt[i..i+5] == "\004LINE\004"
                t -= 6
                end
                    bufdt[r] += dt[i..i] if dt[i..i] != nil
            if utf8(dt[i..i + 1]) != dt[i..i + 1] and dt[i - 1..i] == dt[i - 1..i] and utf8(dt[i..i]) == "?"
              t -= 1
                    end
      if t >= 200
        r += 1
        bufdt[r] = ""
        t = 0
      end
      i += 1
      break if i > dt.size
    end
      buft = srvproc("buffer","name=#{$name}\&token=#{$token}\&ac=1\&id=#{bufid}\&data=#{bufdt[0]}")
            if buft[0].to_i < 0
        speech(_("General:error"))
        speech_wait
        $scene = Scene_Main.new
        return -1
      end
      for i in 1..bufdt.size - 1
              buft = srvproc("buffer","name=#{$name}\&token=#{$token}\&ac=2\&id=#{bufid}\&data=#{bufdt[i]}")
                          if buft[0].to_i < 0
        speech(_("General:error"))
        speech_wait
        $scene = Scene_Main.new
        return -1
      end
      end
  return bufid    
end


# Opens a player with an avatar of specified user
#
# @param user [String] username
def avatar(user)
    avatartemp = srvproc("avatar","name=#{$name}\&token=#{$token}\&searchname=#{user}\&checkonly=1",1)
  case strbyline(avatartemp)[0].to_i
  when -4
    speech(_("EAPI_EltenSRV:error_noavatar"))
    speech_wait
    return
    when -2
      speech(_("General:error_tokenexpired"))
      speech_wait
      $scene = Scene_Loading.new
      return
      when -1
        speech(_("General:error_db"))
        speech_wait
        return
      end
      a = $url+"avatars/"+user
            player(a,"Awatar: #{user}",true,true,true)
                          return
                        end    
                        
                        # Sets the specified file as an avatar
                        #
                        # @param file [String] a file location
    def avatar_set(file)
      waiting
      speech(_("EAPI_EltenSRV:wait_severalminutes"))
      speech(_("EAPI_EltenSRV:wait_converting"),0)
      File.delete("temp\\avatartemp.opus") if FileTest.exists?("temp\\avatartemp.opus")
      h = run("bin\\ffmpeg.exe -y -i \"#{file}\" -b:a 96K temp\\avatartemp.opus",true)
      t = 0
      tmax = File.size(file)/10000.0
      loop do
        loop_update
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
if x != "\003\001"
  break
  end
t += 10.0/Graphics.frame_rate
if t > tmax
  speech(_("General:error"))
  return -1
  break
  end
        end
              data=""
                        fl = read("temp\\avatartemp.opus")
                    File.delete("temp\\avatartemp.opus")              
            host = $srv
  host.delete!("/")
              boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"avatar\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
    q = "POST /srv/avatar_mod.php?name=#{$name}\&token=#{$token} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary.to_s}\r\nContent-Length: #{length}\r\n\r\n#{data}"
  a = connect(host,80,q)
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech(_("General:error"))
    waiting_end
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = strbyline(sn)
avt = bt[1].to_i
            speech_wait
            waiting_end
            if avt < 0
      speech(_("General:error"))
    else
      speech(_("General:info_saved"))
    end
    speech_wait
    return
  end
  

# @note this function is reserved
def buffer_post(data)
    id = rand(2000000000)
  host = $srv
  host.delete!("/")
  length = data.size
  boundary=""
  while data.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
      end    
      data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"data\"\r\n\r\n#{data}\r\n--#{boundary}--"
  q = "POST /srv/buffer_post.php?name=#{$name}\&token=#{$token}&id=#{id.to_s} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{data.size}\r\n\r\n#{data}"
a = connect(host,80,q)
a.delete!("\0")
a
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech(_("General:error"))
    return
  end
  sn = a[s..a.size - 1]
  a
  sn
  a = nil
        bt = strbyline(sn)
if bt[1].to_i < 0
  speech(_("General:error"))
  speech_wait
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
                def userinfo(user)
                  usrinf = []
                                                      uit = srvproc("userinfo","name=#{$name}\&token=#{$token}\&searchname=#{user}")
                                    if uit[0].to_i < 0
                    speech(_("General:error"))
                    return -1
                  end
                  if uit[1].to_i > 1000000000 and uit[1].to_i < 2000000000
                    begin                  
                    uitt = Time.at(uit[1].to_i)
                  rescue Exception
                    retry
                    end
                  usrinf[0] = sprintf("%04d-%02d-%02d %02d:%02d",uitt.year,uitt.month,uitt.day,uitt.hour,uitt.min)
                else
                  usrinf[0] = "Konto nie zostało aktywowane."
                  end
                  if uit[2].to_i == 1
                    usrinf[1] = true
                  else
                    usrinf[1] = false
                  end
usrinf[2] = uit[3].to_i
usrinf[3] = uit[4].to_i
fp = srvproc("forum_posts","name=#{$name}\&token=#{$token}\&cat=3\&searchname=#{user}")
if fp[0].to_i == 0
usrinf[4] = fp[1].to_i
end
usrinf[5] = uit[5].delete("\r\n") if uit[5]
if uit[6].to_i == 0
  usrinf[6]=""
  else
begin                  
                    uitt = Time.at(uit[6].to_i)
                  rescue Exception
                    retry
                    end
                  usrinf[6] = sprintf("%04d-%02d-%02d %02d:%02d",uitt.year,uitt.month,uitt.day,uitt.hour,uitt.min)
end
usrinf[7]=uit[7]
return usrinf
end

# @note this function is reserved
def bufferer(data)
  msg = ""
  msg += $name
  msg += "\r\n"
  msg += $token
  msg += "\r\n"
  bufid = rand(2147483)+1
  msg += bufid.to_s
  msg += "\r\n"
  msg += data.size.to_s
  msg += "\r\n"
  msg += data.to_s
  connect($srv,2431,msg)
  return bufid
end


        # @deprecated use {#sendfile} instead.      
    def asendfile(file)
      fl = read(file)
      msg = "#{$name}\r\n#{$token}\r\n#{fl.size.to_s}\r\n#{fl}"
      filedir = false
      begin
        filedir = connect($srv,2442,msg) if filedir == false
      rescue SystemExit
        Graphics.update
        retry
      end
return filedir
end

# Checks if the specified user exists
#
# @param usr [String] user name
# @return [Boolean] if the user with specified login exists, the return value is true. Otherwise, the return value is false.
def user_exist(usr)
  ut = srvproc("user_exist","name=#{$name}\&token=#{$token}\&searchname=#{usr}")
    if ut[0].to_i < 0
    speech(_("General:error"))
    speech_wait
    return false
  end
  ret = false
  ret = true if ut[1].to_i == 1
  return ret
end

# @deprecated use {#sendfile} instead.
          def hexsendfile(file)
            str = read(file)
            play("list_focus")
            loop_update
                        s = str.urlenc(true)
                        play("list_focus")
                        loop_update
                                                return buffer_post(s)
                                              end
                                            
                                   # Returns the signature of a specified user
                                   #
                                   # @param user [String] a name of the user
                                   # @return [String] the signature of the specified user, if the user doesn't have a signature, the return value is an empty String.
                               def signature(user)
                                 sg = srvproc("signature","name=#{$name}\&token=#{$token}\&get=1\&searchname=#{user}")
                                 if sg[0].to_i < 0
                                   speech(_("General:error"))
                                   speech_wait
                                   return ""
                                 end
                                 text = ""
                                                                  for i in 1..sg.size-1
                                   text += sg[i]
                                 end
                                 return "" if text.size < 4                                 
                                 return text.gsub("\004LINE\004","\r\n").chop.chop
                               end
                            
                               
                               # Sends the specified file to the server and adds it to the shared files of an user
                               #
                               # @param file [String] the location of a file to send
                               # @return [String] the id of a file
                               def sendfile(file,msg=false)
                                    data = ""
                                      host = $srv
  host.delete!("/")
        fl=read(file)
    boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"data\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
    q = "POST /srv/uploads_mod.php?add=1\&filename=#{File.basename(file).urlenc}\&name=#{$name}\&token=#{$token} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary.to_s}\r\nContent-Length: #{length}\r\n\r\n#{data}"
  a = connect(host,80,q)
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech(_("General:error"))
    return nil
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = strbyline(sn)
err = bt[0].to_i
            speech_wait
                        if err < 0
      speech(_("General:error"))
    speech_wait
      else
speech(_("EAPI_EltenSRV:info_sent")) if msg==true
        return bt[1].delete("\r\n")
    end
        return nil
      end
  def isbanned(user=$name)
    bt=srvproc("isbanned","name=#{$name}\&token=#{$token}\&searchname=#{user}")
    return false if bt[0].to_i<0
    return true if bt[1].to_i==1
    return false
  end
  
  def finduser(usr,type=0)
usf=srvproc("user_search","name=#{$name}\&token=#{$token}\&search=#{usr}")    
if usf[0].to_i<0
  speech(_("General:error"))
  speech_wait
  if type<2
  return ""
else
  return []
  end
  end
results=[]
if usf[1].to_i==0
  if type<=2
    return ""
  else
    return []
    end
end
for u in usf[2..1+usf[1].to_i]
  results.push(u.delete("\r\n"))
end
return results[0] if type==0 or (type == 1 and results.size == 1)
return results if type==2
index=selector(results,_("EAPI_EltenSRV:head_seluser"),0,-1)
if index == -1
  return ""
else
  return results[index]
  end
end

def srvstate
      $eltsuspend=false
      end
  

  def cryptmessage(msg)
    b="\0"*20
    b="\0"*(msg.bytesize+18) if msg!=nil
    begin
      a=Win32API.new($eltenlib,"CryptMessage",'ppi','i').call(msg,b,b.bytesize)
      return b
    rescue Exception
      return "err::#{$!.to_s}"
      end
    end
    
    def blogowners(user)
      if ($blogownerstime||0)<Time.now.to_i-10
        b=srvproc("blog_owners","name=#{$name}\&token=#{$token}")
        return nil if b[0].to_i<0
        $blogowners={}
        k=nil
        for i in 2...b.size
          if i%2==0
            k=b[i].delete("\r\n")
          else
            $blogowners[k]||=[]
            $blogowners[k].push(b[i].delete("\r\n"))
            end
          end
          $blogowners[user]=[user] if $blogowners[user]==nil and user_exist(user)
          $blogownerstime=Time.now.to_i
        end
      o=$blogowners[user]
      o=[user] if o==nil and user_exist(user)
      o=[] if o==nil
      return o
      end

        end
  end
#Copyright (C) 2014-2019 Dawid Pieper