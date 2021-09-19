# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module Programs
  @@programs = []
  @@bypaths = {}
  @@pathindex = nil
  @@listeners = []

  class EventListener
    attr_accessor :event, :cls, :proc

    def call
      proc.call if proc.is_a?(Proc)
    end
  end

  class << self
    include EltenAPI

    def pathindexed?
      @@pathindex != nil
    end

    def register(cls, obj = false)
      return if !cls.is_a?(Class)
      if @@pathindex != nil
        EltenAPI::Log.debug("Registering class #{cls.to_s} to program #{@@pathindex}")
        @@bypaths[@@pathindex] ||= []
        @@bypaths[@@pathindex].push(cls)
      elsif obj == false
        EltenAPI::Log.warning("Registered program class without identification: #{cls}")
      end
      return if obj
      @@programs.push(cls)
    end

    def unregister(program)
      i = 0
      while i < @@listeners.size
        if @@listeners[i].cls == program
          @@listeners.delete_at(i)
        else
          i += 1
        end
      end
      Log.debug("Unregistering program class #{program}")
      return if !program.is_a?(Class)
      @@programs.delete(program)
      MediaFinders.unregister(program) if MediaFinders.list.include?(program)
      MediaEncoders.unregister(program) if MediaEncoders.list.include?(program)
      EditBox.unregister_class(program)
      begin
        Object.send(:remove_const, program.name.to_sym)
      rescue Exception
      end
    end

    def delete(path)
      Log.info("deleting program #{path}")
      classes = []
      if @@bypaths[path] == nil
        sf = Dirs.apps + "\\" + path + "\\__app.ini"
        return false if !FileTest.exists?(sf)
        suc = false
        name = readini(sf, "App", "Name", "")
        version = readini(sf, "App", "Version", "")
        author = readini(sf, "App", "Author", "")
        l = list
        l.each { |g|
          if g::Name == name and g::Version == version and g::Author == author
            classes.push(g)
          end
        }
      else
        classes = @@bypaths[path]
        @@bypaths[path] = nil
      end
      suc = false
      suc = true if classes.size > 0
      classes.each { |c| unregister(c) }
      return suc
    end

    def delete_all
      Log.info("Flushing programs data")
      @@bypaths.keys.each { |k| delete(k) }
      c = @@programs.size
      unregister @@programs[0] while @@programs.size > 0
      return c
    end

    def load_all
      Log.info("Loading programs")
      pgs = Dir.entries(Dirs.apps)
      pgs.delete(".")
      pgs.delete("..")
      for pg in pgs
        load_sig(pg) if FileTest.exists?(Dirs.apps + "\\" + pg + "\\__app.ini")
      end
    end

    def load_sig(pg)
      Log.info("Loading program #{pg}")
      if FileTest.exists?(Dirs.apps + "\\" + pg + "\\__app.ini")
        f = Dirs.apps + "\\" + pg + "\\__app.ini"
        file = readini(f, "App", "File", "")
        if FileTest.exists?(Dirs.apps + "\\" + pg + "\\" + file)
          begin
            @@pathindex = pg
            t = Thread.new {
              begin
                load(Dirs.apps + "\\" + pg + "\\" + file)
              rescue Exception
                Log.error("Failed to initialize #{pg}: #{$!.to_s}, #{$@.to_s}")
              end
            }
            if $mainthread == Thread::current
              delay(0.1)
            else
              sleep(0.1)
            end
            if @@bypaths[@@pathindex] == nil or (t.status != false && t.status != nil)
              t.kill if t.status != false && t.status != nil
              Log.error("Cannot load #{pg}, timeout")
            end
          rescue Exception
            Log.error("Failed to load program #{pg}: " + $!.to_s + ", " + $@.to_s)
          end
          @@pathindex = nil
        end
      end
    end

    def list
      return @@programs
    end

    def register_event_listener(event, cls, proc)
      l = EventListener.new
      l.event = event
      l.cls = cls
      l.proc = proc
      @@listeners.push(l)
    end

    def emit_event(event)
      for l in @@listeners
        l.call if l.event == event
      end
    end
  end
end

