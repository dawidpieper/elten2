# Copyright (C) Dawid Pieper
# This code is distributedunder Open Public License

# This simple script is used in order to create Elten 2.3X translation files using PO GetText sources

require 'json'
begin
$dicts={}
locales=JSON.parse(IO.read("locale.list"))
for dir in locales.keys
locale=locales[dir]
if File.directory?(dir) and FileTest.exists?(dir+"/LC_MESSAGES/elten.po")
puts("Exporting: #{dir}")
file=dir+"/LC_MESSAGES/elten.po"
    li=IO.readlines(file)
dict={}
last=''
for l in li
if (/msgid "([^"]+)"/=~l)!=nil
  last=$1.delete("\r\n")
end
if (/msgstr "([^"]+)"/=~l)!=nil
      dict.store(last,$1.delete("\r\n"))
end
  end
dict['_name']=locale['name']
dict['_authors']=locale['authors']
dict['_enname']=locale['enname']
dict['_lcid']=locale['lcid']
$dicts.store(dir,dict)
end
end
fp=File.open("locale.dat","w")
Marshal.dump($dicts,fp)
fp.close
puts("Dictionaries exported")
end