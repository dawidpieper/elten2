# Elten Agent
#Copyright (2014-2016) Dawid Pieper
#All Rights Reserved



require("win32api")
# Audio module
# By Darkleo

$stderr.reopen("agent_err_out.txt","w")

module Audio
  extend self
end

class AudioFile
  attr_reader :name
  attr_reader :sound
  def initialize filename, loopmode = FMod::LOOP_OFF
    @name = filename
    @sound = FMod::Sound.new filename
    @sound.loopMode = loopmode
    @channel = @sound.play true
    @closed = false
  end
  # TODO : use method missing...
  def play
    fail 'File closed' if @closed
    @channel.paused = false
  end
  def playing?
    fail 'File closed' if @closed
    !@channel.paused?
    #@channel start paused
  end
  def pause
    fail 'File closed' if @closed
    @channel.paused = true
  end
  def paused= bool
    fail 'File closed' if @closed
    @channel.paused = bool
  end
  def paused?
    fail 'File closed' if @closed
    @channel.paused?
  end
  def volume
    fail 'File closed' if @closed
    @channel.volume
  end
  def volume= vol
    fail 'File closed' if @closed
    @channel.volume = vol
  end
  def pan
    fail 'File closed' if @closed
    @channel.pan
  end
  def pan= pa
    fail 'File closed' if @closed
    @channel.pan = pa
  end
  def frequency
    fail 'File closed' if @closed
    @channel.frequency
  end
  def frequency= freq
    fail 'File closed' if @closed
    @channel.frequency = freq
  end
  def position unit=FMod::DEFAULT_UNIT
    fail 'File closed' if @closed
    @channel.position unit
  end
  def position=(pos, unit=FMod::DEFAULT_UNIT)
    fail 'File closed' if @closed
    @channel.position= pos, unit
  end
  def close
    fail 'File already closed' if @closed
    @channel.stop
    @sound.release
    @closed = true
  end
end




# DLL handle
# By Darkleo
# Thx to for constants and methods names

