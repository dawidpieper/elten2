# frozen_string_literal: false
# OLEProperty
# helper class of Property with arguments.
class OLEProperty
  def initialize(obj, dispid, gettypes, settypes)
    @obj = obj
    @dispid = dispid
    @gettypes = gettypes
    @settypes = settypes
  end
  def [](*args)
    @obj._getproperty(@dispid, args, @gettypes)
  end
  def []=(*args)
    @obj._setproperty(@dispid, args, @settypes)
  end
end

if FileTest.exists?("win32ole.so")
require("./win32ole.so")
else
require("./bin/win32ole.so")
end

module Win32
  class SAPI5 < WIN32OLE
    VERSION = '0.2.0'
  end
  class SpAudioFormat < SAPI5
    def initialize
      super("{9EF96870-E160-4792-820D-48CF0649E4EC}")
    end
  end
  class SpCustomStream < SAPI5
    def initialize
      super("{8DBEF13F-1948-4aa8-8CF0-048EEBED95D8}")
    end
  end
  class SpFileStream < SAPI5
    def initialize
      super("{947812B3-2AE1-4644-BA86-9E90DED7EC91}")
    end
  end
  class SpInProcRecoContext < SAPI5
    def initialize
      super("{73AD6842-ACE0-45E8-A4DD-8795881A2C2A}")
    end
  end
  class SpInProcRecognizer < SAPI5
    def initialize
      super("{41B89B6B-9399-11D2-9623-00C04F8EE628}")
    end
  end
  class SpLexicon < SAPI5
    def initialize
      super("{0655E396-25D0-11D3-9C26-00C04F8EF87C}")
    end
  end
  class SpMemoryStream < SAPI5
    def initialize
      super("{5FB7EF7D-DFF4-468a-B6B7-2FCBD188F994}")
    end
  end
  class SpMMAudioIn < SAPI5
    def initialize
      super("{CF3D2E50-53F2-11D2-960C-00C04F8EE628}")
    end
  end
  class SpMMAudioOut < SAPI5
    def initialize
      super("{A8C680EB-3D32-11D2-9EE7-00C04F797396}")
    end
  end
  class SpObjectToken < SAPI5
    def initialize
      super("{EF411752-3736-4CB4-9C8C-8EF4CCB58EFE}")
    end
  end
  class SpObjectTokenCategory < SAPI5
    def initialize
      super("{A910187F-0C7A-45AC-92CC-59EDAFB77B53}")
    end
  end
  class SpPhoneConverter < SAPI5
    def initialize
      super("{9185F743-1143-4C28-86B5-BFF14F20E5C8}")
    end
  end
  class SpPhraseInfoBuilder < SAPI5
    def initialize
      super("{C23FC28D-C55F-4720-8B32-91F73C2BD5D1}")
    end
  end
  class SpSharedRecoContext < SAPI5
    def initialize
      super("{47206204-5ECA-11D2-960F-00C04F8EE628}")
    end
  end
  class SpSharedRecognizer < SAPI5
    def initialize
      super("{3BEE4890-4FE9-4A37-8C1E-5E7E12791C1F}")
    end
  end
  class SpTextSelectionInformation < SAPI5
    def initialize
      super("{0F92030A-CBFD-4AB8-A164-FF5985547FF6}")
    end
  end
  class SpUnCompressedLexicon < SAPI5
    def initialize
      super("{C9E37C15-DF92-4727-85D6-72E5EEB6995A}")
    end
  end
  class SpVoice < SAPI5
    SPF_DEFAULT          = 0  # Not asynchronous
    SPF_ASYNC            = 1  # Asynchronous
    SPF_PURGEBEFORESPEAK = 2  # Purges all pending speak requests prior to this speak call.
    SPF_IS_FILENAME      = 4  # The string passed is a file name, and the file text should be spoken.
    SPF_IS_XML           = 8  # The input text will be parsed for XML markup.
    SPF_IS_NOT_XML       = 16 # The input text should not be considered XML markup.
    def initialize
      super("{96749377-3391-11D2-9EE3-00C04F797396}")
    end
  end
  class SpWaveFormatEx < SAPI5
    def initialize
      super("{C79A574C-63BE-44b9-801F-283F87F898BE}")
    end
  end
end

begin
param=$*.join(" ")
include Win32
v = SpVoice.new
def getparam(prms)
prms=[prms] if prms.is_a?(String)
for prm in prms
ind=$*.find_index(prm)
if ind!=nil
if $*[ind+1]!=nil
return $*[ind+1].dup
end
end
end
return nil
end
if pr=getparam(["/v","-v","/voice","--voice"])
v.voice=v.getvoices.item(pr)
end
if pr=getparam(["/r","-r","/rate","--rate"])
r=pr.to_i-50
r/=5.0
v.rate=r
end
$maxduration=0
if pr=getparam(["/d","-d","/duration","--duration","/maxduration","--maxduration","/md","-md"])
$maxduration=pr.to_i
end
if pr=getparam(["/s","-s","/splparagraph","--splparagraph"])
$splparagraph=pr.to_i
end
$outputfilenumber=1
if pr=getparam(["/o","-o","/output","--output","/outputfile","--outputfile"])
f=SpFileStream.new
f.Format.Type=39
fl=pr
if $maxduration > 0 or $splparagraph == 1
fl.gsub!(File.extname(pr),"_001"+File.extname(pr))
$outputfilenumber=1
end
f.Open(fl,3)
v.AudioOutputStream=f
$outputfile=pr
$currentoutputfile=fl
end
text=""
if pr=getparam(["/i","-i","/input","--input","/inputfile","--inputfile"])
text=IO.read(pr)
$inputfile=pr
end
if pr=getparam(["/t","-t","/text","--text"])
text=pr
end
if pr=getparam(["/l","-l","/log","--log"])
$outputstatus=pr
end
$name=""
if pr=getparam(["/n","-n","/name","--name"])
$name=pr
end
$prefix=0
if pr=getparam(["/p","-p","/prefix","--prefix"])
$prefix=pr.to_i
end
if text!=""
text.gsub!("<","")
text.gsub!(">","")
size=text.size
readsize=0
sentences=text.split(". ")
d=0
fd=0
ld=0
for i in 0..sentences.size-1
out=$outputfilenumber.to_s+":"+i.to_s+"/"+sentences.size.to_s+":"+readsize.to_s+"/"+size.to_s+":"+d.to_i.to_s+"/"+fd.to_i.to_s
if $outputstatus!=nil
File.write($outputstatus,out)
else
puts(out)
end
d=File.size($currentoutputfile)/192000.0
fd+=d-ld
ld=d
v.speak(sentences[i]+". ")
readsize+=(sentences[i].size+2)
if ($maxduration>0 and d>=$maxduration-5) or ($splparagraph == 1 and ((sentences[i].include?("\r\n\r\n") and d>60) or (sentences[i].include?("\n") and d>3600) or (sentences[i].downcase.include?("rozdział") and d>180)))
ld=0
f.Close
$currentoutputfile.gsub!(sprintf("_%03d",$outputfilenumber),sprintf("_%03d",$outputfilenumber+1))
$outputfilenumber+=1
f.Open($currentoutputfile,3)
case $prefix
when 1
v.speak("#{$outputfilenumber.to_s}: #{$name}.")
when 2
v.speak("#{$name}: #{$outputfilenumber.to_s}.")
end

end
end
end
end