class Program
  public

  Name = ""
  Version = "0.0"
  Author = nil
  UserMenuOptions = {}
  MainMenuOption = nil
  AppID = 0
  NoMenuItem = false

  def finish(v = nil)
    close
    Log.info("Program exited #{self.class.to_s}")
    alert(p_("Program", "The program has been closed."))
    $scene = Scene_Main.new
    return(v)
  end

  def close
  end

  def self.init
  end

  def on(event, &proc)
    self.class.on(:event, &proc)
  end

  def self.on(event, &proc)
    Programs.register_event_listener(event, self, proc)
  end

  def register_quickaction(ident, &proc)
    self.class.register_quickaction(ident, label, &proc)
  end

  def self.register_quickaction(ident, label, &proc)
    QuickActions.register_proc(self, ident, label, proc)
  end

  def exit(v = 0)
    finish(v)
  end

  protected

  def appsignature
    return (self.class::Name) + "\r\n" + (self.class::Version) + "\r\n" + (self.class::Author)
  end

  def appfile(file = "")
    self.class.appfile(file)
  end

  def self.appfile(file = "")
    filename = file
    dirs = Dir.entries(Dirs.apps)
    dirs.delete(".")
    dirs.delete("..")
    for d in dirs
      dir = Dirs.apps + "\\" + d
      if File.directory?(dir) and FileTest.exists?(dir + "\\__app.ini")
        f = dir + "\\__app.ini"
        name = readini(f, "App", "Name", "")
        author = readini(f, "App", "Author", "")
        version = readini(f, "App", "Version", "")
        if name.downcase == self::Name.downcase and author.downcase == self::Author.downcase and version.downcase == self::Version.downcase
          filename = dir + "\\" + file
          break
        end
      end
    end
    return filename
  end

  def signaled(user, packet)
  end

  def signal(user, packet)
    fail(ArgumentError, "Not JSON-convertable value") if !packet.is_a?(String) and !packet.is_a?(Array) and !packet.is_a?(Hash) and packet != nil and packet != false and packet != true and !packet.is_a?(Integer)
    fail(ArgumentError, "user must be a string") if !user.is_a?(String)
    appid = self.class::AppID
    fail(RuntimeError, "AppID not set") if appid == 0 or !appid.is_a?(Integer)
    pc = JSON.generate(packet)
    r = srvproc("apps_signal", { "ac" => "create", "appid" => appid, "buf" => buffer(pc), "user" => user })
    return r[0].to_i == 0
  end

  private

  def self.inherited(cls)
    EltenAPI::Log.debug("Registered new program class #{cls.name}")
    Programs.register(cls)
    Thread.new {
      begin
        sleep(0.1)
        cls.init
        if cls::UserMenuOptions.is_a?(Hash)
          $usermenuextra = {} if $usermenuextra == nil
          for key in cls::UserMenuOptions.keys
            $usermenuextra[key] = [cls] + ((cls::UserMenuOptions[key]) || [])
          end
        end
      rescue Exception
        EltenAPI::Log.error("Error loading program #{cls.to_s}: #{$!.to_s}, #{$@.to_s}")
      end
    }
  end
end

class Object
  class << self
    alias proselinh inherited

    def inherited(cls, *p)
      Programs.register(cls, true) if Programs.pathindexed?
      proselinh(cls, *p)
    end
  end
end

class EltenApp
  attr_reader :file

  class EltenAppChunk
    attr_reader :type, :name, :start, :size, :compressed

    def initialize(type, name, start, size, compressed)
      @type, @name, @start, @size, @compressed = type, name, start, size, compressed
    end
  end

  def initialize(file)
    @file = file
    @reader = FileReader.new(file)
    if @reader.size < 8 + 1024 || @reader.read(8) != "EltenAPP"
      raise(ArgumentException, "Wrong file format")
    end
    @reader.position += 1024
    @chunks = []
    while @reader.position < @reader.size
      type = @reader.read(8)
      flags = @reader.read(1)
      compressed = false
      compressed = true if (flags & 1) > 0
      sz = @reader.read(1).unpack("C").first
      name = @reader.read(sz)
      size = @reader.read(8).unpack("Q").first
      start = @reader.position
      @chunks.push EltenAppChunk.new(type, name, start, size, compressed)
      @reader.position += size
    end
  end

  def get_chunk_content(ch)
    @reader.position = ch.start
    cnt = @reader.read(ch.size)
    cnt = Zlib::Inflate.inflate(cnt) if ch.compressed
    return cnt
  end

  def manifest
    chunk = @chunks.find { |c| c.type == "MANIFEST" }
    return nil if chunk == nil
    return JSON.load(get_chunk_content(chunk))
  end

  def name
    m = manifest
    return nil if m == nil || !m.is_a?(Hash) || !m["name"].is_a?(String)
    m["name"]
  end

  def version
    m = manifest
    return nil if m == nil || !m.is_a?(Hash) || !m["version"].is_a?(String)
    m["version"]
  end

  def author
    m = manifest
    return nil if m == nil || !m.is_a?(Hash) || !m["author"].is_a?(String)
    m["author"]
  end
end
