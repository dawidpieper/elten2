# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_Registration
  def main
    name = ""
    password = ""
    mail = ""
    while name == ""
    name = input_text(p_("Registration", "Enter your username. It will be used for identification.The maximum length of the  username is 64 characters"), 0, "", false, (("a".."z").to_a+("A".."Z").to_a+("0".."9").to_a+["-","_"]))
  end
  name.gsub("@") do
    alert(p_("Registration", "A username cannot contain an at. The character will be ignored."))
  end    
  name.gsub("/") do
    alert(p_("Registration", "User name can not contain slashes. Sign will be Omitted."))
  end
    name.gsub("\\") do
    alert(p_("Registration", "User name can not contain slashes. Sign will be Omitted."))
  end
    name.gsub(" ") do
    alert(p_("Registration", "User name can not contain spaces. Sign will be Omitted"))
  end
          name.delete!("/ ,;@")
  name.delete!("\\")
  pswconfirm = ""
  while password == "" or password != pswconfirm
    password = input_text(p_("Registration", "Enter your password. It is recommended to use a strong password, which consists  of numbers and letters. Maximum length of the password is 256 characters."),"password")
    pswconfirm = input_text(p_("Registration", "Reenter your password"),"password")
    if pswconfirm != password
      alert(p_("Registration", "The entered passwords differ"))
      end
  end
  while mail.include?("@")==false
    mail = input_text(p_("Registration", "Enter your e-mail address. It will be used in case you forget your password and  to send important information."))
    end
regtemp = srvproc("register", {"register"=>"1", "name"=>name, "password"=>password, "mail"=>mail})
id = regtemp[0].to_i
case id
when 0
  alert(p_("Registration", "Registration is successful, thank you. You can log in using your username and  password."))
  when -1
    alert(p_("Registration", "An unknown error occurred while using database"))
    when -2
      alert(p_("Registration", "Account with the specified username already exists."))
      when -3
        alert(p_("Registration", "An error occurred while trying to write data."))
        when -4
          alert(p_("Registration", "An error occurred while connecting to the server."))
        end
        speech_wait
      $scene = Scene_Loading.new
      main if id != 0
  end
  end