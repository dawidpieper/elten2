#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class ClipboardError < StandardError; end
class Clipboard
# Clipboard data types
TEXT = 1
OEMTEXT = 7
UNICODETEXT = 13
  # Alloc constants
  GMEM_MOVEABLE = 0x0002
  GMEM_ZEROINIT = 0x0040
  GHND = GMEM_MOVEABLE | GMEM_ZEROINIT

  # Clipboard specific functions
  @@OpenClipboard = Win32API.new(
     'user32', 'OpenClipboard', ['L'], 'I'
  )

  @@CloseClipboard = Win32API.new(
     'user32', 'CloseClipboard', [], 'I'
  )

  @@GetClipboardData = Win32API.new(
     'user32', 'GetClipboardData', ['I'], 'P'
  )
    
  @@SetClipboardData = Win32API.new(
     'user32', 'SetClipboardData', ['I', 'I'], 'I'
  )

  @@EmptyClipboard = Win32API.new(
     'user32', 'EmptyClipboard', [], 'I'
  )

  # Generic Win32 functions
  @@GlobalAlloc  =
Win32API.new("kernel32","GlobalAlloc",["I","I"],"I")
@@GlobalLock = Win32API.new("kernel32","GlobalLock",["I"],"I")
@@GlobalFree = Win32API.new("kernel32","GlobalFree",["I"],"I")
@@memcpy = Win32API.new("msvcrt", "memcpy", ["I", "P", "I"],
"I")
  def self.open
     if 0 == @@OpenClipboard.call(0)
        raise ClipboardError, "OpenClipboard() failed"
     end
  end

  def self.close
     @@CloseClipboard.call
  end

  # Sets the clipboard contents to the data that you specify.  You may
# optionally specify a clipboard format. The default is Clipboard::TEXT.
def self.set_data(clip_data, format = TEXT)
self.open
@@EmptyClipboard.call
     # NULL terminate text
     case format
        when TEXT, OEMTEXT, UNICODETEXT
           clip_data << "\0"
     end

     # Global Allocate a movable piece of memory.
     hmem = @@GlobalAlloc.call(GHND, clip_data.length + 4)
     mem  = @@GlobalLock.call(hmem)
     @@memcpy.call(mem, clip_data, clip_data.length)

     # Set the new data
     if @@SetClipboardData.call(format, hmem) == 0
        @@GlobalFree.call(hmem)
        self.close
        raise ClipboardError, "SetClipboardData() failed"
     end

     @@GlobalFree.call(hmem)
     self.close
     self
  end

  # Returns the data currently in the clipboard.  If 'format' is
  # specified, it will attempt to retrieve the data in that format. The
# default is Clipboard::TEXT.
def self.data(format = TEXT)
  clipdata = ""
self.open
begin
clipdata = @@GetClipboardData.call(format)
rescue ArgumentError
# Assume failure is caused by no data in clipboard
end
self.close
clipdata
end
  # An alias for Clipboard.data.
  def self.get_data(format = TEXT)
     self.data(format)
  end

  # Empties the contents of the clipboard.
  def self.empty
     self.open
     @@EmptyClipboard.call
     self.close
     self
   end
   
   def self.get_unic
     self.open
     i=Win32API.new(     'user32', 'GetClipboardData', ['I'], 'L'  ).call(UNICODETEXT)
          buf="\0"*(Win32API.new("kernel32","WideCharToMultiByte",'iilipi','i').call(65001,0,i,-1,nil,0))
Win32API.new("kernel32","WideCharToMultiByte",'iilipi','i').call(65001,0,i,-1,buf,buf.bytesize-1)
buf=buf<<0
buf=buf.delete("\0")
return buf
     end
   
  end
#Copyright (C) 2014-2018 Dawid Pieper