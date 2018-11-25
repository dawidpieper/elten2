# Copyright (C) Dawid Pieper
# This code is distributedunder Open Public License

# This simple script is used in order to create Elten 2.3X translation files using PO GetText sources

require 'json'
require 'zlib'
begin
$dicts=[]
locales=JSON.parse(IO.read("locale.list"))
for dir in locales.keys
locale=locales[dir]
if File.directory?(dir) and FileTest.exists?(dir+"/LC_MESSAGES/elten.po")
puts("Exporting: #{dir}")
file=dir+"/LC_MESSAGES/elten.po"
    r=IO.read(file)
    r.gsub!("\"\r\n\""," ")
    r.gsub!("\"\n\""," ")
    li = r.split("\n")
dict={}
dict['_code']=dir
dict['_name']=locale['name']
dict['_authors']=locale['authors']
dict['_enname']=locale['enname']
dict['_lcid']=locale['lcid']
last=''
for l in li
l.chop! if l[-1..-1]=="\r"
if (/msgid "([^"]+)"/=~l)!=nil
  last=$1.delete("\r\n")
end
if (/msgstr "([^"]+)"/=~l)!=nil
      dict.store(last,$1.delete("\r\n"))
end
  end
dict['_doc_readme']=IO.read(FileTest.exists?(dir+"/readme.txt")?(dir+"/readme.txt"):(locales.keys[0]+"/readme.txt"))
dict['_doc_license']=IO.read(FileTest.exists?(dir+"/license.txt")?(dir+"/license.txt"):(locales.keys[0]+"/license.txt"))
dict['_doc_shortkeys']=IO.read(FileTest.exists?(dir+"/shortkeys.txt")?(dir+"/shortkeys.txt"):(locales.keys[0]+"/shortkeys.txt"))
$dicts.push(dict)
end
end
fp=File.open("locale.dat","wb")
fp.write(Zlib::deflate(Marshal.dump($dicts)))
fp.close
puts("Dictionaries exported")
end