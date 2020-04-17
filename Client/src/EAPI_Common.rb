#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module Common
    private
# EltenAPI common functions
    # Opens the quit menu
    #
    # @param header [String] a message to read, header of the menu
        def quit(header=p_("EAPI_Common", "Exit..."))
         dialog_open
            sel = menulr([_("Cancel"),p_("EAPI_Common", "Hide program in Tray"),_("Exit")],true,0,header)
            sel.disable_menu
      loop do
        loop_update
        sel.update
        if $key[0x11] and $key[81]
sel.commandoptions=["Zabieraj mi to okno","Spadaj z mojego pulpitu","Mam ciebie dość, zamknij się","Zejdź mi z oczu"]
          sel.focus
          end
        if escape
          sel.enable_menu
          dialog_close
          break
            $exit = false
            return(false)
            end
        if enter
          sel.enable_menu
          loop_update
          dialog_close
          case sel.index
          when 0
            break
            $exit = false
            return(false)
            when 1
              $exit = false
              tray
              return false
            when 2
              $scene = nil
              break
              $exit = true
              return(true)
                $exit = false
                return false
                when 3
                                  return quit("W zasadzie, jak mam zejść z oczu osobie niewidomej? Nie rozumiem. Proszę o doprecyzowanie.")
          end
          end
        end
      end
      
      class Console
        def initialize
          @b=binding
        end
        def run(code)
          return eval(code,@b, "Console")
          end
        end

      # Opens a console      
def console
  form=Form.new([
  Edit.new(p_("EAPI_Common", "Enter the command to execute"),"MULTILINE","",true),
  Edit.new(p_("EAPI_Common","Output"),"READONLY","",true),
  Button.new(p_("EAPI_Common","Execute"))
  ])
  dialog_open
  container = Console.new
  loop do
    loop_update
    form.update
    if form.fields[2].pressed? or ($keyr[0x11] and enter)
kom=form.fields[0].text
  begin
  r=container.run(kom).inspect
rescue Exception
    plc=""
    if $@.is_a?(Array)
  for e in $@
    if e!=nil
    plc+=e+"\n" if e!=nil and e[0..6]!="Section"
    end
  end
    lin=$@[0].split(":")[1].to_i
        plc+=kom.delete("\r").split("\n")[lin-1]||""
        end
  r=$!.class.to_s+" ("+$!.to_s+")\n"+plc
    end
speak(r)
form.fields[0].settext("")
form.fields[1].settext(form.fields[1].text+"\r\n"+r,false)
loop_update
end
break if escape
end
dialog_close
end


# Opens a menu of a specified user
#
# @param user name of the user whose menu you want to open
# @param submenu [Boolean] specifies if the menu is a submenu
# @return [String] returns ALT if menu was closed using an alt menu
    def usermenu(user,submenu=false, left=false)
      ui=userinfo(user, true)
            @incontacts = ui[8].to_b if Session.name!="guest"      
@isbanned = ui[10].to_b
      @hasblog = ui[1]
    @hashonors=(ui[11]>0)
    play("menu_open") if submenu != true
play("menu_background") if submenu != true
sel = [p_("EAPI_Common", "Write a private message"),p_("EAPI_Common", "Visiting card"),p_("EAPI_Common", "Open user's blog"),p_("EAPI_Common", "badges of this user")]
if Session.name!="guest"
if @incontacts == true
  sel.push(p_("EAPI_Common", "Remove from contacts' list"))
else
  sel.push(p_("EAPI_Common", "Add to contacts' list"))
end
else
  sel.push("")
  end
if $rang_moderator > 0
  if @isbanned == false
    sel.push(p_("EAPI_Common", "Ban"))
  else
    sel.push(p_("EAPI_Common", "Unban"))
  end
else
  sel.push("")
  end
    if $usermenuextra.is_a?(Hash) and Session.name!="guest"
      for k in $usermenuextra.keys
    sel.push(k)
    end
    end
  if submenu==false
    menu = menulr(sel,true,0,"",true)
  else
    menu = Select.new(sel,true,0,"",true)
    end
  menu.disable_item(2) if @hasblog == false
if Session.name!="guest"

else
  menu.disable_item(0)
    menu.disable_item(4)
  end
menu.disable_item(3) if @hashonors==false
menu.disable_item(5) if $rang_moderator==0
menu.focus
loop do
loop_update
if enter
  play("menu_close")
    Audio.bgs_stop
  case menu.index
  when 0
    insert_scene(Scene_Messages_New.new(user,"","",Scene_Main.new), true)
        loop_update
    return "ALT"
    when 1
            visitingcard(user)
            return("ALT")
      break
            when 2
        insert_scene(Scene_Blog_Main.new(user,0,Scene_Main.new), true)
    loop_update
        return "ALT"
        break
    when 3
        insert_scene(Scene_Honors.new(user,Scene_Main.new), true)
    loop_update
    return "ALT"
          when 4
      if @incontacts == true
        insert_scene(Scene_Contacts_Delete.new(user,Scene_Main.new), true)
      else
        insert_scene(Scene_Contacts_Insert.new(user,Scene_Main.new), true)
      end
    loop_update
    return "ALT"
      when 5
        if @isbanned == false
          insert_scene(Scene_Ban_Ban.new(user,Scene_Main.new), true)
        else
          insert_scene(Scene_Ban_Unban.new(user,Scene_Main.new), true)
        end
    loop_update
    return "ALT"
      else
                if $usermenuextra.is_a?(Hash)
                                    a=$usermenuextra.values[menu.index-6]
                                    s=a[0].new
                                    s.userevent(user, *a[1..-1])
                      insert_scene(s, true)
                                                                 return "ALT"
                  break                  
                  end
