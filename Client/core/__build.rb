# Elten Core Builder
# Copyright (C) 2014-2019 Dawid Pieper
# All Rights Reserved

# This scripts exports Elten code.
# and is generated automatically

require 'zlib'

data=[
[81165628,"Recorder",Zlib::deflate(IO.read("Recorder.rb"))],
[73382195,"Version",Zlib::deflate(IO.read("Version.rb"))],
[78087115,"SoundCard",Zlib::deflate(IO.read("SoundCard.rb"))],
[85146270,"SpeedTest",Zlib::deflate(IO.read("SpeedTest.rb"))],
[12956431,"RI_BASE64",Zlib::deflate(IO.read("RI_BASE64.rb"))],
[79569934,"GEM_STRSCAN",Zlib::deflate(IO.read("GEM_STRSCAN.rb"))],
[73682277,"RI_OSTRUCT",Zlib::deflate(IO.read("RI_OSTRUCT.rb"))],
[70125422,"GEM_JSON",Zlib::deflate(IO.read("GEM_JSON.rb"))],
[53536468,"RI_StringIO",Zlib::deflate(IO.read("RI_StringIO.rb"))],
[36493671,"GEM_ClipBoard",Zlib::deflate(IO.read("GEM_ClipBoard.rb"))],
[3748822,"Authentication",Zlib::deflate(IO.read("Authentication.rb"))],
[55400301,"Users_LastAvatars",Zlib::deflate(IO.read("Users_LastAvatars.rb"))],
[81349764,"Bass",Zlib::deflate(IO.read("Bass.rb"))],
[41660880,"Debug",Zlib::deflate(IO.read("Debug.rb"))],
[62421406,"Users_RecentlyRegistered",Zlib::deflate(IO.read("Users_RecentlyRegistered.rb"))],
[99817731,"Users_RecentlyActived",Zlib::deflate(IO.read("Users_RecentlyActived.rb"))],
[48466559,"UserSearch",Zlib::deflate(IO.read("UserSearch.rb"))],
[47793078,"Clock",Zlib::deflate(IO.read("Clock.rb"))],
[76861948,"Advanced",Zlib::deflate(IO.read("Advanced.rb"))],
[62153937,"Notes",Zlib::deflate(IO.read("Notes.rb"))],
[6066572,"SpeechToFile",Zlib::deflate(IO.read("SpeechToFile.rb"))],
[60376298,"FirstRun",Zlib::deflate(IO.read("FirstRun.rb"))],
[2450339,"ForgotPassword",Zlib::deflate(IO.read("ForgotPassword.rb"))],
[52171072,"Honors",Zlib::deflate(IO.read("Honors.rb"))],
[78101167,"RI_WIN32",Zlib::deflate(IO.read("RI_WIN32.rb"))],
[79529636,"Console",Zlib::deflate(IO.read("Console.rb"))],
[14909470,"Programs",Zlib::deflate(IO.read("Programs.rb"))],
[19954576,"Portable",Zlib::deflate(IO.read("Portable.rb"))],
[46818542,"Polls",Zlib::deflate(IO.read("Polls.rb"))],
[42773290,"Youtube",Zlib::deflate(IO.read("Youtube.rb"))],
[8043195,"License",Zlib::deflate(IO.read("License.rb"))],
[99050268,"Uploads",Zlib::deflate(IO.read("Uploads.rb"))],
[94189879,"Compiler",Zlib::deflate(IO.read("Compiler.rb"))],
[98914042,"RI",Zlib::deflate(IO.read("RI.rb"))],
[9360357,"Admins",Zlib::deflate(IO.read("Admins.rb"))],
[42289542,"WhatsNew",Zlib::deflate(IO.read("WhatsNew.rb"))],
[63403438,"SoundThemesGenerator",Zlib::deflate(IO.read("SoundThemesGenerator.rb"))],
[49922755,"ShortKeys",Zlib::deflate(IO.read("ShortKeys.rb"))],
[48266778,"Interface",Zlib::deflate(IO.read("Interface.rb"))],
[58182033,"Events",Zlib::deflate(IO.read("Events.rb"))],
[91142161,"RI_WINSOCK",Zlib::deflate(IO.read("RI_WINSOCK.rb"))],
[86005065,"Bug",Zlib::deflate(IO.read("Bug.rb"))],
[92009633,"UsersAddedMeToContacts",Zlib::deflate(IO.read("UsersAddedMeToContacts.rb"))],
[23428019,"Audio",Zlib::deflate(IO.read("Audio.rb"))],
[10940112,"GEM_FMOD",Zlib::deflate(IO.read("GEM_FMOD.rb"))],
[3378667,"ReadMe",Zlib::deflate(IO.read("ReadMe.rb"))],
[4417910,"Blog",Zlib::deflate(IO.read("Blog.rb"))],
[36025832,"Ban",Zlib::deflate(IO.read("Ban.rb"))],
[81325139,"Users",Zlib::deflate(IO.read("Users.rb"))],
[34255600,"RI_OPENSSL",Zlib::deflate(IO.read("RI_OPENSSL.rb"))],
[53046486,"Chat",Zlib::deflate(IO.read("Chat.rb"))],
[65730037,"Languages",Zlib::deflate(IO.read("Languages.rb"))],
[86761238,"Files",Zlib::deflate(IO.read("Files.rb"))],
[19338655,"SoundThemes",Zlib::deflate(IO.read("SoundThemes.rb"))],
[10186735,"Changes",Zlib::deflate(IO.read("Changes.rb"))],
[43163030,"Player",Zlib::deflate(IO.read("Player.rb"))],
[35479022,"VisitingCard",Zlib::deflate(IO.read("VisitingCard.rb"))],
[50598139,"Account",Zlib::deflate(IO.read("Account.rb"))],
[33035659,"Contacts",Zlib::deflate(IO.read("Contacts.rb"))],
[31550081,"Program",Zlib::deflate(IO.read("Program.rb"))],
[24142971,"Update",Zlib::deflate(IO.read("Update.rb"))],
[67966518,"Voice",Zlib::deflate(IO.read("Voice.rb"))],
[54428309,"Messages",Zlib::deflate(IO.read("Messages.rb"))],
[73925933,"Online",Zlib::deflate(IO.read("Online.rb"))],
[11843225,"MainMenu",Zlib::deflate(IO.read("MainMenu.rb"))],
[63520501,"Forum",Zlib::deflate(IO.read("Forum.rb"))],
[4657550,"Main",Zlib::deflate(IO.read("Main.rb"))],
[1549615,"Login",Zlib::deflate(IO.read("Login.rb"))],
[75870414,"Registration",Zlib::deflate(IO.read("Registration.rb"))],
[21759743,"Loading",Zlib::deflate(IO.read("Loading.rb"))],
[36973534,"EAPI_External",Zlib::deflate(IO.read("EAPI_External.rb"))],
[93120873,"EAPI_Common",Zlib::deflate(IO.read("EAPI_Common.rb"))],
[95521779,"EAPI_EltenSRV",Zlib::deflate(IO.read("EAPI_EltenSRV.rb"))],
[89565098,"EAPI_Network",Zlib::deflate(IO.read("EAPI_Network.rb"))],
[92441059,"EAPI_UI",Zlib::deflate(IO.read("EAPI_UI.rb"))],
[10346421,"EAPI_Speech",Zlib::deflate(IO.read("EAPI_Speech.rb"))],
[83938464,"EAPI_Form",Zlib::deflate(IO.read("EAPI_Form.rb"))],
[45848054,"EAPI_Dictionary",Zlib::deflate(IO.read("EAPI_Dictionary.rb"))],
[43173883,"EAPI_EltenAPI",Zlib::deflate(IO.read("EAPI_EltenAPI.rb"))],
[34503174,"*Main",Zlib::deflate(IO.read("_Main.rb"))],
]
Dir.mkdir("build") if !FileTest.exists?("build")
fp=File.open("build/elten.edb","wb")
Marshal.dump(data,fp)
fp.close
