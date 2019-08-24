require 'json'
require 'zlib'
begin
$dicts=[]
locales=JSON.parse(IO.read("locale.list"))
tpl={}
for dir in locales.keys
locale=locales[dir]
if File.directory?(dir) and FileTest.exists?(dir+"/LC_MESSAGES/elten.po")
puts("Exporting: #{dir}")
file=dir+"/LC_MESSAGES/elten.po"
    r=IO.read(file)
    r.gsub!("\"\r\n\""," ")
    r=r.gsub("\"\n\""," ").encode('UTF-8', :invalid => :replace)
    li = r.split("\n")
dict={}
dict['_code']=dir
dict['_name']=locale['name']
dict['_authors']=locale['authors']
dict['_enname']=locale['enname']
dict['_lcid']=locale['lcid']
dict[""]=r[0...r.index("\#:")]
ctxt=''
id=''
for l in li
l.chop! if l[-1..-1]=="\r"
if (/msgctxt "([^"]+)"/=~l)!=nil
  ctxt=$1.delete("\r\n")
end
if (/msgid "([^"]+)"/=~l)!=nil
  id=$1.delete("\r\n")
end
if (/msgstr "([^"]+)"/=~l)!=nil
d=$1
if id!=""
if dir[0..1].downcase=='en'
      dict.store(id,d.gsub(/ \{(([a-zA-Z0-9]+)_([a-zA-Z0-9_]+))\}/,"").delete("\r\n"))
      tpl.store(id,ctxt+":: "+d.delete("\r\n"))
else
msgid=tpl.key(ctxt+":: "+id)
      dict.store(msgid,d.gsub(/ \{(([a-zA-Z0-9]+)_([a-zA-Z0-9_]+))\}/,"").delete("\r\n"))
end
end
end
  end
dict['_doc_readme']=IO.read(FileTest.exists?(dir+"/readme.txt")?(dir+"/readme.txt"):(locales.keys[0]+"/readme.txt"))
dict['_doc_license']=IO.read(FileTest.exists?(dir+"/license.txt")?(dir+"/license.txt"):(locales.keys[0]+"/license.txt"))
dict['_doc_rules']=IO.read(FileTest.exists?(dir+"/rules.txt")?(dir+"/rules.txt"):(locales.keys[0]+"/rules.txt"))
dict['_doc_privacypolicy']=IO.read(FileTest.exists?(dir+"/privacypolicy.txt")?(dir+"/privacypolicy.txt"):(locales.keys[0]+"/privacypolicy.txt"))
dict['_doc_shortkeys']=IO.read(FileTest.exists?(dir+"/shortkeys.txt")?(dir+"/shortkeys.txt"):(locales.keys[0]+"/shortkeys.txt"))
$dicts.push(dict)
end
end
fp=File.open("locale.dat","wb")
fp.write(Zlib::deflate(Marshal.dump($dicts)))
fp.close
puts("Dictionaries exported")
end