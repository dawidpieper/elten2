#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Chat
  def main
    $locksyn = false
            chat = srvproc("chat","name=#{$name}\&token=#{$token}\&recv=1")
    err = chat[0].to_i
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
      for i in 1..chat.size - 1
        text += chat[i]
      end
        if @lasttext != text
          play("chat_message")
      @lasttext = text
      speech("Ostatnia wiadomość: " + text)
    end
    msg = "Dołączył do dyskusji."
    srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=#{msg}")
      speech_wait
      @msg = Edit.new("Twoja wiadomość")
      i = 0
      loop do
        i += 1
        @msg.update
        loop_update
        update
      if $scene != self
        break
      end
      if i > 200
                File.delete("chattemp") if FileTest.exist?("chattemp")
                    writefile("chattemp",srvproc("chat","name=#{$name}\&token=#{$token}\&recv=1"))
        recv if $key[0x10] == false
        i = 0
        end
      end
      end
      def update
        if escape
                    msg = "Opuścił dyskusję"
    srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=#{msg}")
                    $scene = Scene_Main.new
          end
        if enter
                    @msg.finalize
          str = @msg.text_str.gsub("\004LINE\004","")
          srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=#{str}")
          play("right")
          @msg.settext("")
          $locksyn = false
        end
        if $key[0x09] == true
         speech(@lasttext) if @lasttext != nil
         end
        end
          def recv
    chat = IO.readlines("chattemp")
    File.delete("chattemp") if $DEBUG != true
    err = chat[0].to_i
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
      for i in 1..chat.size - 1
        text += chat[i]
      end
        if @lasttext != text
          play("chat_message")
      @lasttext = text
      speech_wait
      speech(text)
    end
      end
  end
#Copyright (C) 2014-2016 Dawid Pieper