module FMod
  extend self
  DLL_PATH = 'fmodex.dll'

  # FMOD_INITFLAGS flags
  INIT_NORMAL = 0
  # FMOD_RESULT flags
  OK = 0
  ERR_CHANNEL_STOLEN = 11
  ERR_FILE_NOT_FOUND = 23
  ERR_INVALID_HANDLE = 36
  # FMOD_MODE flags
  DEFAULT = 0
  LOOP_OFF = 1
  LOOP_NORMAL = 2
  LOOP_BIDI = 4
  LOOP_BITMASK = 7
  FMOD_2D = 8
  FMOD_3D = 16
  HARDWARE = 32
  SOFTWARE = 64
  CREATESTREAM = 128
  CREATESAMPLE = 256
  OPENUSER = 512
  OPENMEMORY = 1024
  OPENRAW = 2048
  OPENONLY = 4096
  ACCURATETIME = 8192
  MPEGSEARCH = 16384
  NONBLOCKING = 32768
  UNIQUE = 65536
  # The default mode that the script uses
  DEFAULT_SOFTWARWE = LOOP_OFF | FMOD_2D | SOFTWARE
  # FMOD_CHANNELINDEX flags
  CHANNEL_FREE = -1
  CHANNEL_REUSE = -2
  # FMOD_TIMEUNIT_flags
  TIMEUNIT_MS = 1
  TIMEUNIT_PCM = 2
  # The default time unit the script uses
  DEFAULT_UNIT = TIMEUNIT_MS
  # Types supported by FMOD Ex
  FILE_TYPES = ['ogg', 'aac', 'wma', 'mp3', 'wav', 'it', 'xm', 'mod', 's3m', 'mid', 'midi']

  module System
    extend self
    pre = 'FMOD_System_'
    Create       = Win32API.new DLL_PATH, pre + 'Create',       'p',     'l'
    Init         = Win32API.new DLL_PATH, pre + 'Init',         'llll',  'l'
    Close        = Win32API.new DLL_PATH, pre + 'Close',        'l',     'l'
    Release      = Win32API.new DLL_PATH, pre + 'Release',      'l',     'l'
    CreateSound  = Win32API.new DLL_PATH, pre + 'CreateSound',  'lpllp', 'l'
    CreateStream = Win32API.new DLL_PATH, pre + 'CreateStream', 'lpllp', 'l'
    PlaySound    = Win32API.new DLL_PATH, pre + 'PlaySound',    'llllp', 'l'

    def start max_channels=32, flag=INIT_NORMAL, extraDriverData=0
      temp = '\x00'*4
      Create.call temp
      @@id = temp.unpack('i')[0]
      Init.call @@id, 32, INIT_NORMAL, 0
    end
    def dispose
      return unless @@id
      Close @@id
      Release @@id
      @@id = nil
    end
    def createSound filename, mode=DEFAULT_SOFTWARWE
      filename.gsub("http://") do
      return createStream(filename,mode)
      end
      temp = '\x00'*4
      result = CreateSound.call @@id, filename, mode, 0, temp
      fail "File not found: \"#{filename}\"" if result == ERR_FILE_NOT_FOUND
      temp.unpack('i')[0]
    end
    def createStream filename, mode=DEFAULT_SOFTWARWE
      temp = '\x00'*4
      result = CreateStream.call @@id, filename, mode, 0, temp
      fail "File not found: \"#{filename}\"" if result == ERR_FILE_NOT_FOUND
      temp.unpack('i')[0]
    end
    def playSound id, paused=false, channel=nil
      temp = channel ? [channel].pack('l') : '\x00'*4
      mode = channel ? CHANNEL_REUSE : CHANNEL_FREE
      paused = paused ? 1 : 0
      PlaySound.call @@id, mode, id, paused, temp
      Channel.new temp.unpack('i')[0]
    end
  end
  System.start

  class Sound
    pre = 'FMOD_Sound_'
    Release       = Win32API.new DLL_PATH, pre + 'Release',       'l',     'l'
    GetMode       = Win32API.new DLL_PATH, pre + 'GetMode',       'lp',    'l'
    SetMode       = Win32API.new DLL_PATH, pre + 'SetMode',       'll',    'l'
    SetLoopPoints = Win32API.new DLL_PATH, pre + 'SetLoopPoints', 'lllll', 'l'
    GetLength     = Win32API.new DLL_PATH, pre + 'GetLength',     'lpl',   'l'

    attr_reader :id
    attr_reader :channel
    def initialize filename
      @id = System.createStream filename
    end
    def release
      Release.call @id
    end
    def play paused=false
      @channel = System.playSound @id, paused
    end
    def mode
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0]
    end
    def mode=
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0]
    end
    def loopMode
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0] & LOOP_BITMASK
    end
    def loopMode= newMode
      SetMode.call @id, (mode & ~LOOP_BITMASK | newMode)
    end
    def lenght unit=DEFAULT_UNIT
      temp = '\x00'*4
      GetLength.call @id, temp, unit
      temp.unpack('i')[0]
    end
  end

  class Channel
    pre = 'FMOD_Channel_'
    Stop         = Win32API.new DLL_PATH, pre + 'Stop',         'l',   'l'
    IsPlaying    = Win32API.new DLL_PATH, pre + 'IsPlaying',    'lp',  'l'
    GetPaused    = Win32API.new DLL_PATH, pre + 'GetPaused',    'lp',  'l'
    SetPaused    = Win32API.new DLL_PATH, pre + 'SetPaused',    'll',  'l'
    GetVolume    = Win32API.new DLL_PATH, pre + 'GetVolume',    'lp',  'l'
    SetVolume    = Win32API.new DLL_PATH, pre + 'SetVolume',    'll',  'l'
    GetPan       = Win32API.new DLL_PATH, pre + 'GetPan',       'lp',  'l'
    SetPan       = Win32API.new DLL_PATH, pre + 'SetPan',       'll',  'l'
    GetFrequency = Win32API.new DLL_PATH, pre + 'GetFrequency', 'lp',  'l'
    SetFrequency = Win32API.new DLL_PATH, pre + 'SetFrequency', 'll',  'l'
    GetPosition  = Win32API.new DLL_PATH, pre + 'GetPosition',  'lpl', 'l'
    SetPosition  = Win32API.new DLL_PATH, pre + 'SetPosition',  'lll', 'l'

    attr_reader :id
    def initialize id
      @id = id
    end
    def stop
      Stop.call @id
    end
    def playing?
      temp = '\x00'*4
      IsPlaying.call @id, temp
      temp.unpack('i')[0] != 0
    end
    def paused?
      temp = '\x00'*4
      GetPaused.call @id, temp
      temp.unpack('i')[0] != 0
    end
    def paused=bool
      SetPaused.call @id, (bool ? 1 : 0)
    end
    def volume
      temp = '\x00'*4
      GetVolume.call @id, temp
      temp.unpack('f')[0]
    end
    def volume= vol
      SetVolume.call @id, [vol].pack('f').unpack('i')[0]
    end
    def pan
      temp = '\x00'*4
      GetPan.call @id, temp
      temp.unpack('f')[0]
    end
    def pan= pa
      SetPan.call @id, [pa].pack('f').unpack('i')[0]
    end
    def frequency
      temp = '\x00'*4
      GetFrequency.call @id, temp
      temp.unpack('f')[0]
    end
    def frequency= freq
      SetFrequency.call @id, [freq].pack('f').unpack('i')[0]
    end
    def position unit=DEFAULT_UNIT
      temp = '\x00'*4
      GetPosition.call @id, temp, unit
      temp.unpack('i')[0]
    end
    def position= pos, unit=DEFAULT_UNIT
      pos = pos[0] if Array === pos # why [pos, unit] ???
      SetPosition.call @id, pos, unit
    end
  end
