# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2024 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Object
  include EltenAPI
end

module Elten
  Version = 2.523
  Beta = 0
  Alpha = 0
  IsBeta = 0
  BuildID = 20240120001
  BuildDate = 1705787699
  class << self
    def version
      return Version
    end

    def beta
      return Beta
    end

    def alpha
      return Alpha
    end

    def rc
      return Alpha
    end

    def isbeta
      return IsBeta
    end

    def fullversion
      txt = "ELTEN #{Version.to_s.delete(".").split("").join(".")}"
      txt += " BETA #{Beta.to_s}" if IsBeta == 1
      txt += " RC #{Alpha.to_s}" if IsBeta == 2
      return txt
    end

    def build_id
      return BuildID
    end

    def build_date
      t = Time.at(BuildDate)
      return sprintf("%04d-%02d-%02d %02d:%02d", t.year, t.month, t.day, t.hour, t.min)
    end

    def branch
      case isbeta
      when 0
        return "stable"
      when 1
        return "beta"
      when 2
        return "rc"
      end
    end
  end
end

begin
  $commandline = Win32API.new("kernel32", "GetCommandLine", "", "p").call.to_s
  if (/\/datadir \"([a-zA-Z0-9\\:\/ ]+)\"/ =~ $commandline) != nil
    $reld = $1
    Dirs.eltendata = $reld
  end
  clo = false
  cf = Win32API.new("kernel32", "CreateFileW", "piipiii", "i")
  path = Dirs.eltendata + "\\elten.pid"
  createdirifneeded(Dirs.eltendata)
  $pidfile = cf.call(unicode(path), 0x80000000 | 0x40000000, 0, nil, 2, 256 | 0x4000000, 0)
  if $pidfile > 0
    wr = Win32API.new("kernel32", "WriteFile", "ipipi", "I")
    bp = [0].pack("l")
    tx = Win32API.new("kernel32", "GetCurrentProcessId", "", "i").call.to_s
    wr.call($pidfile, tx, tx.size, bp, 0)
  else
    Win32API.new("kernel32", "CloseHandle", "i", "i").call($pidfile)
    writefile(Dirs.eltendata + "\\!show.dat", "!")
    exit
  end
end

begin
  Log.head("Starting Elten")
  Log.head("Version: #{Elten.version.to_s}")
  Log.head("Beta: #{Elten.beta.to_s}") if Elten.isbeta == 1
  if $ruby != true
    Graphics.freeze
    Graphics.update
    Configuration.volume = 50 if Configuration.volume == nil
    $mainthread = Thread::current
    $currentthread = $mainthread
  end
  $LOAD_PATH << "."
end
begin
  #main
  # Make scene object (title screen)
  if $toscene != true
    $scene = Scene_Loading.new if $tomain == nil and $updating != true and $downloading != true
    $scene = Scene_Main.new if $tomain == true
    $scene = Scene_Update.new if $updating == true
    $scene = $scene if $downloading == true
  end
  $toscene = false
  # Call main method as long as $scene is effective
  loop do
    $scene = Scene_Loading.new if $restart == true
    if $scene != nil and $exit != true
      $notifications_callback = nil
      Log.debug("Loading scene: #{$scene.class.to_s}")
      $scene.main
    else
      break
    end
  end
  if $immediateexit != true
    play("logout")
    register_activity if Configuration.registeractivity == 1
    delay(1)
    speech_wait
    $exit = true
    if $exitupdate == true
      if $exitupdate_donotsilent != true
        writefile(Dirs.eltendata + "\\update.last", Zlib::Deflate.deflate([$version.to_s, $beta.to_s, $alpha.to_s, $isbeta.to_s].join(" ")))
        writefile(Dirs.eltendata + "\\bin\\Data\\update.last", Marshal.dump(Time.now.to_f))
        $exit_runproc = "\"#{Dirs.eltendata}\\eltenup.exe\" /tasks=\"\" /silent"
      else
        $exit_runproc = "\"#{Dirs.eltendata}\\eltenup.exe\""
      end
    elsif $exitreinstall == true
      copydir(".", Dirs.temp + "\\elten_setup")
      deldir("#{Dirs.temp}\\elten_setup\\eltendata")
      $exitdonotclean = true
      $exit_runproc = "\"#{Dirs.temp}\\elten_setup\\bin\\elten_portablesetup.exe\""
    end
  end
rescue Hangup
  Graphics.update if $ruby != true
  $toscene = true
  retry
rescue Reset
  key_update
  $DEBUG = true if $key[0x10]
  play("signal") if $key[0x10]
  retry
rescue SystemExit
  if $immediateexit != true
    loop_update
    quit if $keyr[0x73]
    play("listbox_focus") if $exit == nil
    $toscene = true
    retry if $exit == nil
  end
rescue Exception
  Log.error($!.class.name + ": " + $!.message + " - " + $@.to_s)
  Log.error("Critical exception occurred, terminating!")
  fail
ensure
  if $immediateexit != true
    NVDA.join
    NVDA.destroy
    Win32API.new("kernel32", "TerminateProcess", "ip", "i").call($agent.pid, "") if $agent != nil
    $agent = nil
    LocalConfig.save
    FileCache.get_caches.each { |a| a.save }
    Log.debug("Closing processes")
    if $procs != nil
      for o in $procs
        Win32API.new("kernel32", "TerminateProcess", "ip", "i").call(o, "")
      end
    end
    if $exitdonotclean != true && Dirs.temp != nil
      Log.info("Cleaning up temporary files")
      deldir(Dirs.temp)
    end
    Log.info("Exiting Elten")
    Win32API.new($eltenlib, "hideTray", "", "i").call if $eltenlib != nil
    if $exit_runproc != nil
      Log.debug("Starting queued Processes")
      run($exit_runproc, false, nil, false)
      Win32API.new("kernel32", "ExitProcess", "i", "i").call(0)
    end
  end
end; begin
rescue Exception
  if $ruby != true
    if $updating != true and $start != nil and $downloading != true
      speech("Critical error occurred: " + $!.message)
      speech_wait
      sleep(0.5)
      speech("Do you want to send the errror report?")
      speech_wait
      if selector(["No", "Yes"]) == 1
        sleep(0.15)
        bug
      end
      sel = ListBox.new(["Copy error report to clipboard", "Restart", "Try again", "Rescue mode", "Abort"], "What to do?", 0, ListBox::Flags::AnyDir, false)
      loop do
        loop_update
        sel.update
        if enter
          if sel.index > 0
            break
          else
            msg = $!.to_s + "\r\n" + $@.to_s
            Clipboard.text = msg
            speech("Copied to clipboard")
          end
        end
      end
      case sel.index
      when 1
        $toscene = false
        retry
      when 2
        $toscene = true
        retry
      when 3
        speech("Rescue mode")
        speech_wait
        @sels = ["Quit", "Reinstall"]
        @sels += ["Try to open forum", "Try to open messages"] if Session.name != nil and Session.name != ""
        @sel = ListBox.new(@sels, "", 0, ListBox::Flags::AnyDir, false)
        loop do
          loop_update
          @sel.update
          if enter
            break
          end
        end
        case @sel.index
        when 0
          fail
        when 1
          $scene = Scene_Update.new
          $toscene = true
          retry
        when 2
          insert_scene($scene) if $scenes != nil
          $scene = Scene_Forum.new
          $toscene = true
          retry
        when 3
          insert_scene($scene) if $scenes != nil
          $scene = Scene_Messages.new
          $toscene = true
          retry
        end
      when 4
        fail if $DEBUG == true
      end
    end
    if $updating == true
      retry
    end
    if $start == nil
      retry
    end
  else
    fail
  end
end