end
break
end
if alt
  if submenu != true
    break
else
  return("ALT")
  break
end
end
if escape
  loop_update
  if submenu == true
        return
    break
  else
        break
    end
  end
  if ((arrow_up and !left and menu.index==0) or (arrow_left and left)) and submenu == true
        loop_update
    return
    break
  end
  menu.update
end
Audio.bgs_stop if submenu != true
play("menu_close") if submenu != true
end

# Opens a what's new menu
#
# @param quiet [Boolean] if true, no text is read if there's nothing new
     def whatsnew(quiet=false)
       agtemp = srvproc("agent",{"client"=>"1"})
       err = agtemp[0]
messages = agtemp[8].to_i
posts = agtemp[9].to_i
blogposts = agtemp[10].to_i
blogcomments = agtemp[11].to_i
followedforums=agtemp[12].to_i
followedforumsposts=agtemp[13].to_i
friends=agtemp[14].to_i
birthday=agtemp[15].to_i
mentions=agtemp[16].to_i
$nversion=agtemp[2].to_f
$nbeta=agtemp[3].to_i
bid=srvproc("bin/buildid","name=#{Session.name}\&token=#{Session.token}",1).to_i
                                    if messages <= 0 and posts <= 0 and blogposts <= 0 and blogcomments <= 0 and followedforums<=0 and followedforumsposts<=0 and friends<=0 and birthday<=0 and mentions<=0 and (Elten.build_id==bid or bid<=0)
  alert(p_("EAPI_Common", "There is nothing new.")) if quiet != true
else
    $scene = Scene_WhatsNew.new(true,agtemp,bid)
end
speech_wait
end

# Creates a debug info
#
# @return [String] debug information which can be attached to a bug report etc.
          def createdebuginfo
            di = ""
            di += "*ELTEN | DEBUG INFO*\r\n"
            if $@ != nil
              if $! != nil
            di += $!.to_s + "\r\n" + $@.to_s + "\r\n"
          end
          end
            di +="\r\n[Computer]\r\n"
            di += "OS version: " + (Win32API.new("kernel32","GetVersion",'','i').call>>16).to_s + "\r\n"
                        di += "Elten data path: " + Dirs.eltendata.to_s + "\r\n"
                procid = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("PROCESSOR_IDENTIFIER",procid,procid.size)
procid.delete!("\0")
di += "Processor Identifier: " + procid.to_s + "\r\n"
                procnum = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("NUMBER_OF_PROCESSORS",procnum,procnum.size)
procnum.delete!("\0")
di += "Number of processors: " + procnum.to_s + "\r\n"
ramt=[0].pack("l")
Win32API.new("kernel32","GetPhysicallyInstalledSystemMemory",'p','i').call(ramt)
ram=ramt.unpack("l")[0]/1024

di += "RAM Memory: "+ram.to_s+"MB\r\n"
memt=[0,0,0,0,0,0,0,0,0,0].pack('iiiiiiiiii')
Win32API.new("psapi","GetProcessMemoryInfo",'ipi','i').call($process,memt,memt.size)
di += "Memory usage: "+(memt.unpack('i'*9)[3]/1048576).to_s+"MB\r\n"
di += "Peak memory usage: "+(memt.unpack('i'*9)[2]/1048576).to_s+"MB\r\n"
cusername = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("USERNAME",cusername,cusername.size)
cusername.delete!("\0")
di += "User name: " + cusername.to_s + "\r\n"
di += "\r\n[Elten]\r\n"
di += "User: " + Session.name.to_s + "\r\n"
di += "Token: " + Session.token.to_s + "\r\n"
ver = $version.to_s
ver += "_BETA" if $isbeta == 1
ver += "_RC" if $isbeta == 2
ver += $beta.to_s if $isbeta == 1
di += "Version: " + ver.to_s + "\r\n"
di += "URL: "+$url.to_s+"\r\n"
di += "Start time: " + $start.to_s + "\r\n"
di += "Current time: " + Time.now.to_i.to_s + "\r\n"
if $app!=nil
di += "\r\n[Programs]\r\n"
for i in 0..$app.size - 1
di += $app[i][0].to_s
di += "\r\n"
end
end
di += "\r\n[Configuration]\r\n"
di += "Language: " + $language + "\r\n"
di += "Sound theme's path: " + $soundthemespath + "\r\n"
if $voice >= 0
  voicename = Win32API.new("bin\\screenreaderapi", "sapiGetVoiceNameW", 'i', 'i')
              vc="\0"*1024
              Win32API.new("msvcrt", "wcscpy", 'pp', 'i').call(vc,voicename.call($voice))