end
module Audio
  $bgm = nil
  $bgs = nil
  $me = []
  $se = []
  def self.bgm_play(file,volume=100,pitch=100)
    file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
if $bgm != nil
  $bgm.close
  $bgm = nil
end
$bgm = AudioFile.new(utf8(file),2)
if volume < 100
  $bgm.volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $bgm.frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $bgm.frequency = freq
end
$bgm.play
return file
  end
  def self.bgm_stop
    if $bgm != nil
      $bgm.close
      $bgm = nil
      return true
    end
    return false
  end
  def self.bgm_fade(time=1000)
    Thread.new do
      t = time
                    pr = ($bgm.volume.to_f / 100.to_f).to_f
        w = (t.to_f / 100.to_f / 1000.to_f).to_f
      for i in 1..100
        if $bgm != nil
        delay(w)
        $bgm.volume -= pr
      else
        break
        end
        end
      end
    end
    def self.bgs_play(file,volume=100,pitch=100)
    file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
if $bgs != nil
  $bgs.close
  $bgs = nil
end
$bgs = AudioFile.new(utf8(file),2)
if volume < 100
  $bgs.volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $bgs.frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $bgs.frequency = freq
end
$bgs.play
return file
  end
  def self.bgs_stop
    if $bgs != nil
      $bgs.close
      $bgs = nil
      return true
    end
    return false
  end
    def self.bgs_fade(time=1000)
    Thread.new do
      t = time
              pr = ($bgs.volume.to_f / 100.to_f).to_f
        w = (t.to_f / 100.to_f / 1000.to_f).to_f
      for i in 1..100
        if $bgs != nil
        delay(w)
        $bgs.volume -= pr
      else
        break
        end
        end
      end
    end
    def self.me_play(file,volume=100,pitch=100)
    file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
$me.push(AudioFile.new(utf8(file),1))
if volume < 100
  $me[$me.size - 1].volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $me[$me.size - 1].frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $me[$me.size - 1].frequency = freq
