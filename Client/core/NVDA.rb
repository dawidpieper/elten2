#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module NVDA
  CreateNamedPipe=Win32API.new("kernel32", "CreateNamedPipe", 'piiiiiip', 'i')
  CloseHandle = Win32API.new("kernel32", "CloseHandle", 'i', 'i')
  WriteFile = Win32API.new("kernel32","WriteFile",'ipipi','I')
PeekNamedPipe=Win32API.new("kernel32","PeekNamedPipe",'ipippp','i')  
      ReadFile = Win32API.new("kernel32","ReadFile",'ipipp','I')
  class <<self
    def init
      @waiting=0
                  @lastwrite=""
      @checked=nil
      @prepared=false
      if @initialized==true
        CloseHandle.call(@pipein)
        CloseHandle.call(@pipeout)
        @pipein=nil
        @pipeout=nil
        @pipethread.exit
        @pipethread=nil
        end
      @initialized=true
      @pipename="elten"+rand(36**48).to_s(36)
      @pipein=CreateNamedPipe.call("\\\\.\\pipe\\"+@pipename+"in", 1, 8, 1, 1048576, 1048576, 1, nil) while @pipein==nil||@pipein==-1
      @pipeout=CreateNamedPipe.call("\\\\.\\pipe\\"+@pipename+"out", 2, 8, 1, 1048576, 1048576, 1, nil) while @pipeout==nil||@pipeout==-1
                  writefile($tempdir+"\\nvda.pipe", @pipename)
                  Log.debug("NVDA pipes registered: #{@pipein.to_s}, #{@pipeout.to_s}")
                                    @writes||=[]
                                    @reads||={}
      @pipethread=Thread.new {
      sleep(0.2)
      @prepared=true
      pid = Win32API.new("kernel32", "GetCurrentProcessId", '', 'i').call
      Thread.new {
            write({'ac'=>'init', 'pid'=>pid},false,1)
        }
      begin
      dwritten=[0].pack("i")
      loop {
            while @writes.size>0 and @pipeout!=nil
              w=JSON.generate(@writes.first)+"\n"
                                  WriteFile.call(@pipeout, w, w.bytesize, dwritten, 0)
                                  @writes.delete_at(0)
        end
        if @pipein!=nil and (lv=avail)>0
                    r=read(lv)
                    while r[-1..-1]!="\n"
                      sleep(0.001)
                      r+=read(avail)
                      end
                      b=r.split("\n")
                      for l in b
              j=JSON.load(l)
              @reads[j['id']]=j
            end
          else
                        end
            sleep(0.001)
      }
    rescue Exception
      Log.error("NVDA: #{$!.to_s}, #{$@.to_s}")
      end
      }
          end
    def initialized?
              @initialized==true
            end
    def braille(text, pos=nil, push=false)
      text=text+""
            if @oldrawbraille!=text or @oldrawpos!=pos or push
        @oldrawbraille=text
        @oldrawpos=pos
      else
        return
      end
                              sleep(0.001) while @braillethr!=nil and @braillethr.status!=nil and @braillethr.status!=false
      @braillethr = Thread.new {
                                                 pos!=nil
                                                                                                  text.gsub!(/\004INFNEW\{([^\}]+)\}\004/) {"[#{$1}]"}
                                                                                                  text.gsub!("\004NEW\004", "[]")
                                                                                                                                                  text.gsub!(/\004[^\004]+\004/,"")
                                                                                                   if pos!=nil
                          pos=text[0..pos].split("").size-1
                          pos=0 if pos<0
                        end
                                                      if @oldbraille!=text or push
                                        pos=0 if pos==nil
        @braillepos=pos
                              ac={'ac'=>'braille', 'text'=>text}
      ac['pos']=pos if pos!=nil
        write(ac) if @braille_alert==nil
      @oldbraille=text
          elsif pos!=nil and @oldpos!=pos
            @oldpos=pos
      write({'ac'=>'braillepos', 'pos'=>pos}) if @braille_alert==nil
    end
    }
  end
  def braille_alert(text)
    return if text==@braillealert
    @braillealertthr.exit if @braillealertthr!=nil
    @braille_alert=text
    ac={'ac'=>'braille', 'text'=>text}
              write(ac)
              @braillealertthr=Thread.new {
              s=text.size/16.0
              s=1 if s<1
              s=5 if s>5
              sleep(s)
              @braille_alert=nil
                            braille(@oldrawbraille||"", @oldrawpos, true)
                            @braillealertthr=nil
              }
    end
            def speak(text)
              Thread.new {
                                          sleep(0.01)
      write({'ac'=>'speak', 'text'=>text})!=nil
      }
    end
    def speakindexed(texts, indexes, indid=nil)
                          Thread.new {
              sleep(0.01)
      write('ac'=>'speakindexed', 'texts'=>texts, 'indexes'=>indexes, 'indid'=>indid)
      }
      end
    def getindex(id=true)
            a=write({'ac'=>'getindex'})
            index=nil
            indid=nil
            index=a['index'] if a!=nil
            indid=a['indid'] if a!=nil
                        if id==false
                        return index
                      else
                        return [index,indid]
                        end
          end
              def getversion
            a=write({'ac'=>'getversion'})
            version=nil
            version=a['version'] if a!=nil
            return version
          end
          def getnvdaversion
            a=write({'ac'=>'getnvdaversion'})
            version=nil
            version=a['version'] if a!=nil
            return version
            end
          def prepared?
            @prepared==true
            end
          def check
            return false if !@initialized || !@prepared
            if @checked==nil
            @checked = write({'ac'=>'check'}, false, 0.1)!=nil
            Log.info("NVDA connected") if @checked
            end
            @checked
          end
          def sleepmode
            a=write({'ac'=>'sleepmode'})
            if a==nil
              return nil
            else
              return a['st']
              end
            end
          def sleepmode=(st)
                        write({'ac'=>'sleepmode', 'st'=>st})
            end
          def stop
                                                            write({'ac'=>'stop'})!=nil
                                    end
        def avail
              dread=[0].pack("I")
      dleft=[0].pack("I")
      dtotal=[0].pack("I")
      buf=""
      PeekNamedPipe.call(@pipein,buf,0,dread,dtotal,dleft)
          return dtotal.unpack("I").first
        end
        def read(size=nil)
            size=avail if size==nil
            return "" if size==0
        dread = [0].pack("i")
      buf="\0"*size
        ReadFile.call(@pipein, buf, size, dread, nil)        
        return "" if dread.unpack("i").first==0
        return buf[0..dread.unpack("i").first-1]
      end
    def write(ac, tryagain=true, timelimit=nil)
                        if timelimit==nil
              s=0
              ac.values.each {|x| s+=x.to_s.size}
              if s<1000
                timelimit=1
              else
                timelimit=8
                end
        end
            return if !@initialized or !ac.is_a?(Hash) or @checked==false
      sleep(0.1) while !@prepared
      st=nil
                                                                                                                                                                              ac['id']=rand(10**24) if ac['id']==nil
                                                                                                                                                                                                @writes.push(ac)
                  @waiting+=1
                                                tm=Time.now.to_f
                        loop {
                sleep(0.001)
                        break if @reads[ac['id']]!=nil or Time.now.to_f-tm>timelimit
                  }
                  sleep(0.01) if @reads[ac['id']]==nil
                  @waiting-=1
                                                                                                          if @reads[ac['id']]!=nil
                                                  r=@reads[ac['id']]
                                                  @reads.delete(ac['id'])
                                                  st=r
                                                else
                                                                            if tryagain==true
                                                                              Log.warning("NVDA is not responding, reconnecting...")
                                                                                                                  init
                  st=write(ac, false)
                else
                  Log.warning("NVDA is not responding, uninitializing Addon.")
                  @checked=nil
                st=nil
                end
              end
              return st
                        end
  end
end  
#Copyright (C) 2014-2019 Dawid Pieper