voice = deunicode(vc)
di += "Voice name: " + voice.to_s + "\r\n"
end
di += "Voice id: " + $voice.to_s + "\r\n"
di += "Voice rate: " + $rate.to_s + "\r\n"
di += "Typing echo: " + $interface_typingecho.to_s + "\r\n"
return di
end

# Sends a bug report
#
# @param getinfo [Boolean] ask a user to describe the bug
# @param info [String] predefined information
# @return [Numeric] return 0 if succeeds, otherwise the return value is an error code
def bug(getinfo=true,info="")
  loop_update
  if getinfo == true
    info = prompt(p_("EAPI_Common", "Describe the found error"),p_("EAPI_Common", "Send"))
    if info == ""
    return 1
  end
  info += "\r\n|||\r\n\r\n\r\n\r\n\r\n\r\n"
  end
  di = createdebuginfo
  info += di
  info.gsub!("\r\n","\004LINE\004")
  buf = buffer(info)
  bugtemp = srvproc("bug",{"buffer"=>buf})
      err = bugtemp[0].to_i
  if err != 0
    alert(_("Error"))
    r = err
  else
    alert(p_("EAPI_Common", "Sent."))
    r = 0
  end
  speech_wait
  return r
end



# Opens a list of contacts allowing user to select one
#
# @return [String] returns a selected contact name, if cancelled, the return value is nil
  def selectcontact
                ct = srvproc("contacts",{})
        err = ct[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      contact = []
      for i in 1..ct.size - 1
        ct[i].delete!("\r\n")
      end
      for i in 1..ct.size - 1
        contact.push(ct[i]) if ct[i].size > 1
      end
      if contact.size < 1
        speak(p_("EAPI_Common", "Empty list"))
        speech_wait
      end
      selt = []
      for i in 0..contact.size - 1
        selt[i] = contact[i] + ". " + getstatus(contact[i])
        end
      sel = Select.new(selt,true,0,p_("EAPI_Common", "Select contact"))
      loop do
loop_update
        sel.update if contact.size > 0
        if escape
          loop_update
          $focus = true
                    return(nil)
        end
        if enter and contact.size > 0
          loop_update
          $focus = true
          play("list_select")
                    return(contact[sel.index])
          end
        end
        end
      
# Opens a visitingcard of a specified user
#
# @param user [String] user whose visitingcard you want to open
  def visitingcard(user=Session.name)
            vc = srvproc("visitingcard",{"searchname"=>user})
            pr = srvproc("profile",{"get"=>"1", "searchname"=>user})
    if vc[0].to_i<0
      alert(_("Database Error"))
      return -1
      end
      dialog_open
      text = ""
honor=gethonor(user)
text += "#{if honor==nil;"Użytkownik";else;honor;end}: #{user} \r\n"
text += getstatus(user,false)
text += "\r\n"
fullname = ""
gender = -1
birthdateyear = 0
birthdatemonth = 0
birthdateday = 0
location = ""
if pr[0].to_i == 0
  fullname = pr[1].delete("\r\n")
        gender = pr[2].delete("\r\n").to_i
        if pr[3].to_i>1900 and pr[4].to_i > 0 and pr[4].to_i < 13 and pr[5].to_i > 0 and pr[5].to_i < 32
        birthdateyear = pr[3].delete("\r\n")
        birthdatemonth = pr[4].delete("\r\n")
        birthdateday = pr[5].delete("\r\n")
        end
        location = pr[6].delete("\r\n")
        text += fullname+"\r\n"
        text+="#{p_("EAPI_Common", "Gender")}: "
        if gender == 0
          text += "#{_("Female")}\r\n"
        else
          text += "#{_("male")}\r\n"
        end
if birthdateyear.to_i>0
        age = Time.now.year-birthdateyear.to_i
if Time.now.month < birthdatemonth.to_i
  age -= 1
elsif Time.now.month == birthdatemonth.to_i
  if Time.now.day < birthdateday.to_i
    age -= 1
    end
  end
  age -= 2000 if age > 2000      
  text += "#{p_("EAPI_Common", "Age")}: #{age.to_s}\r\n"
end
if location!="" and (location.to_i>0 or Lists.locations.map{|l| l['country']}.uniq.include?(location))
  text+=p_("EAPI_Common", "Location")+": "
  if location.to_i>0
    loc={}
    Lists.locations.each {|l| loc=l if l['geonameid']==location.to_i}
    text+=loc['name']+", "+loc['country'] if loc!=nil
  else
    text+=location
  end
  text+="\r\n"
  end
end
  ui = userinfo(user)
if ui != -1
if gender == 0
  text += p_("EAPI_Common_female", "Last seen")
elsif gender == 1
  text += p_("EAPI_Common_male", "Last seen")
  else
  text += p_("EAPI_Common", "Last seen")
  end
text+= ": " + ui[0] + "\r\n"
 text += p_("EAPI_Common", "User has a blog")+"\r\n" if ui[1] == true
text += "#{p_("EAPI_Common", "Knows %{count} users")%{'count'=>ui[2].to_s}}\r\n"
if gender == -1
text += p_("EAPI_Common", "Known by %{count} users")%{'count'=>ui[3].to_s}
elsif gender == 0
  text += p_("EAPI_Common_female", "Known by %{count} users")%{'count'=>ui[3].to_s}
elsif gender == 1
  text += p_("EAPI_Common_male", "Known by %{count} users")%{'count'=>ui[3].to_s}
end
text += "\r\n"
text += "#{p_("EAPI_Common", "Forum posts")}: " + ui[4].to_s + "\r\n"
text += "#{p_("EAPI_Common", "Polls answered")}: " + ui[7].to_s.delete("\r\n") + "\r\n"
v=""
ui[5].split(" ").each {|e|
if v==""
e=e.delete(".").split("").join(".")
else
v+=" "
end
v+=e
}
text += "#{p_("EAPI_Common", "Used version")}: " + v + "\r\n"
text += "#{p_("EAPI_Common", "Registered")}: " + ui[6].to_s.split(" ")[0] + "\r\n" if ui[6]!=""
end
if vc[1]!="     " and vc.size!=1
text += "\r\n\r\n"
      for i in 1..vc.size - 1
        text += vc[i]
      end
      end
      inptr = Edit.new(p_("EAPI_Common", "Visiting card of %{user}:")%{'user'=>user},"READONLY|MULTILINE",text)
      loop do
        loop_update
        inptr.update
        break if escape
      end
      loop_update
      $focus = true if $scene.is_a?(Scene_Main) == false
      dialog_close
      return 0
    end
              
# Shows user agreement
#
# @param omit [Boolean] determines whether to allow user to close the window without accepting
    def license(omit=false)
    @license = _doc('license')
    @rules = _doc('rules')
    @privacypolicy = _doc('privacypolicy')
form = Form.new([
Edit.new(p_("EAPI_Common", "License agreement"),Edit::Flags::MultiLine|Edit::Flags::ReadOnly|Edit::Flags::MarkDown,@license,true),
Edit.new(p_("EAPI_Common", "Terms and Conditions"),Edit::Flags::MultiLine|Edit::Flags::ReadOnly|Edit::Flags::MarkDown,@rules,true),
Edit.new(p_("EAPI_Common", "Privacy Policy"),Edit::Flags::MultiLine|Edit::Flags::ReadOnly|Edit::Flags::MarkDown,@privacypolicy,true),
Button.new(p_("EAPI_Common", "I accept Elten license agreement, Terms and Conditions and Privacy Policy")),Button.new(p_("EAPI_Common", "I do not accept, exit"))])
loop do
  loop_update
  form.update
  if (enter or space) and form.index == 4
    exit
  end
  if (space or enter) and form.index == 3
    break
  end
  if escape
    if omit == true
      break
    else
      if form.index==0 or form.index==1
        form.index+=1
        form.focus
        else
    q = confirm(p_("EAPI_Common", "Do you accept Elten license agreement, terms and conditions and privacy policy?"))
    if q == 0
      exit
    else
      break
      end
    end
    end
    end
  end
end

# Opens an audio player
#
# @param file [String] a location or URL of a media to play
# @param label [String] player window caption
# @param wait [Boolean] close a player after audio is played
# @param control [Boolean] allow user to control the played audio, by for example scrolling it
# @param trydownload [Boolean] download a file if the codec doesn't support streaming
def player(file,label="",wait=false,control=true,trydownload=false,stream=false)
  if File.extname(file).downcase==".mid" and FileTest.exists?(Dirs.extras+"\\soundfont.sf2") == false
    if confirm(p_("EAPI_Common", " You are trying to play a midi file. In order to play such files, Elten needs an  external base of instruments. Do you want to download the base from the server  now? It may take several minutes."))==1
    downloadfile($url+"extras/soundfont.sf2",Dirs.extras+"\\soundfont.sf2",p_("EAPI_Common", "Please wait, the soundfont is being downloaded. It may take a while."),p_("EAPI_Common", "Soundfont downloaded succesfully."))
    speech_wait
    Win32API.new("bass","BASS_SetConfigPtr",'ip','l').call(0x10403,Dirs.extras+"\\soundfont.sf2")
  else
    return
    end
      end
  plpause=false
  plpos=0
  if $playlist!=nil and $playlistbuffer!=nil and $playlistbuffer.playing?
    plpause=true
    $playlistbuffer.pause
    end
  if label != ""
  dialog_open if wait==false
$dialogvoice.close if $dialogvoice != nil
$dialogvoice = nil
end
snd=Player.new(file,label)
delay(0.1)
    loop do
                    loop_update
                    snd.update if control
  if wait == true
    if snd.sound!=nil
  if snd.pause != true
    if snd.sound.position(true)>=snd.sound.length(true)-1024 and snd.sound.length(true)>0
                  snd.close
            $playlistbuffer.play if plpause==true
      return
     break
            end
          end
          end
  end
  if (enter and !$key[0x10]) or escape or snd.sound==nil
    snd.fade
    snd.close
    dialog_close if label!=""
    break
    end
  end
$playlistbuffer.play if plpause==true
end

# gets a key pressed by user
#
# @param keys [Array] a keyboard state
# @param multi [Boolean] support multikeys
# @return [String] returns pressed key or keys, if nothing pressed, the return value is an empty string
# @example read the pressed keys
#  loop do
  #   speech(getkeychar)
  #   break if escape
  #  end
def getkeychar(keys=[],multi=false)
    ret=""
  lng=Win32API.new("user32","GetKeyboardLayout",'i','l').call(0).to_s(2)[16..31].to_i(2)
          for i in 32..255
    if $key[i]
      c="\0"*8
  if Win32API.new("user32","ToUnicode",'iippii','i').call(i,0,$keybd,c,c.bytesize,0) > 0
                                                                            re=deunicode(c)
ret=re if re!="" and re[0]>=32
end
end
end
  $lastkeychar=[ret,Time.now.to_i*1000000+Time.now.usec.to_i] if ret!=""
          return ret
        end
    
      # @note this function is reserved for Elten usage
                  def thr1
                    gcs=Win32API.new("bin\\screenreaderapi","getCurrentScreenReader",'','i')
                    ss=Win32API.new("bin\\screenreaderapi","stopSpeech",'','i')
                                        loop do
            begin
            sleep(0.1)
              if $voice != -1 and ($ruby != true or $windowminimized != true)
                if !NVDA.check and gcs.call>0
ss.call
end
                      end
              rescue Exception
        fail
      end
      end
    end
    
    # @note this function is reserved for Elten usage
def thr2
  $playlistvolume=0.8
  $playlistindex = 0 if $playlistindex == nil
  $playlistlastindex = -1 if $playlistlastindex == nil
plpos=0
  loop do
    sleep(0.1)
    if $playlist.size > 0
    plpos=$playlistbuffer.position if $playlistbuffer!=nil and $playlistpaused != true
    if $playlistlastindex != $playlistindex or $playlistbuffer == nil
      $playlistbuffer.close if $playlistbuffer != nil
      $playlistindex=0 if $playlistindex>=$playlist.size        
      if $playlist[$playlistindex] != nil      
                $playlistbuffer = Bass::Sound.new($playlist[$playlistindex])
        else
              $playlistindex += 1
              $playlistindex = 0 if $playlistindex >= $playlist.size
              end
                                      $playlistlastindex=$playlistindex
            if $playlistbuffer != nil
              $playlistbuffer.volume=$playlistvolume
              $playlistbuffer.play
              end
    end
    sleep(0.05)
    if $playlistbuffer != nil
      if $playlistbuffer.position(true)>=$playlistbuffer.length(true)-128 and $playlistpaused != true
        $playlistindex += 1
      elsif $playlistpaused == true
        plpos=-1
      end
      $playlistbuffer.volume=$playlistvolume if $playlistbuffer.volume!=$playlistvolume and $playlistvolume.is_a?(Float) or $playlistvolume.is_a?(Integer)
    end
  else
    sleep(0.5)
    if $playlistbuffer != nil
    $playlistbuffer.close
    $playlistbuffer=nil
  end
  end
    end
end

# @note this function is reserved for Elten usage
  def thr3
    begin    
    $subthreads=[] if $subthreads==nil
                            loop do
                              sleep(0.05)
                                    if $scenes.size > 0
                                      if $currentthread != nil  
                                                                                  $subthreads.push($currentthread)
                                        end
                                      $currentthread = Thread.new do
                                        stopct=false
                                        sc=$scene
                                        begin
                                          if stopct == false
                                                                                    newsc = $scenes[0]
                                          $scenes.delete_at(0)
                                                                $scene = newsc
                      $stopmainthread = true
                                            while $scene != nil and $scene.is_a?(Scene_Main) == false and $exit!=true
Log.debug("Loading parallel scene: #{$scene.class.to_s}")
$scene.main
                      end
                                            $stopmainthread = false
                      $scene = sc
$scene=Scene_Main.new if $scene.is_a?(Scene_Main) or $scene == nil
$scene=nil if $exit==true
$key[0..255]=[false]*256
$focus = true if $scene.is_a?(Scene_Main) == false                     and $scene!=nil
Log.info("Exiting parallel scenes thread")
end
rescue Exception
      stopct=true
                                                  $stopmainthread = false
                      $scene = sc
$scene=Scene_Main.new if $scene.is_a?(Scene_Main) or $scene == nil
loop_update
$focus = true if $scene.is_a?(Scene_Main) == false                    
Log.error("Parallel scene: #{$!.to_s} #{$@.to_s}")
  retry
end
sleep(0.1)
end
end
  if $currentthread != nil    
  if $currentthread.status==false or $currentthread.status==nil
        if $subthreads.size > 0
    $currentthread=$subthreads.last
    while $subthreads.last.status==false or $subthreads.last.status==nil
      $subthreads.delete_at($subthreads.size-1)
           end
    if $restart!=true
           $currentthread.wakeup
         else
           $mainthread.wakeup
           $subthreads=[]
           $scene=Scene_Loading.new
           end
      $subthreads.delete_at($subthreads.size-1)
    else
      $mainthread.wakeup
      $currentthread=nil
      end
        end
                                                                                                                                                              end
         sleep(0.1)
       end
     rescue Exception
              retry
       end
     end

# @note this function is reserved for Elten usage
def agent_start
  Log.info("Starting Agent")
    #return if $ruby
                $agent = ChildProc.new("bin\\rubyw -Cbin agent.dat\"")
                $agent.write(Marshal.dump({'func'=>'relogin','name'=>Session.name,'token'=>Session.token, 'hwnd'=>$wnd})) if Session.name!="" and Session.name!=nil and Session.name!='guest'
    sleep(0.1)
end

# Gets the size of a file or directory
#
# @param location [String] a location to a file or directory
# @param upd [Boolean] window refreshing
# @return [Numeric] a size in bytes
def getsize(location,upd=true)
               if File.file?(location)
    sz= File.size(location)
        sz=0 if sz<0
    return sz
    end
                      return Dir.size(location)
                    end
                    
                    def createdirifneeded(dir)
                      if !FileTest.exists?(dir)
                        Log.debug("Dir not exists so creating: #{dir}")
                        Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode(dir), nil)
                        end
                      end

