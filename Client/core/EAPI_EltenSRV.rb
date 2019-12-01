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
          Log.debug("Server request to module #{mod}")
                              play("signal") if $netsignal
          #speech(mod+": "+param.gsub("\&"," "))
          #speech_wait
          preparam=param
                    if param.is_a?(Hash)
            if $name!=nil and $token!=nil and param['name']==nil
              param['name']=$name
              param['token']=$token
              end
            prm=""
            for k in param.keys
                            prm+="\&" if prm!=""
              prm+=k+"="+param[k].to_s.urlenc
            end
                        param=prm
            end
          if $agent!=nil
                                                    id=rand(1e16)
            $agent.write(Marshal.dump({'func'=>'srvproc','mod'=>mod,'param'=>param,'id'=>id}))
            $agids||=[]
            $agids.push(id)
                        $agent_wait=true
            t=Time.now.to_f
            w=false
                while $eresps[id]==nil
            loop_update
      if Time.now.to_f-t>2 and w==false
        waiting
        w=true
      elsif Time.now.to_f-t>15
        Log.warning("Session timed out for request to module #{mod}")
        waiting_end
        break
      end
      if escape and w
        Log.debug("Server request to module #{mod} cancelled by user")
        waiting_end
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
      waiting_end if w
      rsp=$eresps[id]
      rsp={'resp'=>'-4'} if rsp==nil
                case output
    when 0
      r=rsp['resp'].delete("\r").split("\n")
    for i in 0...r.size
      r[i]+="\r\n"
    end
    $agent_wait=false
      return r
    when 1
      return rsp['resp']
      when 3
        return 0 if rsp['resptime']==nil
        return rsp['resptime']-rsp['reqtime']
      end
    end
            if preparam.is_a?(String)
                        rt={}
                                                for r in preparam.split("\&")
                          k,v=r.split("=")
                          v="" if v==nil
                          v=v.urldec if v.include?("%")
                          rt[k]=v
                        end
                        param=rt
                                                                      r=""
                                                                      for k in param.keys
                          r+="\&" if r!=""
                          r+=k+"="+param[k].urlenc
                        end
                        param=r    
                        end
    url = $url + mod + ".php?" + param
tmpname = $tempdir+"/eas#{(rand(36**2).to_s(36))}.tmp"
    #tm=Time.now.to_i*1000000+Time.now.usec
 if download(url,tmpname) != 0
   case output
   when 0
return ["-1"]
when 1
  return "-1"
end
end
                case output
    when 0
          r = IO.readlines(tmpname)
          when 1
      r = readfile(tmpname)
            end
    File.delete(tmpname) if $DEBUG==false
        return r
      end
      
      def name_attachments(attachments, names=[])
  return names if names!=nil&&names.size>0
                      for at in attachments
                        at
                      ati=srvproc("attachments",{"info"=>"1", "id"=>at})
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
        fl=readfile(file)
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
    alert(_("General:error"))
    return nil
  end
  sn = a[s..a.size - 1]
    a = nil
        bt = sn.split("\r\n")
err = bt[0].to_i
            speech_wait
                        if err < 0
      alert(_("General:error"))
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
  statustemp = srvproc("status_list",{})
    err = statustemp[0].to_i
  if err != 0
    alert(_("General:error"))
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
      tonline = srvproc("online",{})
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
  statustemp = srvproc("status_mod",{"text"=>text})
    if statustemp[0].to_i != 0
    return statustemp[0].to_i
  else
    return 0
    end
  end

# Opens a player with an avatar of specified user
#
# @param user [String] username
def avatar(user)
    avatartemp = srvproc("avatar","name=#{$name}\&token=#{$token}\&searchname=#{user}\&checkonly=1",1)
  case avatartemp.split("\r\n")[0].to_i
  when -4
    alert(_("EAPI_EltenSRV:error_noavatar"))
    return
    when -2
      alert(_("General:error_tokenexpired"))
      $scene = Scene_Loading.new
      return
      when -1
        alert(_("General:error_db"))
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
      alert(_("EAPI_EltenSRV:wait_severalminutes"))
      alert(_("EAPI_EltenSRV:wait_converting"),0)
      File.delete($tempdir+"\\avatartemp.opus") if FileTest.exists?($tempdir+"\\avatartemp.opus")
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
  alert(_("General:error"))
  return -1
  break
  end
        end
              data=""
                        fl = readfile($tempdir+"\\avatartemp.opus")
                    File.delete($tempdir+"\\avatartemp.opus")              
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
    alert(_("General:error"))
    waiting_end
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = sn.split("\r\n")
avt = bt[1].to_i
            speech_wait
            waiting_end
            if avt < 0
      alert(_("General:error"))
    else
      alert(_("General:info_saved"))
    end
    speech_wait
    return
  end
  

# @note this function is reserved
def buffer(data)
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
    alert(_("General:error"))
    return
  end
  sn = a[s..a.size - 1]
  a
  sn
  a = nil
        bt = sn.split("\r\n")
if bt[1].to_i < 0
  alert(_("General:error"))
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
                                                      uit = srvproc("userinfo",{"searchname"=>user})
                                    if uit[0].to_i < 0
                    alert(_("General:error"))
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
fp = srvproc("forum_posts",{"cat"=>"3", "searchname"=>user})
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

# Checks if the specified user exists
#
# @param usr [String] user name
# @return [Boolean] if the user with specified login exists, the return value is true. Otherwise, the return value is false.
def user_exist(usr)
  ut = srvproc("user_exist",{"searchname"=>usr})
    if ut[0].to_i < 0
    alert(_("General:error"))
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
                                 sg = srvproc("signature",{"get"=>"1", "searchname"=>user})
                                 if sg[0].to_i < 0
                                   alert(_("General:error"))
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
        fl=readfile(file)
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
    alert(_("General:error"))
    return nil
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = sn.split("\r\n")
err = bt[0].to_i
            speech_wait
                        if err < 0
      alert(_("General:error"))
      else
alert(_("EAPI_EltenSRV:info_sent")) if msg==true
        return bt[1].delete("\r\n")
    end
        return nil
      end
  def isbanned(user=$name)
    bt=srvproc("isbanned",{"searchname"=>user})
    return false if bt[0].to_i<0
    return true if bt[1].to_i==1
    return false
  end
  
  def finduser(usr,type=0)
usf=srvproc("user_search",{"search"=>usr})    
if usf[0].to_i<0
  alert(_("General:error"))
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
        b=srvproc("blog_owners",{})
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