end
$me[$me.size - 1].play
return file
  end
  def self.me_stop
    suc = false
    for i in 0..$me.size - 1
      $me[i].close
      $me[i] = nil
    end
    $me = []
    return suc
  end
    def self.se_play(file,volume=100,pitch=100)
      file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
$se.push(AudioFile.new(utf8(file),1))
if volume < 100
  $se[$se.size - 1].volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $se[$se.size - 1].frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $se[$se.size - 1].frequency = freq
end
$se[$se.size - 1].play
return file
  end
  def self.se_stop
    suc = false
for i in 0..$se.size - 1
      $se[i].close
      $se[i] = nil
      suc = true
    end
   $se = []
   return suc
  end
  def self.searchaudiofileextension(file)
    if FileTest.exist?(file) == false
ext = ['AIFF', 'ASF', 'ASX', 'DLS', 'FLAC', 'FSB', 'IT', 'M3U', 'MID', 'MOD', 'MP2', 'MP3', 'OGG', 'PLS', 'RAW', 'S3M', 'VAG', 'WAV', 'WAX', 'WMA', 'XM', 'XMA']
suc = false
for i in 0..ext.size - 1
  if FileTest.exist?(file + "." + ext[i])
    suc = true
    found = file + "." + ext[i]
    break
    end
end
if suc == true
  return found
else
  libfile = "\0" * 1024
  Win32API.new("kernel32","GetModuleFileNameA",'ipi','i').call(0,libfile,libfile.size)
  libfile.delete!("\0")
libfile = libfile.sub(File.dirname(libfile),".")
  libfile = libfile.sub(".exe",".ini")
  libfile = libfile.sub(".EXE",".INI")
  lib = "\0" * 1024
  Win32API.new("kernel32","GetPrivateProfileString",'ppppip','i').call("Game","Library","RGSS102E.dll",lib,lib.size,libfile)
  getrtppath = Win32API.new(lib, 'RGSSGetRTPPath', 'L', 'L')
    getpathwithrtp = Win32API.new(lib, 'RGSSGetPathWithRTP', 'L', 'P')
    rtp = ""
    for i in 0..1024
    rtp = getpathwithrtp.call(getrtppath.call(i))
    if rtp != ""
      break
      end
    end
    rtp = "." if rtp == ""
  return searchaudiofileextensionrtp(file,rtp)
  end
end
else
  return file
end
  def self.searchaudiofileextensionrtp(file,rtp)
file = rtp + "\\" + file
    if FileTest.exist?(file) == false
ext = ['AIFF', 'ASF', 'ASX', 'DLS', 'FLAC', 'FSB', 'IT', 'M3U', 'MID', 'MOD', 'MP2', 'MP3', 'OGG', 'PLS', 'RAW', 'S3M', 'VAG', 'WAV', 'WAX', 'WMA', 'XM', 'XMA']
suc = false
for i in 0..ext.size - 1
  if FileTest.exist?(file + "." + ext[i])
    suc = true
    found = file + "." + ext[i]
    break
    end
end
if suc == true
  return found
else
  return utf8(file)
  end
end
else
  return file
  end