# Deletes a specified directory with all subdirectories
#
# @param dir [String] a directory location
# @param with [Boolean] if false, deletes all subentries of the directory, but does not delete that directory
def deldir(dir,with=true)
  return if !File.directory?(dir)
  Log.debug("Deleting directory #{dir}")
  dr=Dir.entries(dir)
  dr.delete("..")
  dr.delete(".")
  for t in dr
    f=dir+"/"+t
    if File.directory?(f)
      deldir(f)
    else
      File.delete(f)
      end
    end
    Win32API.new("kernel32","RemoveDirectoryW",'p','i').call(unicode(dir)) if with == true
  end
  
  def copyfile(source,destination,override=true)
    Log.debug("Copying file: (#{source}, #{destination})")
    c=1
    c=0 if override
    Win32API.new("kernel32","CopyFileW",'ppi','i').call(unicode(source), unicode(destination), c)
    end
  
  # Copies a directory with all files and subdirectories
  #
  # @param source [String] a location of directory to copy
  # @param destination [String] destination
  def copydir(source,destination,esource=nil,edestination=nil)
    Log.debug("Copying directory (#{source}, #{destination})")
    if esource==nil
      esource=source
      edestination=destination
      end
  loop_update
  Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode(destination),nil)
  e=Dir.entries(esource)
  e.delete("..")
  e.delete(".")
  ec=Dir.entries(esource)
  ec.delete(".")
  ec.delete("..")
  for i in 0..ec.size-1
    if File.directory?(esource+"\\"+ec[i])
      copydir(source+"\\"+e[i],destination+"\\"+e[i],esource+"\\"+ec[i],edestination+"\\"+ec[i])
    else
      begin
      copyfile(source+"\\"+e[i],destination+"\\"+e[i])
    rescue Exception
      end
      end
    end
  end
  
  # @note this function is reserved for Elten usage
  def tray
    if $ruby==true
      alert(_("Function not supported on this platform"))
      return
    end
    $totray=true
  end
  
  # Gets the main honor of specified user
  #
  # @param user [String] user name
  # @return [String] return a honor, if no honor selected, returns nil
  def gethonor(user)
    hn=srvproc("honors",{"list"=>"1", "user"=>user, "main"=>"1"})
    if hn[0].to_i<0 or hn[1].to_i==0
      return nil
    end
        if $language=="pl-PL"
          return hn[3].delete("\r\n")
        else
          return hn[5].delete("\r\n")
          end
        end
