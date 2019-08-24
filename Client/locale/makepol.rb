require 'zlib'
l=Marshal.load(Zlib.inflate(IO.binread("locale.dat")))
tpl=l[0]

m={}
ct={}
for s in tpl.keys
next if s[0..0]=="_"||s==""
cat=s[0...s.index(":")]
m[cat]||=[]
ct[cat]||=[]
if m[cat].include?(tpl[s])
for i in 0...m[cat].size
m[cat][i]+=" {"+(ct[cat][i][(ct[cat][i].index(":")+1)..-1])+"}" if ct[cat][i]==tpl[s]
end
tpl[s]+=" {"+(s[(s.index(":")+1)..-1])+"}" 
end
m[cat].push(tpl[s])
ct[cat].push(s)
end

files=Dir.entries("../core")
files.delete(".")
files.delete("..")
cnt={}
for f in files
cnt[f]=IO.readlines("../core/"+f)
end

sr={}
for cat in ct.keys
sr[cat]=[]
for i in 0...ct[cat].size
for f in cnt.keys
for li in 0...cnt[f].size
if cnt[f][li].include?(ct[cat][i])
sr[cat][i]=f+":"+(li+1).to_s
end
end
end
end
end

for lang in l
fp=File.open(lang['_code']+"/lc_messages/elten.po","w")
fp.write("msgid \"\"\nmsgstr \"\"\n")
fp.write("\"Project-Id-Version: Elten 2.3\\n\""+"\n")
fp.write("\"POT-Creation-Date: \\n\""+"\n")
fp.write("\"Language-Team: #{lang['_authors'].join(", ")}\\n\""+"\n")
fp.write('"MIME-Version: 1.0\n"'+"\n")
fp.write('"Content-Type: text/plain; charset=UTF-8\n"'+"\n")
fp.write('"Content-Transfer-Encoding: 8bit\n"'+"\n")
fp.write("Language: #{lang['_code']}\\n"+"\n")
fp.write("\n")
for cat in m.keys
for i in 0...m[cat].size
c=m[cat][i]
msgid=m[cat][i]
msgid=ct[cat][i] if lang['_code'][0..1].downcase=='en'
msgstr=m[cat][i]
fuzzy=true if lang['_code'][0..1].downcase!='en'
for t in lang.keys
if t==ct[cat][i]
msgstr=lang[t]
fuzzy=false
end
end
fuzzy=true if msgstr==msgid and msgid.count(" ")>0
fp.write("#: #{sr[cat][i]}\n") if sr[cat][i]!=nil
fp.write("#, fuzzy\n") if fuzzy
fp.write("msgctxt \"#{cat}\"\nmsgid \"#{msgid}\"\nmsgstr \"#{msgstr}\"\n\n")
end
end
fp.close
end