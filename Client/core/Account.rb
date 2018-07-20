#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Account_Password
  def main
      oldpassword = ""
  password = ""
  repeatpassword = ""
  while oldpassword == ""
    oldpassword = input_text("Podaj stare hasło","password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    while password == ""
    password = input_text("Podaj nowe hasło","password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while repeatpassword == ""
    repeatpassword = input_text("Powtórz nowe hasło","password|ACCEPTESCAPE")
  end
  if repeatpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
  if password != repeatpassword
    speech("Pola: Nowe Hasło i Powtórz Nowe Hasło mają różne wartości.")
    speech_wait
    main
  end
    act = srvproc("account_mod","changepassword=1\&name=#{$name}\&token=#{$token}\&oldpassword=#{oldpassword}\&password=#{password}")
    err = act[0].to_i
  case err
  when 0
    speech("Hasło zostało zmienione.")
    speech_wait
    writeini($configdata + "\\login.ini","Login","AutoLogin","-1")
    $scene = Scene_Loading.new
    when -1
      speech("Błąd połączenia z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        when -6
          speech("Podano błędne stare hasło.")
          speech_wait
          $scene = Scene_Main.new
  end
    end
end

class Scene_Account_Mail
  def main
      password = ""
  mail = ""
  while password == ""
    password = input_text("Podaj hasło","password|ACCEPTESCAPE")
  end
  if password == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while mail == ""
    mail = input_text("Podaj nowy adres e-mail","ACCEPTESCAPE")
  end
  if mail == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    act = srvproc("account_mod","changemail=1\&name=#{$name}\&token=#{$token}\&oldpassword=#{password}\&mail=#{mail}")
    err = act[0].to_i
  case err
  when 0
    speech("Adres e-mail został zmieniony.")
    speech_wait
    $scene = Scene_Main.new
    when -1
      speech("Błąd połączenia z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        when -6
          speech("Podano błędne stare hasło.")
          speech_wait
          $scene = Scene_Main.new
  end
    end
end

class Scene_Account_VisitingCard
  def main
    dialog_open
            vc = srvproc("visitingcard","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
        err = vc[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..vc.size - 1
        text += vc[i]
      end
@form = Form.new([Edit.new("Twoja wizytówka:","MULTILINE",text,true),Button.new("Zapisz"),Button.new("Anuluj")])
visitingcard = ""
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index == 2)
    visitingcard = "\004ESCAPE\004"
    break
  end
  if ($key[0x11] and enter) or ((space or enter) and @form.index == 1)
    visitingcard = @form.fields[0].text_str
    break
    end
  end
      if visitingcard == "\004ESCAPE\004" or visitingcard == "\004TAB\004"
        dialog_close
        $scene = Scene_Main.new
        return
      end
buf = buffer(visitingcard)
      vc = srvproc("visitingcard_mod","name=#{$name}\&token=#{$token}\&buffer=#{buf}"      )
err = vc[0].to_i
case err
when 0
  speech("Zapisano.")
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
  end
  
  class Scene_Account_Status
    def main
            speech("Zmiana statusu")
      speech_wait
      text = ""
      while text == ""
      text = input_text("Podaj nowy status","ACCEPTESCAPE")
    end
    if text == "\004ESCAPE\004"
      $scene = Scene_Main.new
      return
    end
    ef = setstatus(text)
    if ef != 0
      speech("Błąd!")
    else
      speech("Status został zmieniony.")
    end
    speech_wait
    $scene = Scene_Main.new
        end
  end
  
  class Scene_Account_Profile
    def main
            speech("Edycja profilu")
      profile = srvproc("profile","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&get=1")
                    fullname = ""
        gender = 0
        birthdateyear = ""
        birthdatemonth = ""
        birthdateday = ""
        location = ""
        publicprofile = 0
        publicmail = 0
if profile[0].to_i == 0
        fullname = profile[1].delete("\r\n")
        gender = profile[2].delete("\r\n").to_i
        birthdateyear = profile[3].delete("\r\n")
        birthdatemonth = profile[4].delete("\r\n")
        birthdateday = profile[5].delete("\r\n")
        location = profile[6].delete("\r\n")
        publicprofile = profile[7].to_i
        publicmail = profile[8].to_i
      end
      fields = []
      fields.push(Edit.new("Imię i nazwisko","",fullname,true))
      fields.push(Select.new(["kobieta","mężczyzna"],false,gender,"Płeć",true))
      fields.push(Edit.new("Data urodzenia: rok","NUMBERS|LENGTH04",birthdateyear,true))
      fields.push(Edit.new("Data urodzenia: miesiąc","NUMBERS|LENGTH02",birthdatemonth,true))
      fields.push(Edit.new("Data urodzenia: dzień","NUMBERS|LENGTH02",birthdateday,true))
      fields.push(Edit.new("Lokalizacja","",location,true))
      fields.push(CheckBox.new("Ukryj mój profil przed osobami z poza mojej listy kontaktów",publicprofile))
      fields.push(Button.new("Zapisz"))
      fields.push(Button.new("Anuluj"))
      speech_wait
      @form = Form.new(fields)
      loop do
        loop_update
        @form.update
        if ((space or enter) and @form.index == 7) or (enter and $key[0x11])
$fullname=fields[0].text_str
$gender=fields[1].index
          pr = srvproc("profile","name=#{$name}\&token=#{$token}\&mod=1\&fullname=#{fields[0].text_str}\&gender=#{fields[1].index.to_s}\&birthdateyear=#{fields[2].text_str.to_i.to_s}\&birthdatemonth=#{fields[3].text_str.to_i.to_s}\&birthdateday=#{fields[4].text_str.to_i.to_s}\&location=#{fields[5].text_str}\&publicprofile=#{fields[6].checked}")
if pr[0].to_i < 0
    speech("Błąd")
  speech_wait
else
  speech("Zapisano")
  speech_wait
end
$scene = Scene_Main.new
          end
        $scene = Scene_Main.new if escape or ((space or enter) and @form.index == 8)
        break if $scene != self
        end
          end
        end
        
        class Scene_Account_Signature
  def main
    dialog_open
            sg = srvproc("signature","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&get=1")
        err = sg[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..sg.size - 1
        text += sg[i]
      end
@form = Form.new([Edit.new("Twoja sygnatura:","MULTILINE",text,true),Button.new("Zapisz"),Button.new("Anuluj")])
signature = ""
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index == 2)
    signature = "\004ESCAPE\004"
    break
  end
  if ($key[0x11] and enter) or ((space or enter) and @form.index == 1)
    signature = @form.fields[0].text_str
    break
    end
  end
      if signature == "\004ESCAPE\004" or signature == "\004TAB\004"
        dialog_close
        $scene = Scene_Main.new
        return
      end
buf = buffer(signature)
      sg = srvproc("signature","name=#{$name}\&token=#{$token}\&buffer=#{buf}\&set=1")
err = sg[0].to_i
case err
when 0
  speech("Zapisano.")
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
end

class Scene_Account_Greeting
  def main
    dialog_open
            gt = srvproc("greetings","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&get=1")
        err = gt[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..gt.size - 1
        text += gt[i]
      end
@form = Form.new([Edit.new("Twoja wiadomość powitalna:","",text,true),Button.new("Zapisz"),Button.new("Anuluj")])
greeting = ""
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index == 2)
    greeting = "\004ESCAPE\004"
    break
  end
  if (enter) or ((space or enter) and @form.index == 1)
    greeting = @form.fields[0].text_str
    break
    end
  end
      if greeting == "\004ESCAPE\004" or greeting == "\004TAB\004"
        dialog_close
        $scene = Scene_Main.new
        return
      end
buf = buffer(greeting)
      gt = srvproc("greetings","name=#{$name}\&token=#{$token}\&buffer=#{buf}\&set=1")
err = gt[0].to_i
case err
when 0
  speech("Zapisano.")
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
end

class Scene_Account_Avatar
  def main
    dialog_open
    @tree=FilesTree.new("Ustaw awatar",getdirectory(26),false,false,"Documents",[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma"])
    loop do
      loop_update
      @tree.update
      break if escape
      if enter
        pt=@tree.path+@tree.file
        if File.directory?(pt)==false
          avatar_set(pt)
          break
          end
              end
    end
    dialog_close
    $scene=Scene_Main.new
    end
  end
  
  class Scene_Account_WhatsNew
    def main
      wnc=srvproc("whatsnew_config","name=#{$name}\&token=#{$token}\&get=1")
      if wnc[0].to_i<0
        speech("Błąd.")
        speech_wait
        return $scene=Scene_Main.new
      end
      options=["Powiadom i pokaż w co nowego","Tylko powiadom","Zignoruj"]
      cats=["Nowe wiadomości","Nowe wpisy w śledzonych wątkach","Nowe wpisy na śledzonych blogach","Nowe komentarze na twoim blogu","Nowe wątki na śledzonych forach","Nowe wpisy na śledzonych forach","Nowi znajomi","Urodziny znajomych","Wzmianki"]
      @fields=[]
      for i in 0..cats.size-1
        @fields.push(Select.new(options,true,wnc[i+1].to_i,cats[i],true))
      end
@fields+=[Button.new("Zapisz"),Button.new("Anuluj")]
      @form=Form.new(@fields)
            loop do
        loop_update
        @form.update
        if (enter or space) and @form.index==@fields.size-2
          heads=["messages","followedthreads","followedblogs","blogcomments","followedforums","followedforumsthreads","friends","birthday","mentions"]
          t=""
          for i in 0..heads.size-1
            t+="&"+heads[i]+"="+@fields[i].index.to_s
          end
          prm="name=#{$name}\&token=#{$token}\&set=1"+t
                    if srvproc("whatsnew_config",prm)[0].to_i<0
            speech("Błąd.")
          else
            speech("Zapisano.")
            speech_wait
            break
            end
          end
        break if escape or ((enter or space) and @form.index==@fields.size-1)
          
        end
$scene=Scene_Main.new
        end
      end
      
      class Scene_Account_AutoLogins
  def main
        al=[]
    loop do
      password=input_text("Podaj hasło","PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        return $scene=Scene_Main.new
        break
      else
        al=srvproc("autologins","name=#{$name}\&token=#{$token}\&password=#{password}")
        if al[0].to_i<0
          speech("Wystąpił błąd podczas próby uwierzytelnienia konta. Prawdopodobnie podano błędne hasło.")
          speech_wait
        else
          break
          end
        end
    end
    als=[]
    t=0
        for a in al[1..al.size-1]
              case t
    when 0
      ret=0
      tim=""
      begin
        if ret<10        
        tm=Time.at(a.to_i)
        tim=sprintf("%04d-%02d-%02d %02d:%02d",tm.year,tm.month,tm.day,tm.hour,tm.min)
      end
    rescue Exception
      ret+=1
      retry
        end
              als.push([tim])
      t+=1
      when 1
        als.last.push(a.delete("\r\n"))
        t+=1
        when 2
                    als.last.push(a.delete("\r\n"))
          t=0
  end
end
selt=[]
for s in als
  selt.push("Komputer: #{s[2]}, adres IP utworzenia: #{s[1]}, data wygenerowania: #{s[0]}")
end
@sel=Select.new(selt,true,0,"Klucze automatycznego logowania")
loop do
  loop_update
  @sel.update
  break if escape
  break if $scene!=self
  globallogout if $key[0x2e] or enter
  if alt
    case menuselector(["Wyloguj wszystkie sesje","Odśwież","anuluj"])
    when 0
      globallogout
      when 1
        return main
        when 2
          return $scene=Scene_Main.new
          return
          end
    end
  end
$scene=Scene_Main.new
  end
def globallogout
  confirm("Czy chcesz usunąć wszystkie klucze automatycznego logowania i wylogować wszystkie zalogowane sesje? Wymagane będzie ponowne zalogowanie się do Eltena.") do
        loop do
      password=input_text("Podaj hasło","PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        @sel.focus
        return
        break
      else
        lg=srvproc("logout","global=1\&name=#{$name}\&token=#{$token}\&password=#{password}")
        if lg[0].to_i<0
          speech("Wystąpił błąd podczas próby uwierzytelnienia konta. Prawdopodobnie podano błędne hasło.")
          speech_wait
        else
          $name=""
          $token=""
          $restart=true
          $scene=Scene_Loading.new
          break
          return
          end
        end
    end
    end
  end
end

class Scene_Account_BlackList
  def main
            bt = srvproc("blacklist","name=#{$name}\&token=#{$token}\&get=1")
            if bt[0].to_i<00
          speech("Błąd.")
      speech_wait
      $scene = Scene_Main.new
      return
      end
      @blacklist = []
      selt=[]
      if bt.size>1            
      for u in bt[1..bt.size-1]
        @blacklist.push(u.delete("\r\n"))
              selt.push(u + ". " + getstatus(u))
        end
end
        header="Czarna lista"
              @sel = Select.new(selt,true,0,header)
                              loop do
loop_update
        @sel.update if @blacklist.size > 0
        update
        if $scene != self
          break
          end
                  end
      end
      def update
        $scene = Scene_Main.new if escape
                            if $key[0x2e]
          if @blacklist.size >= 1
          if simplequestion("Czy na pewno chcesz usunąć tego użytkownika z czarnej listy?") == 1
            if srvproc("blacklist","name=#{$name}\&token=#{$token}\&del=1\&user=#{@blacklist[@sel.index]}")[0].to_i<0
              speech("Błąd")
            else
              play("edit_delete")
              speech("Użytkownik został usunięty z czarnej listy.")
            end
            speech_wait
            @blacklist.delete_at(@sel.index)
            @sel.commandoptions.delete_at(@sel.index)
            @sel.focus
            end
          end
          end
        menu if alt
        usermenu(@blacklist[@sel.index],false) if enter and @blacklist.size > 0
                                      end
        def menu
          play("menu_open")
          play("menu_background")
          @menu=menulr(["","Dodaj","Usuń","Odśwież","Anuluj"],true,0,"",true)
          @menu.commandoptions[0]=@blacklist[@sel.index] if @blacklist.size>0
          if @blacklist.size==0
          @menu.disable_item(2)
          @menu.disable_item(0)
        end
        @menu.focus
          loop do
            loop_update
            @menu.update
            break if escape or alt or $scene!=self
            if enter or (@menu.index==0 and Input.trigger?(Input::DOWN))
              case @menu.index
              when 0
                loop_update
                if usermenu(@blacklist[@sel.index],true) == "ALT"
                break
              else
                                @menu.focus
                              end
                when 1
                  user=input_text("Podaj nazwę użytkownika, którego chcesz dodać do czarnej listy","ACCEPTESCAPE")
                  user=finduser(user) if user!="\004ESCAPE\004" and finduser(user).downcase==user.downcase
                  if user=="\004ESCAPE\004"
                                      elsif user_exist(user)==false
                    speech("Użytkownik nie istnieje")
                    speech_wait
                                      else
                  confirm("Użytkownik po dodaniu do twojej czarnej listy nie będzie mógł wysyłać do ciebie wiadomości prywatnych. Czy jesteś pewien, że chcesz kontynuować?") do
                    bl=srvproc("blacklist","name=#{$name}\&token=#{$token}\&add=1\&user=#{user}")
                    case bl[0].to_i
                    when 0
                      speech("Użytkownik #{user} został dodany do twojej czarnej listy")
                      @sel.commandoptions.push(user)
                      @blacklist.push(user)
                      when -1
                        speech("Błąd połączenia się z bazą danych.")
                        when -2
                          speech("Klucz sesji wygasł.")
                          speech_wait
                          $scene=Scene_Loading.new
                          return
                          when -3
                            speech("Do czarnej listy nie można dodawać członków administracji.")
                            when -4
                              speech("Ten użytkownik jest już dodany do twojej czarnej listy.")
                              when -5
                                speech("Użytkownik nie istnieje.")
                    end
                  speech_wait
                    end
                  end
                  break
                  when 2
                                        confirm("Czy na pewno chcesz usunąć tego użytkownika z czarnej listy?") do
            if srvproc("blacklist","name=#{$name}\&token=#{$token}\&del=1\&user=#{@blacklist[@sel.index]}")[0].to_i<0
              speech("Błąd")
            else
              play("edit_delete")
              speech("Użytkownik został usunięty z czarnej listy.")
            end
            speech_wait
            @blacklist.delete_at(@sel.index)
            @sel.commandoptions.delete_at(@sel.index)
            @sel.focus
            end
            break        
            when 3
                      $scene=Scene_Account_BlackList.new
                      break
                      when 4
                        $scene=Scene_Main.new
              break
                        end
              end
            end
play("menu_close")
          Audio.bgs_fade(200)
                  end
        end
#Copyright (C) 2014-2016 Dawid Pieper