def speechtofile(file="",text="",name="")
  text=readfile(file) if text=="" and file!=""
                name=File.basename(file).gsub(File.extname(file),"") if file!="" and name==""
  voices=[]
  voicename = Win32API.new("bin\\screenreaderapi", "sapiGetVoiceNameW", 'i', 'i')
                for i in 0..Win32API.new("bin\\screenreaderapi","sapiGetNumVoices",'','i').call-1
    vc="\0"*1024
              Win32API.new("msvcrt", "wcscpy", 'pp', 'i').call(vc,voicename.call(i))
                  voices.push(deunicode(vc))
    end
  scl=[]
  for i in 0..100
    scl.push(i.to_s+"%")
    end
    fields=[Edit.new(p_("EAPI_Common", "Title"),"",name,true),Select.new(voices,true,$voice.abs,p_("EAPI_Common", "voice"),true),Select.new(scl,true,$rate,p_("EAPI_Common", "rate"),true),FilesTree.new(p_("EAPI_Common", "destination location"),getdirectory(40)+"\\",true,true,"Music"),FilesTree.new(p_("EAPI_Common", "File to read"),getdirectory(40)+"\\",false,true,"Documents"),Select.new([p_("EAPI_Common", "Create one file"),p_("EAPI_Common", "Divide by paragraphs"),p_("EAPI_Common", "Divide every")],true,0,p_("EAPI_Common", "Output splitting"),true),Edit.new(p_("EAPI_Common", "Duration of one file (minutes)"),"","15",true),CheckBox.new(p_("EAPI_Common", "Read file number")),Select.new(["mp3","ogg","wav"],true,0,p_("EAPI_Common", "Output format"),true),Button.new(p_("EAPI_Common", "preview")),Button.new(p_("EAPI_Common", "confirm")),Button.new(_("Cancel"))]
    fields[4]=nil if file!="" or text!=""
    splittime=fields[6]
    splitinform=fields[7]
    fields[6]=nil
    fields[7]=nil
    fields[5]=nil if text!="" and text.size<5000
    form=Form.new(fields)
    loop do
      loop_update
      form.update
      if fields[5]!=nil      
      if fields[5].index==2
  fields[6]=splittime
  fields[7]=splitinform