end
def play(voice,volume=100,pitch=100)
                        volume = volume.to_i
                        if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mid")
                          Audio.se_play("#{$soundthemepath}/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mid")
                          Audio.bgs_play("#{$soundthemepath}/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/SE/#{voice}.wav") or FileTest.exist?("Audio/SE/#{voice}.mp3") or FileTest.exist?("Audio/SE/#{voice}.ogg") or FileTest.exist?("Audio/SE/#{voice}.mid")
                          Audio.se_play("Audio/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/BGS/#{voice}.wav") or FileTest.exist?("Audio/BGS/#{voice}.mp3") or FileTest.exist?("Audio/BGS/#{voice}.ogg") or FileTest.exist?("Audio/BGS/#{voice}.mid")
                          Audio.bgs_play("Audio/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                      end
def hexspecial(t)
            t = t.gsub("ą","%C4%85")
            t = t.gsub("ć","%C4%87")
            t = t.gsub("ę","%C4%99")
            t = t.gsub("ł","%C5%82")
            t = t.gsub("ń","%C5%84")
            t = t.gsub("ó","%C3%B3")
            t = t.gsub("ś","%C5%9B")
            t = t.gsub("ź","%C5%BA")
            t = t.gsub("ż","%C5%BC")
            t = t.gsub("Ą","%C4%84")
            t = t.gsub("Ć","%C4%86")
            t = t.gsub("Ę","%C4%98")
            t = t.gsub("Ł","%C5%81")
            t = t.gsub("Ń","%C5%83")
            t = t.gsub("Ó","%C3%B2")
            t = t.gsub("Ś","%C5%9A")
            t = t.gsub("Ź","%C5%B9")
            t = t.gsub("Ż","%C5%BB")
            return t
          end
class String
  def delline(lines=1)
    self.gsub!("\004LINE\004","\r\n")    
    str = ""
foundlines = 1
    for i in 0..self.size - 1
      str += self[i..i]
      foundlines += 1 if self[i..i] == "\n"
    end
    fl = 0
    ret = ""
    for i in 0..str.size - 1
      fl += 1 if str[i..i] == "\r" or (str[i..i] == "\n" and str[i-1..i-1] != "\r")
      if foundlines - lines > fl
        ret += str[i..i]
        end
      end
      return ret.to_s
    end
    def strbyline
str = self
  byline = []
  index = 0
  byline[index] = ""
  for i in 0..str.size - 1
    if str[i..i] != "\n" and str[i..i] != "\r"
    byline[index] += str[i..i]
  elsif str[i..i] == "\n"
    index += 1
    byline[index] = ""
    end
  end
  return byline
end
def rdelete!(i)
    b = i[0]
  x = 0
  for i in 1..self.size
    if self[self.size - i] == b
      x += 1
    else
      break
    end
       end
  for i in 1..x
    chop!
    end
  end
  def maintext
    str = ""
    for i in 0..self.size - 1
            str += self[i..i]
            break if self[i+1..i+1] == "\003"
    end
    return str
  end
  def lore
    str = ""
    s = false
    for i in 0..self.size - 1
            str += self[i..i] if s == true
            s = true if self[i..i] == "\003"
    end
    return str
  end
  def b
    o = []
    for i in 0..self.size - 1
      o.push(" "[self[i]])
    end
    return o
    end
  def urlenc
    string = self+""
        r = string.gsub(/([^ a-zA-Z0-9_.-]+)/) do |m|
      '%' + m.unpack('H2' * m.size).join('%').upcase
    end.tr(' ', '+')
    return r
    end
  end
def loop_update
sleep(0.001)
end
  def futf8(text)
    mw = Win32API.new("kernel32", "MultiByteToWideChar", "ilpipi", "i")
    wm = Win32API.new("kernel32", "WideCharToMultiByte", "ilpipipp", "i")
    len = mw.call(0, 0, text, -1, nil, 0)
    buf = "\0" * (len*2)
    mw.call(0, 0, text, -1, buf, buf.bytesize/2)
    len = wm.call(65001, 0, buf, -1, nil, 0, nil, nil)
    ret = "\0" * len
    wm.call(65001, 0, buf, -1, ret, ret.bytesize, nil, nil)
    for i in 0..ret.bytesize - 1
      ret[i..i] = "\0" if ret[i] == 0
    end
    ret.delete!("\0")
    return ret
  end

def utf8(text)
  text = "" if text == nil or text == false
ext = "\0" if text == nil
to_char = Win32API.new("kernel32", "MultiByteToWideChar", 'ilpipi', 'i') 
to_byte = Win32API.new("kernel32", "WideCharToMultiByte", 'ilpipipp', 'i')
utf8 = 65001
w = to_char.call(utf8, 0, text.to_s, text.bytesize, nil, 0)
b = "\0" * (w*2)
w = to_char.call(utf8, 0, text.to_s, text.bytesize, b, b.bytesize/2)
w = to_byte.call(0, 0, b, b.bytesize/2, nil, 0, nil, nil)
b2 = "\0" * w
w = to_byte.call(0, 0, b, b.bytesize/2, b2, b2.bytesize, nil, nil)
return(b2)
  end
def download(source,destination)
  $downloadcount = 0 if $downloadcount == nil
  source.sub!("?","?eltc=#{$downloadcount.to_s(36)}\&")
source = hexspecial(source)
  $downloadcount += 1
    ef = 0
  begin
  ef = Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,source,destination,0,nil)
