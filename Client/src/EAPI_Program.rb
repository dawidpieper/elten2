#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module Programs
  @@programs=[]
    @@bypaths={}
  @@pathindex=nil
  class <<self
    include EltenAPI
    def pathindexed?
      @@pathindex!=nil
      end
    def register(cls, obj=false)
      return if !cls.is_a?(Class)
      if @@pathindex!=nil
        EltenAPI::Log.debug("Registering class #{cls.to_s} to program #{@@pathindex}")
        @@bypaths[@@pathindex]||=[]
        @@bypaths[@@pathindex].push(cls)
      elsif obj==false
        EltenAPI::Log.warning("Registered program class without identification: #{cls}")
      end
      return if obj
      @@programs.push(cls)
    end
    def unregister(program)
      Log.debug("Unregistering program class #{program}")
      return if !program.is_a?(Class)
            @@programs.delete(program)
      Object.send(:remove_const, program.to_s.to_sym)
    end
    def delete(path)
      Log.info("deleting program #{path}")
      classes=[]
      if @@bypaths[path]==nil
      sf=Dirs.apps+"\\"+path+"\\__app.ini"
      return false if !FileTest.exists?(sf)
      suc=false
      name=readini(sf,"App","Name","")
      version=readini(sf,"App","Version","")
      author=readini(sf,"App","Author","")
      l=list
      l.each {|g|
      if g::Name==name and g::Version==version and g::Author==author
        classes.push(g)
        end
      }
    else
      classes=@@bypaths[path]
      @@bypaths[path]=nil
    end
    suc=false
    suc=true if classes.size>0
    classes.each {|c| unregister(c)}
      return suc
    end
    def delete_all
      Log.info("Flushing programs data")
      @@bypaths.keys.each{|k| delete(k)}
      c=@@programs.size
            unregister @@programs[0] while @@programs.size>0
      return c
      end
    def load_all
      Log.info("Loading programs")
          pgs=Dir.entries(Dirs.apps)
          pgs.delete(".")
          pgs.delete("..")
      for pg in pgs
load_sig(pg) if FileTest.exists?(Dirs.apps+"\\"+pg+"\\__app.ini")
        end
      end
      def load_sig(pg)
        Log.info("Loading program #{pg}")
                if FileTest.exists?(Dirs.apps+"\\"+pg+"\\__app.ini")
                  f=Dirs.apps+"\\"+pg+"\\__app.ini"
                    file=readini(f,"App","File","")
          if FileTest.exists?(Dirs.apps+"\\"+pg+"\\"+file)
            begin
            @@pathindex=pg
            t=Thread.new {
            begin
            load(Dirs.apps+"\\"+pg+"\\"+file)
          rescue Exception
            Log.error("Failed to initialize #{pg}: #{$!.to_s}, #{$@.to_s}")
            end
            }
            if $mainthread==Thread::current
                                        delay(0.1)
              else
                sleep(0.1)
              end
              if @@bypaths[@@pathindex]==nil or (t.status!=false&&t.status!=nil)
                t.kill if t.status!=false&&t.status!=nil
                Log.error("Cannot load #{pg}, timeout")
                end
            rescue Exception
              Log.error("Failed to load program #{pg}: "+$!.to_s+", "+$@.to_s)
            end
                          @@pathindex=nil
            end
          end
        end
      def list
        return @@programs
        end
  end
  end

class Program
  public
  Name=""
  Version="0.0"
  Author=nil
    UserMenuOptions={}
    MainMenuOption=nil
    AppID=0
      def finish(v=nil)
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
  def exit(v=0)
    finish(v)
  end
  protected
  def appsignature
    return (self.class::Name)+"\r\n"+(self.class::Version)+"\r\n"+(self.class::Author)
    end
  def appfile(file="")
    c=(self.class::Name).delete("()")
    basename=Dirs.apps+"\\"+c.delspecial
    filename=""
    i=0
    loop {
    dname=basename+""
    dname+="("+i.to_s+")" if i>0
    if File.directory?(dname) and FileTest.exists?(dname+"\\__app.ini")
      f=dname+"\\__app.ini"
      name=readini(f,"App","Name","")
      author=readini(f,"App","Author","")
      version=readini(f,"App","Version","")
      if name.downcase==self.class::Name.downcase and author.downcase==self.class::Author.downcase and version.downcase==self.class::Version.downcase
        filename=dname+"\\"+file
        break
      end
    else
      createdirifneeded(dname)
      f=dname+"\\__app.ini"
      writeini(f,"App","Name",self.class::Name)
      writeini(f,"App","Author",self.class::Author)
      writeini(f,"App","Version",self.class::Version)
      filename=dname+"\\"+file
      break
    end
    i+=1
    }
    return filename
  end
  def signaled(user, packet)
    end
  def signal(user, packet)
    fail(ArgumentError, "Not JSON-convertable value") if !packet.is_a?(String) and !packet.is_a?(Array) and !packet.is_a?(Hash) and packet!=nil and packet!=false and packet!=true and !packet.is_a?(Integer)
    fail(ArgumentError, "user must be a string") if !user.is_a?(String)
    appid=self.class::AppID
    fail(RuntimeError, "AppID not set") if appid==0 or !appid.is_a?(Integer)
    pc=JSON.generate(packet)
    r=srvproc("apps_signal", {"ac"=>"create", "appid"=>appid, "buf"=>buffer(pc), "user"=>user})
    return r[0].to_i==0
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
      $usermenuextra={} if $usermenuextra==nil
      for key in cls::UserMenuOptions.keys
            $usermenuextra[key]=[cls]+((cls::UserMenuOptions[key])||[])
            end
          end
              rescue Exception
                EltenAPI::Log.error("Error loading program #{cls.to_s}: #{$!.to_s}, #{$@.to_s}")
                end
                }
  end
end

class Object
  class <<self
  alias proselinh inherited
  def inherited(cls, *p)
    Programs.register(cls,true) if Programs.pathindexed?
      proselinh(cls, *p)
    end
  end
end