elsif fields[5].index==1
    fields[6]=nil
  fields[7]=splitinform
  else
  fields[6]=nil
  fields[7]=nil
end
end
if (enter or space)
  if form.index==9
        ttext=""
    if text!=""
      ttext=text
    end
    if ttext==""
              ext=File.extname(fields[4].selected(false))
        if ext == ".doc" or ext==".docx" or ext==".epu" or ext==".epub" or ext==".html" or ext==".mobi" or ext==".pdf" or ext==".mob" or ext==".rtf" or ext==".txt"
        fid="txe#{rand(36**8).to_s(36)}"
                    convert_book(fields[4].selected, $tempdir+"\\"+fid+".txt")
                    next if !FileTest.exists?($tempdir+"\\"+fid+".txt")
            File.rename($tempdir+"\\"+fid+".txt",$tempdir+"\\"+fid+".tmp")
            impfile=$tempdir+"\\#{fid}.tmp"
            ttext=readfile(impfile)
          File.delete(impfile)
            else
            ttext=readfile(fields[4].selected)
            end
                end
    if ttext!=""
    v=$voice
    r=$rate
    $voice=fields[1].index
    $rate=fields[2].index
    Win32API.new("bin\\screenreaderapi","sapiSetVoice",'i','i').call($voice)
    Win32API.new("bin\\screenreaderapi","sapiSetRate",'i','i').call($rate)
    t=ttext[0..9999]
    speech(t)
    while speech_actived
      loop_update
      speech_stop if enter or space
    end
    loop_update
    $voice=v
    $rate=r
    Win32API.new("bin\\screenreaderapi","sapiSetVoice",'i','i').call($voice)
    Win32API.new("bin\\screenreaderapi","sapiSetRate",'i','i').call($rate)
  else
    alert(p_("EAPI_Common", "No selected file to read"))
  end