rescue Exception
  Graphics.update
  retry
end
  Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(source)
  if FileTest.exist?(destination) == false
    writefile(destination,-4)
    end
return ef
    end
def readini(file,group,key,default="\0")
        r = "\0" * 16384
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call(group,key,default,r,r.bytesize,file)
    r.delete!("\0")
    return r.to_s    
  end

def speech(text,method=1)
  text = text.to_s
    text = text.gsub("\004LINE\004") {"\r\n"}
  $trans1 = [] if $t1 == nil
  $trans2 = [] if $t2 == nil
  if $translation == true
    suc = false
    for i in 0..$trans1.bytesize - 1
      if $trans1[i] == text
        suc = true
        end
      end
      if suc == false
        std = $stdout
    $trans1.push(text)
    $trans2.push(text)
    std.reopen("trans","w")
    std.puts(text + "\003\004\005" + text)
    end
    end
  if text == " " and $password != true
    if $interface_soundthemeactivation != 0
  else
    speech("Spacja")
    end
    return
  end
  if text == "\n"
    return
  end
  if text.bytesize == 1
    if text[0] <= 90 and text[0] >= 65
      end
    end
  if $password == true
    speech_stop
    return
    end
  if text != ""
  text = char_dict(text)
  text = dict(text) if $language != "PL_PL" and $language != nil
  text = text.sub("_"," ")
  text.gsub!("\004NEW\004") {
  ""
  }
polecenie = "sapiSayString"
polecenie = "sayString" if $voice == -1
text_d = text
text_d = utf8(text) if $speech_to_utf == true
$speech_lasttext = text_d
Win32API.new("screenreaderapi",polecenie,'pi','i').call(text_d,method) if $password != true
end
text_d = text if text_d == nil
return text_d
end

def speech_actived
  polecenie = "sapiIsSpeaking"
  if $voice != -1
  if Win32API.new("screenreaderapi",polecenie,'v','i').call() == 0
    return(false)
  else
    return(true)
  end
else
  i = 0
  loop do
    i += 1
   Graphics.update
   Input.update
   key_update
   break if $key[0x11] or i > $speech_lasttext.bytesize * 10
 end
 return false
  end
  end
  
  def speech_stop
    polecenie = "sapiStopSpeech"
    polecenie = "stopSpeech" if $voice == -1
    Win32API.new("screenreaderapi",polecenie,'v','i').call()
    end

def speech_actived
  polecenie = "sapiIsSpeaking"
  if $voice != -1
  if Win32API.new("screenreaderapi",polecenie,'v','i').call() == 0
    return(false)
  else
    return(true)
  end
else
  i = 0
  loop do
    i += 1
   Graphics.update
   Input.update
   key_update
   break if $key[0x11] or i > $speech_lasttext.bytesize * 10
 end
 return false
  end
  end
  
  def speech_stop
    polecenie = "sapiStopSpeech"
    polecenie = "stopSpeech" if $voice == -1
    Win32API.new("screenreaderapi",polecenie,'v','i').call()
    end

def speech_wait
  while speech_actived == true
loop_update
  end
  return
end

