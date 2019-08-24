require 'rubygems'
def sfile(file)
return rfile(file) if FileTest.exists?(file)
3.times {file.chop!} if file[-3..-1]==".rb" or file[-3..-1]==".so"
suc=false
for pa in $LOAD_PATH
s=false
if File.file?(pa+"/"+file) or FileTest.exists?(pa+"/"+file+".rb")
rfile(pa+"/"+file+".rb") if s==false
s=true
suc=true
elsif FileTest.exists?(pa+"/"+file+".so")
suc=true
if !$soes.include?(file+".so")
$soes.push(file+".so")
$soeloc.push(pa+"/"+file+".so")
$cnt += "\r\nrequire(\"./#{File.basename(file)}\")\r\n"
""
else
return ""
end
end
end
if suc==false
for fl in Gem.find_files(file)
if fl[-3..-1]==".rb"
rfile(fl)
elsif fl[-3..-1]==".so"
if !$soes.include?(file+".so")
$soes.push(file+".so")
$soeloc.push(fl)
$cnt += "\r\nrequire(\"./#{File.basename(file)}\")\r\n"
""
else
return ""
end
end
end
end
return ""
end
def rfile(file)
$res||=[]
return "" if $res.include?(file)
$res.push(file)
puts(File.basename(file))
r=IO.read(file)
r.gsub!(/require( *)(\(*)(\"|\')([^\"\']+)(\"|\')(\)*)/) do
sfile($4)
""
end
r.gsub!(/require_relative( *)(\(*)(\"|\')([^\"\']+)(\"|\')(\)*)/) do
f=$4
f+=".rb" if f[-3..-1]!=".rb"
if !$rels.include?(f)
$rels.push(f)
rfile(File.dirname(file)+"/"+f)
end
""
end
r.gsub!("require lib","")
$cnt+="\r\n"+r+"\r\n"
$res.push(r)
end

$res=[]
$cnt="$LOAD_PATH<<\".\"\r\n$VERBOSE=nil\r\n"
$soes=[]
$soeloc = []
$reqs=[]
$rels=[]
sfile("agent.rb")
Dir.mkdir("export") if !FileTest.exists?("export")
Dir.mkdir("export/inc") if !FileTest.exists?("export/inc")
$cnt.delete!("\r")
$cnt.gsub!(" # :nodoc:","")
$cnt.gsub!(/^([\t ]*)\#([a-zA-Z0-9\t ]+)([^\n]+)$/,"")
#$cnt.gsub!(/([\t ]+)\#([\t ]#)([^\n]+)$/,"")
$cnt.gsub!(/^([ \t]*)\#([ \t]*)$/,"")
$cnt.gsub!(/\n(\n+)/,"\n")
$cnt.gsub!(/\n([ \t]+)/,"\n")
puts $cnt.size
IO.write("export/agent.dat",$cnt)