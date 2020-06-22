#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

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
$bgm = Bass::Sound.new(file,1,true)
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
    if $bgm != nil and !$bgm.closed
      $bgm.close
      $bgm = nil
      return true
    end
    return false
  end
  def self.bgm_fade(time=1000)
    return if $bgm==nil or $bgm.closed
    Thread.new do
      t = time
                    pr = ($bgm.volume.to_f / 100.to_f).to_f
        w = (t.to_f / 100.to_f / 1000.to_f).to_f
      for i in 1..100
        if $bgm != nil
        sleep(w)
        break if $bgm==nil or $bgm.closed
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
$bgs = Bass::Sound.new(file,1,true)
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
        if $bgs != nil and !$bgs.closed
      $bgs.close
      $bgs = nil
      return true
    end
    return false
  end
    def self.bgs_fade(time=1000)
      return if $bgs==nil or $bgs.closed
    Thread.new do
      t = time
              pr = ($bgs.volume.to_f / 100.to_f).to_f
        w = (t.to_f / 100.to_f / 1000.to_f).to_f
      for i in 1..100
        if $bgs != nil
        sleep(w)
        break if $bgs==nil or $bgs.closed
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
$me.push(Bass::Sound.new(file,0))
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
$se.push(Bass::Sound.new(file,1))
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
    lib = "RGSS104E.dll"
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
else
  return file
end
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
  return file
  end
end
  end
end

Audio_OLD = Audio if $ruby != true
Audio = Audio_FMOD if $ruby == true