def char_dict(text)
  r=""
  case text
  when "."
    r="kropka"
    when ","
      r="przecinek"
      when "/"
        r="ukośnik"
        when ";"
          r="średnik"
          when "'"
            r="apostrof"
            when "["
              r="lewy kwadratowy"
              when "]"
                r="prawy kwadratowy"
                when "\\"
                  r="bekslesz"
                  when "-"
                    r="minus"
                    when "="
                      r="równe"
                      when "`"
                        r="akcent"
                        when "<"
                          r="mniejsze"
                          when ">"
                            r="większe"
                            when "?"
                              r="pytajnik"
                              when ":"
                                r="dwukropek"
                                when "\""
                                  r="cudzysłów"
                                  when "{"
                                    r="lewa klamra"
                                    when "}"
                                      r="prawa klamra"
                                      when "|"
                                        r="kreska pionowa"
                                        when "_"
                                          r="podkreślnik"
                                          when "+"
                                            r="plus"
                                            when "!"
                                              r="wykrzyknik"
                                              when "@"
                                                r="małpa"
                                                when "#"
                                                  r="krzyżyk"
                                                  when "$"
                                                    r="dolar"
                                                    when "%"
                                                      r="procent"
                                                      when "^"
                                                        r="daszek"
                                                        when "\&"
                                                          r="ampersant"
                                                          when "*"
                                                            r="gwiazdka"
                                                            when "("
                                                              r="lewy nawias"
                                                              when ")"
                                                                r="prawy nawias"
                      end
                      if r==""
                        return(text)
                      else
                        return(r)
                        end
                      end

def dict(text)
  text = "" if text == nil
  if $lang_src != nil and $lang_dst != nil
for i in 3..$lang_src.bytesize - 1
  if $lang_src[i] == text
    r = $lang_dst[i]
    return(r)
    end
  end
end
for i in 3..$lang_dst.bytesize - 1
  suc = false
    $lang_dst[i].gsub("%%") {
  suc = true
  ""
  }
  if suc == true
    dst = $lang_dst[i].gsub("%","")
    src = $lang_src[i].gsub("%","")
  text.sub!(src,dst)
  end
end
text.gsub!("\r\r","  ")
  return(text)
end

class Reset < Exception

end

begin
$eltenlib = "eltenvc"
begin
$windowsversion = Win32API.new($eltenlib,"WindowsVersion",'v','i').call
rescue Exception
$eltenlib = "elten"
retry
end
$speech_to_utf = true
    $appdata = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("appdata",$appdata,$appdata.bytesize)
for i in 0..$appdata.bytesize - 1
$appdata = $appdata.sub("\0","")
end
$eltendata = $appdata + "\\elten"
$configdata = $eltendata + "\\config"
$bindata = $eltendata + "\\bin"
$langdata = $eltendata + "\\lng"
$soundthemesdata = $eltendata + "\\soundthemes"
$language = "\0" * 16
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Language","Language","PL_PL",$language,$language.bytesize,$configdata + "\\language.ini")
    $language.delete!("\0")
          $lang_src = []
      $lang_dst = []
    if $language != "PL_PL"
      $langwords = readlines($langdata + "\\" + $language + ".elg")
                          for i in 0..$langwords.size - 1
        $langwords[i].delete!("\n")
        $langwords[i].gsub!('\r\n',"\r\n")
        s = false
        $lang_src[i] = ""
        $lang_dst[i] = ""
        for j in 0..$langwords[i].size - 1
          if s == false
            if $langwords[i][j..j] != "|" and $langwords[i][j..j] != "\\"
            $lang_src[i] += $langwords[i][j..j]
          else
            s = true
          end
        else
          if $langwords[i][j..j] != "|" and $langwords[i][j..j] != "\\"
            $lang_dst[i] += $langwords[i][j..j]
            end
            end
          end
      end
end
$soundthemespath = "\0" * 64
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("SoundTheme","Path","",$soundthemespath,$soundthemespath.size,$configdata + "\\soundtheme.ini")
    $soundthemespath.delete!("\0")
    if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
