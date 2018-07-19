#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

# Simulation of the coming new Elten Engine

module Elten
    module Engine
      include EltenAPI
    module Speech
class <<self
      
def say(saytext,outputtype,alter)
  if outputtype==0
  Win32API.new("screenreaderapi","sayString",'pi','i').call(utf8(saytext),alter)
    else
    Win32API.new("screenreaderapi","sapiSayString",'pi','i').call(utf8(saytext),alter)
    end
end
def stop(outputtype)
  if outputtype==0
    Win32API.new("screenreaderapi","stopSpeech",'','i').call
  else
    Win32API.new("screenreaderapi","sapiStopSpeech",'','i').call
  end
  end
def isspeaking
  Win32API.new("screenreaderapi","sapiIsSpeaking",'','i').call
  end
  def getnumvoices
  Win32API.new("screenreaderapi","sapiGetNumVoices",'','i').call
end
  def getvoice
  Win32API.new("screenreaderapi","sapiGetVoice",'','i').call
end
def setvoice(v)
  Win32API.new("screenreaderapi","sapiSetVoice",'i','i').call(v)
end
def getrate
  Win32API.new("screenreaderapi","sapiGetRate",'','i').call
end
def setrate(r)
  Win32API.new("screenreaderapi","sapiSetRate",'i','i').call(r)
end
def getvolume
  Win32API.new("screenreaderapi","sapiGetVolume",'','i').call
end
def setvolume(v)
  Win32API.new("screenreaderapi","sapiSetVolume",'i','i').call(v)
end
def getvoicename(id)
  futf8(Win32API.new("screenreaderapi","sapiGetVoiceName",'i','p').call(id))
end
def getoutputmethod
  Win32API.new("screenreaderapi","getCurrentScreenReader",'','i').call
  end
def ispaused
  Win32API.new("screenreaderapi","sapiIsPaused",'','i').call
  end
  def setpaused(s)
  Win32API.new("screenreaderapi","sapiSetPaused",'s','i').call(s)
  end
  
end
end

module Kernel
  class <<self
    def getmodulefilename
      path="\0"*1024
Win32API.new("kernel32","GetModuleFileName",'ipi','i').call(0,path,path.size)
return path
end

def getexitcodeprocess(prochandle)
  x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(prochandle,x)
return x
  end

def copyfile(source,destination,method)
  Win32API.new("kernel32","CopyFile",'ppi','i').call(utf8(source),utf8(destination),method)
end

def movefile(source,destination)
  Win32API.new("kernel32","MoveFile",'ppi','i').call(utf8(source),utf8(destination))
end

def deletefile(source)
  Win32API.new("kernel32","DeleteFile",'p','i').call(utf8(source))
end


  end
end

end
  end
#Copyright (C) 2014-2016 Dawid Pieper