end
if form.index==10
  ttext=""
    if text!=""
      ttext=text
    end
    if ttext==""
      ttext=readfile(fields[4].selected) if File.file?(fields[4].selected(false))
    end
  if fields[0].text==""
    alert(p_("EAPI_Common", "Type a file name"))
  elsif File.directory?(fields[3].selected(false))==false
    alert(p_("EAPI_Common", "Select file location"))
  elsif ttext==""
    alert(p_("EAPI_Common", "Select source file"))
  else
    cmd="bin\\rubyw bin/sapi.dat "
    cmd+="/v #{fields[1].index} "
    cmd+="/r #{fields[2].index} "
    cmd+="/n \"#{fields[0].text_str.gsub("\"","")}\" "
    maxd=0
if fields[5]!=nil
  maxd=fields[6].text_str.to_i*60 if fields[5].index==2
  cmd+="/d #{fields[6].text_str.to_i*60} " if fields[5].index==2
    cmd+="/s 1 " if fields[5].index==1
    cmd+="/p #{fields[7].checked} "  if fields[5].index>0
    end
    cname=fields[0].text_str.delete("\"\'\\/;\[\]\{\}\#\$^*\&|<>").gsub(" ","_")
    outd=fields[3].selected
    if fields[5]!=nil
    if fields[5].index>0
      outd+="\\#{cname}"
      Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode(outd),nil)
    end
    end
    outd+="\\#{cname}.wav"
    cmd+="/o \"#{outd}\" "
        if file==""
      if text!="" and text.size<256
        cmd+="/t \"#{text.gsub("\"","")}\" "
      else
        if text==""
        impfile=fields[4].selected
        ext=File.extname(fields[4].selected(false))
      else
        impfile=$tempdir+"\\txi#{rand(36**8).to_s(36)}.txt"
        writefile(impfile,text)
        ext="txt"
        end
        fid=""
        if ext == ".doc" or ext==".docx" or ext==".epu" or ext==".epub" or ext==".html" or ext==".mobi" or ext==".pdf" or ext==".mob" or ext==".rtf" or ext==".txt"
        fid="txe#{rand(36**8).to_s(36)}"
            convert_book(fields[4].selected, $tempdir+"\\"+fid+".txt")
            next if !FileTest.exists?($tempdir+"\\"+fid+".txt")
            File.rename($tempdir+"\\"+fid+".txt",$tempdir+"\\"+fid+".tmp")
            impfile=$tempdir+"\\#{fid}.tmp"
            end
            text=readfile($tempdir+"\\"+fid+".tmp")
              cmd+="/i \"#{impfile}\" "
        end
    else
      cmd+="/i \"#{file}\" "
      end
            outfl=$tempdir+"/sapiout"+rand(36**2).to_s(36)+".tmp"
      cmd+="/l \"#{outfl}\" "
      h=run(cmd,true)
      play("waiting")
      starttm=Time.now.to_i