cmd = $*.to_s
cmd.gsub("/wait") do
sleep(3)
end
$url = "https://elten-net.eu/"
Win32API.new("urlmon","URLDownloadToFile",'ppplp','i').call(nil,$url + "redirect","redirect",0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call($url + "redirect")
    if FileTest.exists?("redirect")
      rdr = IO.readlines("redirect")
      File.delete("redirect") if $DEBUG != true
      if rdr.size > 0
          if rdr[0].bytesize > 0
            $url = rdr[0].delete("\r\n")
            end
        end
      end
loop do
if FileTest.exists?("agent.tmp") == false and $omitinit != true
Win32API.new("user32","MessageBox",'ippi','i').call(0,"Cannot load Elten Agent Temporary File...","Fatal Error",16)
break
else
if $omitinit != true
ot = $token
agenttemp = IO.readlines("agent.tmp")
File.delete("agent.tmp")
$name = agenttemp[0].delete("\r\n")
$token = agenttemp[1].delete("\r\n")
$hwnd = agenttemp[2].delete("\r\n").to_i
$mes = 0
$pst = 0
$blg = 0
if $token != ot
download($url+"logout.php?name=#{$name}\&token=#{ot}","logouttemp")
File.delete("logouttemp") if FileTest.exists?("logouttemp")
end
end
$omitinit = false
loop do
$voice = readini($configdata + "\\sapi.ini","Sapi","Voice","0").to_i
Win32API.new("screenreaderapi","sapiSetVoice",'i','i').call($voice)
$rate = readini($configdata + "\\sapi.ini","Sapi","Rate","50").to_i
Win32API.new("screenreaderapi","sapiSetRate",'i','i').call($rate)
$soundthemespath = "\0" * 64
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("SoundTheme","Path","",$soundthemespath,$soundthemespath.size,$configdata + "\\soundtheme.ini")
    $soundthemespath.delete!("\0")
    if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
url = $url + "active.php?name=#{$name}\&token=#{$token}"
if download(url,"agentacttemp") == 0
if FileTest.exists?("agentacttemp")
File.delete("agentacttemp")
end
url = $url + "whatsnew.php?name=#{$name}\&token=#{$token}\&get=1"
if download(url,"agentwntemp") == 0
if FileTest.exists?("agentwntemp")
wntemp = IO.readlines("agentwntemp")
File.delete("agentwntemp")
if wntemp.size > 1
s = false
if wntemp[1].to_i > $mes
speech("Otrzymałeś nową wiadomość.") if $loaded == true
s = true
end
if wntemp[2].to_i > $pst
speech("W śledzonym wątku pojawił się nowy wpis.") if $loaded == true
s = true
end
if wntemp[3].to_i > $blg
speech("Na śledzonym blogu pojawił się nowy wpis.") if $loaded == true
s = true
end
play("new") if s == true
$loaded = true
$mes = wntemp[1].to_i
$pst = wntemp[2].to_i
$blg = wntemp[3].to_i
end
end
end
end
sleep(1)
IO.write("agent_output.tmp",$name+"\r\n"+$token+"\r\n"+$mes.to_s+"\r\n"+$pst.to_s+"\r\n"+$blg.to_s)
if FileTest.exists?("agent_exit.tmp") or Win32API.new("user32","IsWindow",'i','i').call($hwnd) == 0
puts("Exiting...")
File.delete("agent_exit.tmp") if FileTest.exists?("agent_exit.tmp")
$break = true
break
end
break if FileTest.exists?("agent.tmp")
end
end
if $break == true
download($url+"logout.php?name=#{$name}\&token=#{$token}","logouttemp")
File.delete("logouttemp") if FileTest.exists?("logouttemp")
break
end
File.delete("agent_err_out.txt")
end
#rescue LoadError
#retry
#rescue RuntimeError
#retry
end




# Elten Agent
#Copyright (2014-2016) Dawid Pieper
#All Rights Reserved