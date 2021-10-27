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
  @@configs = {}

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
        sups = []
        c = cls
        while c != Object
          c = c.superclass
          sups.push(c)
        end
        if sups.include?(Program)
          config = @@configs[@@pathindex]
          cls.const_set("Name", config[:name]) if cls.const_get("Name") == "" && config[:name] != nil
          cls.const_set("Version", config[:version]) if cls.const_get("Version") == "0.0" && config[:version] != nil
          cls.const_set("Author", config[:author]) if cls.const_get("Author") == "" && config[:author] != nil
        end
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
        name, version, author = get(path)
        return false if name == nil || author == nil || version == nil
        suc = false
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
        load_sig(pg) if FileTest.exists?(Dirs.apps + "\\" + pg + "\\__app.ini") || FileTest.exists?(Dirs.apps + "\\" + pg + "\\__app.rb")
      end
    end

    def load_sig(pg)
      Log.info("Loading program #{pg}")
      name, author, version, file = get_conf(pg)
      if name != nil && version != nil && author != nil && file != nil
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

    def get_conf(path)
      name = version = author = file = nil
      sf = Dirs.apps + "\\" + path + "\\__app.ini"
      sfb = Dirs.apps + "\\" + path + "\\__app.rb"
      if FileTest.exists?(sf)
        name = readini(sf, "App", "Name", "")
        version = readini(sf, "App", "Version", "")
        author = readini(sf, "App", "Author", "")
        file = readini(sf, "App", "File", "")
      elsif FileTest.exists?(sfb)
        code = readfile(sfb)
        config = {}
        if (/^\=begin[ \t]+EltenAppInfo[\s]*(.+)^\=end[ \t]+EltenAppInfo[\s]*$/m =~ code) != nil
          re = $1.gsub("\r\n", "\n")
          lines = re.split("\n")
          for line in lines
            next if !line.include?("=")
            ind = line.index("=")
            key, val = line[0...ind], line[ind + 1..-1]
            key.delete!(" \t")
            val = val[1..-1] while val[0..0] == " " || val[0..0] == "\t"
            val = val[0...-1] while val[-1..-1] == " " || val[-1..-1] == "\t"
            config[key.downcase] = val
          end
        end
        name = config["name"]
        version = config["version"]
        author = config["author"]
        file = "__app.rb"
      end
      @@configs[path] = { :name => name, :author => author, :version => version, :file => file }
      return name, version, author, file
    end

    def configs
      @@configs.dup
    end
  end
end

class Program
  public

  Name = ""
  Version = "0.0"
  Author = ""
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

  def app_file(file = "")
    self.class.app_file(file)
  end

  alias appfile app_file
  def self.app_file(nfile = "")
    dirs = Dir.entries(Dirs.apps)
    dirs.delete(".")
    dirs.delete("..")
    for d in dirs
      name, version, author, file = Programs.get_conf(d)
      if name != nil && version != nil && author != nil && file != nil
        if name.downcase == self::Name.downcase and author.downcase == self::Author.downcase and version.downcase == self::Version.downcase
          return Dirs.apps + "\\" + d + "\\" + nfile
          break
        end
      end
    end
    return nfile
  end
  def self.appfile(*arg); app_file(*arg); end

  def signaled(user, packet)
  end

  def signal(user, packet)
    fail(ArgumentError, "Not JSON-convertable value") if !packet.is_a?(String) and !packet.is_a?(Array) and !packet.is_a?(Hash) and packet != nil and packet != false and packet != true and !packet.is_a?(Integer)
    fail(ArgumentError, "user must be a string") if !user.is_a?(String)
    appid = self.class::AppID
    fail(RuntimeError, "AppID not set") if appid == 0 or !appid.is_a?(Integer)
    pc = JSON.generate(packet)
    r = srvproc("apps_signal", { "ac" => "create", "appid" => appid, "user" => user }, 0, { "packet" => pc })
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
