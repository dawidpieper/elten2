# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  private

  # EltenAPI functions

  # Reads an ini value
  #
  # @param file [String] a file to read
  # @param group [String] an INI group
  # @param key [String] an INI key
  # @param default [String] this string will be returned if the specified key or file doesn't exist
  # @return [String] the ini value of a specified key
  def readini(file, group, key, default = "\0")
    default = default.to_s if default.is_a?(Integer)
    r = "\0" * 16384
    sz = Win32API.new("kernel32", "GetPrivateProfileStringW", "pppplp", "i").call(unicode(group), unicode(key), unicode(default), r, r.size * 2, unicode(file))
    return deunicode(r[0...sz * 2])
  end

  # Writes a specified value to an INI file
  #
  # @param file [String] a file to write
  # @param group [String] an INI group to write
  # @param key [String] an INI key to write
  # @param value [String] a value to write
  def writeini(file, group, key, value)
    value.delete!("\r\n") if value.is_a?(String)
    if value != nil
      iniw = Win32API.new("kernel32", "WritePrivateProfileStringW", "pppp", "i")
      iniw.call(unicode(group), unicode(key), unicode(value.to_s), unicode(file))
    else
      iniw = Win32API.new("kernel32", "WritePrivateProfileStringW", "pppp", "i")
      iniw.call(unicode(group), unicode(key), nil, unicode(file))
    end
  end

  def unicode(str)
    return nil if str == nil
    str = str + "" if str.frozen?
    buf = "\0" * Win32API.new("kernel32", "MultiByteToWideChar", "iipipi", "i").call(65001, 0, str, str.bytesize, nil, 0) * 2
    @@multibytetowidechar ||= Win32API.new("kernel32", "MultiByteToWideChar", "iipipi", "i")
    @@multibytetowidechar.call(65001, 0, str, str.size, buf, buf.bytesize / 2)
    return buf << 0
  end

  def deunicode(str, nulled = false)
    return nil if str == nil
    str.chop! if str[-1..-1] == "\0" and (str.bytesize.to_i / 2 != str.bytesize.to_f / 2.0)
    str << "\0\0" if nulled and str[-2..-1] != "\0\0"
    sz = str.bytesize / 2
    sz = -1 if nulled
    buf = "\0" * Win32API.new("kernel32", "WideCharToMultiByte", "iipipipp", "i").call(65001, 0, str, sz, nil, 0, nil, nil)
    @@widechartomultibyte ||= Win32API.new("kernel32", "WideCharToMultiByte", "iipipipp", "i")
    @@widechartomultibyte.call(65001, 0, str, sz, buf, buf.size, nil, nil)
    return buf[0..(buf.index("\0") || 0) - 1]
  end

  def char_to_code(str)
    unicode(str).unpack("s").first
  end

  def code_to_char(code)
    deunicode([code].pack("s"))
  end

  # Returns an ASCII character of a specified code
  #
  # @param code [Numeric] an ASCII code
  # @return [String] an ASCII character of specified code
  def ASCII(code)
    r = "\0"
    r[0] = code.to_i
    return r
  end

  def format_date(date, justdate = false, secs = true)
    return "" if !date.is_a?(Time)
    str = sprintf("%04d-%02d-%02d", date.year, date.month, date.day)
    if !justdate
      str += sprintf(" %02d:%02d", date.hour, date.min)
      str += sprintf(":%02d", date.sec) if secs
    end
    return str
  end

  # Writes a specified text to a file
  #
  # @param file [String] a file name or path
  # @param text [String] a text to write
  # @return [Numeric] a number of written characters
  def writefile(file, text)
    if text.is_a?(Array)
      t = ""
      for i in text
        t += i + "\r\n"
      end
      text = t
    end
    cf = Win32API.new("kernel32", "CreateFileW", "piipiip", "i")
    handle = cf.call(unicode(file), 2, 1 | 2 | 4, nil, 2, 0, nil)
    writefile = Win32API.new("kernel32", "WriteFile", "ipipi", "I")
    bp = "\0" * text.size
    r = writefile.call(handle, text, text.size, bp, 0)
    bp = nil
    Win32API.new("kernel32", "CloseHandle", "i", "i").call(handle)
    handle = 0
    return r
  end

  # Runs a binary file
  #
  # @param file [String] a file to run
  # @param hide [Boolean] if true, the new process's window is hidden
  # @return [Numeric] the pid of a created process
  def run(file, hide = false, path = nil, addToProcs = true)
    Log.debug("Running process: #{file}")
    path = $path[0...$path.size - ($path.reverse.index("\\"))] if path == nil
    params = "LPLLLLLPPP"
    createprocess = Win32API.new("kernel32", "CreateProcessW", params, "I")
    env = 0
    env = "Windows".split(File::PATH_SEPARATOR) << nil
    env = env.pack("p*").unpack("L").first
    flags = 0
    startinfo = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x100, 0, 0, 0, 0, 0, 0]
    startinfo = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 | 0x100, 0, 0, 0, 0, 0, 0] if hide
    startinfo = startinfo.pack("LLLLLLLLLLLLSSLLLL")
    procinfo = [0, 0, 0, 0].pack("LLLL")
    pr = createprocess.call(0, unicode(file), 0, 0, 0, 0, 0, unicode(path), startinfo, procinfo)
    procinfo[0, 4].unpack("L").first # pid
    if addToProcs
      $procs = [] if $procs == nil
      $procs.push(procinfo.unpack("llll")[0])
    end
    return procinfo.unpack("llll")[0]
  end

  # Executes a process and waits for it to close
  #
  # @param cmdline [String] a command line to execute
  # @param hidewindow [Boolean] hide a process window
  # @param tmax [Numeric] maximum execution time, 0 = Infinity
  def executeprocess(cmdline, hide = false, tmax = 0, update = true, path = nil)
    h = run(cmdline, hide, path)
    t = 0
    loop do
      if update
        loop_update
      else
        sleep(0.1)
      end
      x = "\0" * 1024
      Win32API.new("kernel32", "GetExitCodeProcess", "ip", "i").call(h, x)
      x.delete!("\0")
      if x != "\003\001"
        break
      end
      t += 10.0 / Graphics.frame_rate
      if t > tmax and tmax != 0
        return -1
        break
      end
    end
    x = "\0" * 1024
    Win32API.new("kernel32", "GetExitCodeProcess", "ip", "i").call(h, x)
    x.delete!("\0")
    return x
  end

  # Reads a file
  #
  # @param file [String] a file to read
  # @return [String] a file text
  def readfile(file, limit = 0)
    createfile = Win32API.new("kernel32", "CreateFileW", "piipili", "l")
    handler = createfile.call(unicode(file), 1, 1 | 2 | 4, nil, 4, 0, 0)
    if handler < 64
      return nil
    end
    readfile = Win32API.new("kernel32", "ReadFile", "ipipp", "I")
    sz = "\0" * 8
    Win32API.new("kernel32", "GetFileSizeEx", "ip", "l").call(handler, sz)
    size = sz.unpack("L")[0]
    size = limit if limit > 0 && limit < size
    b = "\0" * (size.to_i)
    bp = "\0" * (size.to_i)
    handleref = readfile.call(handler, b, b.size, bp, nil)
    Win32API.new("kernel32", "CloseHandle", "i", "i").call(handler)
    handler = 0
    return b
  end

  class SpellCheckResult
    attr_accessor :index, :length
    attr_reader :suggestions

    def initialize
      @suggestions = []
    end
  end

  def spellcheck(language, text)
    return [] if text == ""
    unic = unicode(text)
    count = Win32API.new($eltenlib, "SpellCheck", "pppi", "i").call(unicode(language), unic, nil, 0)
    return [] if count <= 0
    count = 30 if count > 100
    res = ([0, 0, 0, 0] * count).pack("iiii" * count)
    r = Win32API.new($eltenlib, "SpellCheck", "pppi", "i").call(unicode(language), unic, res, count)
    return [] if r <= 0

    wcslen = Win32API.new("msvcrt", "wcslen", "i", "i")
    wcscpy = Win32API.new("msvcrt", "wcscpy", "pi", "i")
    movemem = Win32API.new("kernel32", "RtlMoveMemory", "pii", "i")

    results = []

    for i in 0...count
      rt = res[i * 16...i * 16 + 16].unpack("iiii")
      rtis = ([0] * rt[2]).pack("i" * rt[2])
      movemem.call(rtis, rt[3], rtis.size)
      result = SpellCheckResult.new
      index = deunicode(unic[0...(rt[0] * 2)]).size
      length = deunicode(unic[rt[0] * 2...(rt[0] + rt[1]) * 2]).size
      result.index = index
      result.length = length
      for s in rtis.unpack("i" * rt[2])
        len = wcslen.call(s)
        sug = "\0" * 2 * (len + 1)
        wcscpy.call(sug, s) if s != 0
        result.suggestions.push(deunicode(sug))
      end
      results.push(result)
    end
    Win32API.new($eltenlib, "SpellCheckFree", "pi", "i").call(res, count)
    return results
  end

  def spellchecklanguages
    count = Win32API.new($eltenlib, "SpellCheckLanguages", "pi", "i").call(nil, 0)
    return [] if count <= 0
    res = ([0] * count).pack("i" * count)
    r = Win32API.new($eltenlib, "SpellCheckLanguages", "pi", "i").call(res, count)
    return [] if r <= 0

    wcslen = Win32API.new("msvcrt", "wcslen", "i", "i")
    wcscpy = Win32API.new("msvcrt", "wcscpy", "pi", "i")

    results = []

    for i in 0...count
      s = res[i * 4...(i * 4 + 4)].unpack("i")[0]
      len = wcslen.call(s)
      ln = "\0" * 2 * (len + 1)
      wcscpy.call(ln, s)
      results.push(deunicode(ln))
    end
    Win32API.new($eltenlib, "SpellCheckLanguagesFree", "pi", "i").call(res, count)
    return results
  end

  # Wait for a specified time
  #
  # @param time [Float] a time to delay, in seconds
  def delay(time = 0)
    if time == 0
      if $ruby != true
        sec = Graphics.frame_rate
      else
        sec = 0.025
      end
      for i in 1..sec.to_f * 0.75
        Graphics.update
        break if !$key[0xd] and !$key[0x20] and i > 10
      end
      for i in 1..255
        $keyms[i] = 70
        $key[i] = false
      end
    else
      for i in 1..Graphics.frame_rate * time
        loop_update
      end
    end
  end

  def readconfig(group, key, val = "")
    r = readini(Dirs.eltendata + "\\elten.ini", group, key, "$DEFAULT")
    if r == "$DEFAULT"
      writeconfig(group, key, val)
      r = val
    end
    return r.to_i if val.is_a?(Integer)
    return r
  end

  def writeconfig(group, key, val)
    Log.debug("Changing configuration: (#{group}:#{key}): #{val.to_s}")
    val = val.to_s if val != nil
    writeini(Dirs.eltendata + "\\elten.ini", group, key, val)
  end

  module LocalConfig
    LCCache = {}
    LOCache = {}
    class << self
      def [](k, default = 0)
        return 0 if !k.is_a?(String)
        if LCCache[k] != nil
          return unformat(LCCache[k])
        else
          v = readconfig("Local", k, format(default))
          un = unformat(v)
          return default if default.class.name != un.class.name
          LCCache[k] = v
          LOCache[k] = v
          return un
        end
      end

      def unformat(t)
        if t.is_a?(Integer)
          return t
        elsif t[0..0] == "["
          return t[1...-1].split(",").map { |o| unformat(o) }
        else
          return t.to_i
        end
      end

      def format(t)
        if t.is_a?(Integer)
          return t.to_s
        elsif t.is_a?(Array)
          return "[" + t.find_all { |l| l.is_a?(Integer) }.join(",") + "]"
        end
      end

      def []=(k, v)
        return 0 if !k.is_a?(String) || (!v.is_a?(Integer) && !v.is_a?(Array))
        if v.is_a?(Array)
          v = "[" + v.find_all { |l| l.is_a?(Integer) }.join(",") + "]"
        end
        LCCache[k] = v
      end

      def save
        for k in LCCache.keys
          v = LCCache[k]
          writeconfig("local", k, v) if v != LOCache[k]
        end
      end
    end
  end

  # Calls a SHGetFilePath from shell32 library
  #
  # @param type [Numeric] a directory id
  # @return [String] directory path
  def getdirectory(type)
    dr = "\0" * 1040
    Win32API.new("shell32", "SHGetFolderPathW", "iiiip", "i").call(0, type, 0, 0, dr)
    fdr = deunicode(dr)
    return fdr
  end

  def insert_scene(scene, must = false)
    return if (($scenes[0] != nil and $scenes[0].is_a?(scene.class)) or $scene.is_a?(scene.class)) and !must
    if $scene.is_a?(Scene_Main) and $scenes.size == 0
      return $scene = scene
    end
    $subthreads ||= []
    $scenes ||= []
    Log.info("Inserting new parallel scenes thread #{($subthreads.size + $scenes.size + 1).to_s}")
    $scenes.insert(0, scene)
    t = Time.now.to_f
    loop_update(false) while Time.now.to_f - t < 0.2
  end

  def crypt(data, code = nil)
    pin = [data.size, data].pack("ip")
    pout = [0, nil].pack("ip")
    pcode = nil
    pcode = [code.size, code].pack("ip") if code != nil
    Win32API.new("crypt32", "CryptProtectData", "pppppip", "i").call(pin, nil, pcode, nil, nil, 0, pout)
    s, t = pout.unpack("ii")
    m = "\0" * s
    Win32API.new("kernel32", "RtlMoveMemory", "pii", "i").call(m, t, s)
    Win32API.new("kernel32", "LocalFree", "i", "i").call(t)
    return m
  end

  def decrypt(data, code = nil)
    pin = [data.size, data].pack("ip")
    pout = [0, nil].pack("ip")
    pcode = nil
    pcode = [code.size, code].pack("ip") if code != nil
    if Win32API.new("crypt32", "CryptUnprotectData", "pppppip", "i").call(pin, nil, pcode, nil, nil, 0, pout) > 0
      s, t = pout.unpack("ii")
      m = "\0" * s
      Win32API.new("kernel32", "RtlMoveMemory", "pii", "i").call(m, t, s)
      Win32API.new("kernel32", "LocalFree", "i", "i").call(t)
      m = nil if m == ""
      return m
    else
      Log.warning("Failed to decrypt data") if m == "" || m == nil
      return nil
    end
  end

  def bfs(mat, x, y, ox, oy)
    rowNum = [-1, 0, 0, 1]
    colNum = [0, -1, 1, 0]
    return nil if (mat[x][y] == false or mat[ox][oy] == false)
    visited = []
    for i in 0...mat.size
      visited[i] = []
      for j in 0...mat[i].size
        visited[i][j] = false
      end
    end
    visited[x][y] = true
    q = [[[x, y], []]]
    while !q.empty?
      curr = q[0]
      if (curr[0][0] == ox && curr[0][1] == oy)
        return curr[1]
      end
      q.delete_at(0)
      for i in 0...4
        row = curr[0][0] + rowNum[i]
        col = curr[0][1] + colNum[i]
        if row >= 0 && col >= 0 && row < mat.size && col < mat[row].size && mat[row][col] == true && !visited[row][col]
          visited[row][col] = true
          adjcell = [[row, col], curr[1] + [[row, col]]]
          q.push(adjcell)
        end
      end
    end
    return nil
  end

  class Reset < Exception
  end

  if $ruby == true
    module Input
      attr_reader :A
      attr_reader :B
      attr_reader :C
      attr_reader :UP
      attr_reader :DOWN
      attr_reader :LEFT
      attr_reader :RIGHT
      attr_reader :CTRL
      LEFT = 0x25
      UP = 0x26
      RIGHT = 0x27
      DOWN = 0x28
      class << self
        if $ruby == true
          def update
          end
        end

        def trigger?(x)
          return $key[x]
        end

        def repeat?(x)
          return $key[x]
          k = $keyr[x]
          k = false if $keyms[x] < 50
          k = true if $key[x]
          return k
        end
      end
    end
  end

  class ChildProc
    attr_reader :pid

    def initialize(file)
      @stdin_rd = "\0" * 4
      @stdin_wr = "\0" * 4
      @stdout_rd = "\0" * 4
      @stdout_wr = "\0" * 4
      @stderr_rd = "\0" * 4
      @stderr_wr = "\0" * 4
      saAttr = [12, nil, 1].pack("ipi")
      Win32API.new("kernel32", "CreatePipe", "pppi", "i").call(@stdout_rd, @stdout_wr, saAttr, 1048576 * 32)
      Win32API.new("kernel32", "SetHandleInformation", "iii", "i").call(@stdout_rd.unpack("i").first, 1, 0)
      Win32API.new("kernel32", "CreatePipe", "pppi", "i").call(@stderr_rd, @stderr_wr, saAttr, 1048576 * 32)
      Win32API.new("kernel32", "SetHandleInformation", "iii", "i").call(@stderr_rd.unpack("i").first, 1, 0)
      Win32API.new("kernel32", "CreatePipe", "pppi", "i").call(@stdin_rd, @stdin_wr, saAttr, 1048576 * 32)
      Win32API.new("kernel32", "SetHandleInformation", "iii", "i").call(@stdin_wr.unpack("i").first, 1, 0)
      params = "LPPPLLLPPP"
      createprocess = Win32API.new("kernel32", "CreateProcessW", params, "I")
      env = 0
      env = "Windows".split(File::PATH_SEPARATOR) << nil
      env = env.pack("p*").unpack("L").first

      si = [68, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 | 0x100, 0, 0, 0, @stdin_rd.unpack("I").first, @stdout_wr.unpack("I").first, @stderr_wr.unpack("I").first]
      startinfo = si.pack("IIIIIIIIIIIISSIIII")
      @procinfo = [0, 0, 0, 0].pack("LLLL")
      pr = createprocess.call(0, unicode(file), nil, nil, 1, 0, 0, unicode($path[0...$path.size - ($path.reverse.index("\\"))]), startinfo, @procinfo)
      @pid = @procinfo.unpack("LLLL").first
    end

    def running?
      x = "\0" * 4
      Win32API.new("kernel32", "GetExitCodeProcess", "ip", "i").call(@pid, x)
      return x[0..1] == "\003\001"
    end

    def terminate
      Win32API.new("kernel32", "TerminateProcess", "ip", "i").call(@pid, "")
    end

    def avail
      dread = [0].pack("I")
      dleft = [0].pack("I")
      dtotal = [0].pack("I")
      buf = ""
      @@peeknamedpipe ||= Win32API.new("kernel32", "PeekNamedPipe", "ipippp", "i")
      @@peeknamedpipe.call(@stdout_rd.unpack("I").first, buf, 0, dread, dtotal, dleft)
      return dtotal.unpack("I").first
    end

    def read(size = nil)
      size = avail if size == nil
      return "" if size == 0
      dread = [0].pack("i")
      buf = "\0" * size
      readfile = Win32API.new("kernel32", "ReadFile", "ipipp", "I")
      readfile.call(@stdout_rd.unpack("i").first, buf, size, dread, nil)
      return "" if dread.unpack("i").first == 0
      return buf[0..dread.unpack("i").first - 1]
    end

    def avail_err
      dread = [0].pack("I")
      dleft = [0].pack("I")
      dtotal = [0].pack("I")
      buf = ""
      @@peeknamedpipe ||= Win32API.new("kernel32", "PeekNamedPipe", "ipippp", "i")
      @@peeknamedpipe.call(@stderr_rd.unpack("I").first, buf, 0, dread, dtotal, dleft)
      return dtotal.unpack("I").first
    end

    def read_err(size = nil)
      size = avail_err if size == nil
      return "" if size == 0
      dread = [0].pack("i")
      buf = "\0" * size
      readfile = Win32API.new("kernel32", "ReadFile", "ipipp", "I")
      readfile.call(@stderr_rd.unpack("i").first, buf, size, dread, nil)
      return "" if dread.unpack("i").first == 0
      return buf[0..dread.unpack("i").first - 1]
    end

    def write(text)
      dwritten = [0].pack("i")
      writefile = Win32API.new("kernel32", "WriteFile", "ipipi", "I")
      writefile.call(@stdin_wr.unpack("i").first, text, text.bytesize, dwritten, 0)
    end

    def close
    end
  end

  class FileReader
    @@handlers = {}
    CreateFile = Win32API.new("kernel32", "CreateFileW", "piipiip", "i")
    ReadFile = Win32API.new("kernel32", "ReadFile", "ipipp", "I")
    CloseHandle = Win32API.new("kernel32", "CloseHandle", "i", "i")
    SetFilePointer = Win32API.new("kernel32", "SetFilePointer", "ilpi", "i")

    def initialize(file)
      ObjectSpace.define_finalizer(self,
                                   self.class.method(:finalize).to_proc)
      @file = file
      @handler = CreateFile.call(unicode(file), 1, 1, nil, 4, 0, 0)
      @@handlers[self.id] = @handler
    end

    def self.finalize(id)
      CloseHandle.call(@@handlers[id])
      @@handlers[id] = nil
    end

    def position
      phi = "\0" * 4
      lo = SetFilePointer.call(@handler, 0, phi, 1)
      return lo + phi.unpack("I").first * (2 ** 32)
    end

    def position=(pt)
      lo, hi = [pt].pack("q").unpack("iI")
      phi = [hi].pack("I")
      SetFilePointer.call(@handler, lo, phi, 0)
    end

    def read(size)
      buf = "\0" * size
      rd = [0].pack("i")
      ReadFile.call(@handler, buf, size, rd, nil)
      return buf[0...rd.unpack("I").first]
    end

    def close
      CloseHandle.call(@@handlers[self.id] || 0)
      @@handlers[self.id] = nil
    end
  end

  def load_configuration
    Log.info("Loading configuration")
    lang = Configuration.language
    Configuration.listtype = readconfig("Interface", "ListType", 0)
    Configuration.roundupforms = readconfig("Interface", "RoundUpForms", 0)
    Configuration.usepan = readconfig("Interface", "UsePan", 1)
    Configuration.soundcard = readconfig("SoundCard", "SoundCard", "")
    s = false
    sc = Bass.soundcards
    for i in 0...sc.size
      if sc[i] == Configuration.soundcard
        Bass.setdevice(i)
        s = true
      end
    end
    if Configuration.soundcard == ""
      Win32API.new($eltenlib, "SapiSetDevice", "i", "i").call(-1)
    else
      devices = listsapidevices
      for i in 0...devices.size
        if devices[i] == Configuration.soundcard
          Win32API.new($eltenlib, "SapiSetDevice", "i", "i").call(i)
        end
      end
    end
    Bass.setdevice(-1) if s == false
    Configuration.microphone = readconfig("SoundCard", "Microphone", "")
    s = false
    mc = Bass.microphones
    for i in 0...mc.size
      if mc[i] == Configuration.microphone
        Bass.setrecorddevice(i)
        s = true
      end
    end
    Bass.setrecorddevice(-1) if s == false
    Configuration.controlspresentation = readconfig("Interface", "ControlsPresentation", 0)
    Configuration.contextmenubar = readconfig("Interface", "ContextMenuBar", 1)
    Configuration.soundthemeactivation = readconfig("Interface", "SoundThemeActivation", 1)
    Configuration.typingecho = readconfig("Interface", "TypingEcho", 0)
    Configuration.bgsounds = readconfig("Interface", "BGSounds", 1)
    Configuration.linewrapping = readconfig("Interface", "LineWrapping", 1)
    Configuration.hidewindow = readconfig("Interface", "HideWindow", 0)
    Configuration.synctime = readconfig("Advanced", "SyncTime", 1)
    Configuration.registeractivity = readconfig("Privacy", "RegisterActivity", -1)
    Configuration.checkupdates = readconfig("Updates", "CheckAtStartup", 1)
    c_autostart = readconfig("System", "AutoStart", 0)
    autostart = false
    runkey = Win32::Registry::HKEY_CURRENT_USER.create("Software\\Microsoft\\Windows\\CurrentVersion\\Run")
    path = "\0" * 1025
    Win32API.new("kernel32", "GetModuleFileNameW", "ipi", "i").call(0, path, path.size / 2)
    path = deunicode(path)
    c_autostart = 0 if File.basename(path).downcase != "elten.exe"
    autostart_cmd = "\"#{File.dirname(path)}\\bin\\rubyw.exe\" -C\"#{File.dirname(path)}\\bin\" \"agent.dat\" /autostart"
    au = false
    begin
      autostart = (runkey["elten"] == autostart_cmd)
      au = true
    rescue Exception
      autostart = false
    end
    if autostart.to_i != c_autostart
      if c_autostart == 1
        runkey["elten"] = autostart_cmd
      else
        runkey.delete("elten")
      end
    elsif au == true && c_autostart == 0
      runkey.delete("elten")
    end
    runkey.close
    Configuration.voice = readconfig("Voice", "Voice", "")
    if $rvc == nil
      if (/\/voice (-?)(\d+)/ =~ $commandline) != nil
        $rvc = $1 + $2
        Configuration.voice = $rvc.to_s
      end
    end
    if Configuration.voice.to_i.to_s == Configuration.voice
      if Configuration.voice.to_i == -1
        Configuration.voice = "NVDA"
      elsif Configuration.voice.to_i >= 0
        voices = listsapivoices
        if Configuration.voice.to_i <= voices.size
          Configuration.voice = voices[Configuration.voice.to_i].voiceid
        else
          Configuration.voice = ""
        end
      else
        Configuration.voice = ""
      end
      writeconfig("Voice", "Voice", Configuration.voice)
    end
    Configuration.usebraille = readconfig("Interface", "UseBraille", 1)
    Configuration.language = readconfig("Interface", "Language", "")
    if Configuration.language.include?("_")
      Configuration.language.gsub!("_", "-")
      writeconfig("Interface", "Language", Configuration.language)
    end
    Configuration.voicerate = readconfig("Voice", "Rate", 50)
    if $rvcr == nil
      if (/\/voicerate (\d+)/ =~ $commandline) != nil
        $rvcr = $1
        Configuration.voicerate = $rvcr.to_i
      end
    end
    Win32API.new($eltenlib, "SapiSetRate", "i", "i").call(Configuration.voicerate)
    Configuration.voicevolume = readconfig("Voice", "Volume", 100)
    if $rvcv == nil
      if (/\/voicevolume (\d+)/ =~ $commandline) != nil
        $rvcv = $1
        Configuration.voicevolume = $rvcv.to_i
      end
    end
    Win32API.new($eltenlib, "SapiSetVolume", "i", "i").call(Configuration.voicevolume)
    Configuration.voicepitch = readconfig("Voice", "Pitch", 50)
    if Configuration.voice != "" && Configuration.voice != "NVDA"
      voices = listsapivoices
      for i in 0...voices.size
        if voices[i].voiceid == Configuration.voice
          Win32API.new($eltenlib, "SapiSetVoice", "i", "i").call(i)
        end
      end
    elsif Configuration.voice == ""
      lcid = Win32API.new("kernel32", "GetUserDefaultLCID", "", "i").call
      voices = listsapivoices
      for i in 0...voices.size
        if voices[i].language.to_i(16) == lcid
          Win32API.new($eltenlib, "SapiSetVoice", "i", "i").call(i)
          break
        end
      end
    end
    Configuration.soundtheme = readconfig("Interface", "SoundTheme", "")
    Configuration.soundtheme = nil if Configuration.soundtheme.size == 0
    stheme = nil
    stheme = Dirs.soundthemes + "\\" + Configuration.soundtheme + ".elsnd" if Configuration.soundtheme != nil
    use_soundtheme(stheme)
    Configuration.volume = readconfig("Interface", "MainVolume", 50)
    Configuration.usefx = readconfig("Advanced", "UseFX", -1)
    Configuration.usedenoising = readconfig("Advanced", "UseDenoising", 0)
    Configuration.useechocancellation = readconfig("Advanced", "UseEchoCancellation", 0)
    Configuration.autologin = readconfig("Login", "EnableAutoLogin", 1)
    setlocale(Configuration.language) if lang != Configuration.language
  end
end