edt=Edit.new(p_("EAPI_Common", "Please wait, reading to file"),"READONLY|MULTILINE","",true)
f=false            
t = 0
file=0
fn=false
rf=0
th=Thread.new do
  fr=nil
  case fields[8].index
  when 0
    fr=".mp3"
    when 1
      fr=".ogg"
    end
      rf=0
    while (file>rf or fn==false) and fr!=nil
        sleep(0.5)
  if file>rf+1
        n=rf+1
    if fields[5]!=nil and fields[5].index>0
        b=outd.gsub(File::extname(outd),"_"+sprintf("%03d",n)+File.extname(outd))
      else
        b=outd
        end
    if FileTest.exists?(b)
      c="bin\\ffmpeg -y -i \"#{b}\" \"#{b.gsub(".wav",fr)}\""
      executeprocess(c,true,0,false)
      File.delete(b) if FileTest.exists?(b)
    end
    rf+=1
  else
    break if fn and rf==file-1
    end
    end
  end
loop do
        loop_update
        tx=readfile(outfl)
                if /(\d+):(\d+)\/(\d+):(\d+)\/(\d+):(\d+)\/(\d+)/=~tx
                  if $4.to_i>0 and $5.to_i>0
                  edt.settext("#{($4.to_f/($5.to_f+1.0)*100.0).to_i}%\r\n#{p_("EAPI_Common", "Reading to file number")} #{$1}#{if maxd==0;"";else;" ("+(($6.to_f/maxd.to_f*100.0).to_i%101).to_s+"%)";end}\r\n#{p_("EAPI_Common", "Sentence %{cursentence} of %{sentences}")%{'cursentence'=>$2,'sentences'=>$3}}\r\n#{p_("EAPI_Common", "Read")} #{sprintf("%02d:%02d:%02d",$7.to_i/3600,($7.to_i/60)%60,$7.to_i%60)}#{if Time.now.to_i>starttm;"\r\n#{p_("EAPI_Common", "Estimated elapsed time")}"+sprintf("%02d:%02d:%02d",((Time.now.to_i-starttm)/($4.to_f/$5.to_f)*(1-$4.to_f/$5.to_f)).to_i/3600,((Time.now.to_i-starttm)/($4.to_f/$5.to_f)*(1-$4.to_f/$5.to_f)).to_i/60%60,((Time.now.to_i-starttm)/($4.to_f/$5.to_f)*(1-$4.to_f/$5.to_f)).to_i%60);else;"";end}",false)
          file=$1.to_i
          if f == false
          edt.focus
          f=true
          end
          end
        end
        edt.update
        x="\0"*1024
        Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
if x != "\003\001"
    file+=1
    edt.settext(p_("EAPI_Common", "Please wait, file processing..."))
    edt.focus
 fn=true
   while th.status!=false and th.status!=nil
   loop_update
   if file!=1
   edt.settext("#{p_("EAPI_Common", "Processing")}... #{(rf.to_f/(file-1).to_f*100.0).to_i}%",false)
   end
   edt.update
   end
  waiting_end
   alert(p_("EAPI_Common", "Reading to file finished."))
  break
  end
end
break
    end
  end
  if form.index==11
    break
    end
  end
  break if escape
      end
    end
       def decompress(source,destination,msg="")
         speech(msg)
         waiting
         executeprocess("bin\\7z x \"#{source}\" -y -o\"#{destination}\"",true)
         waiting_end
       end
       def compress(source,destination,msg=p_("EAPI_Common", "Compressing..."))
         speech(msg)
         waiting
ext=File.extname(destination).downcase
cmd=""
if ext==".rar"
  cmd="bin\\rar a -ep1 -r \"#{destination}\" \"#{source}\" -y"
else
  cmd="bin\\7z a \"#{destination}\" \"#{source}\" -y"
  end
executeprocess(cmd,true)
         waiting_end
       end
       
       def process_notification(notif)
         play(notif['sound']) if notif['sound']!=nil
         speech(notif['alert']) if notif['alert']!=nil
       end
       
       def register_activity
         return if Session.name==nil or Session.name=="" or Session.name=="guest" or $agent==nil
         $activitytime=Time.now.to_i
         $activity.keys.each{|k|$activity[k]=$activity[k].round}
         $agent.write(Marshal.dump({'func'=>'activity_register', 'activity'=>$activity}))
         $activity.clear
         Log.debug("User activity report generated and sent to server")
         end
     end
     end