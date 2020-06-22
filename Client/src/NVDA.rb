#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module NVDA
  CreateNamedPipe=Win32API.new("kernel32", "CreateNamedPipe", 'piiiiiip', 'i')
  CloseHandle = Win32API.new("kernel32", "CloseHandle", 'i', 'i')
  WriteFile = Win32API.new("kernel32","WriteFile",'ipipi','I')
PeekNamedPipe=Win32API.new("kernel32","PeekNamedPipe",'ipippp','i')  
      ReadFile = Win32API.new("kernel32","ReadFile",'ipipp','I')
  class <<self
    @@lastid=0
    def init
      @waiting=0
                  @lastwrite=""
      @checked=nil
      @prepared=false
      @gestures=[]
            @checktime=0
            @cbckindexing=false
            @index=nil
            @indid=nil
            @iswaiting=true
      destroy if @initialized==true
      @initialized=true
      @pipename="elten"+rand(36**48).to_s(36)
      @pipein=CreateNamedPipe.call("\\\\.\\pipe\\"+@pipename+"in", 1, 8, 255, 16*1024**2, 16*1024**2, 1, nil) while @pipein==nil||@pipein==-1
      @pipest=CreateNamedPipe.call("\\\\.\\pipe\\"+@pipename+"st", 1, 8, 255, 16*1024**2, 16*1024**2, 1, nil) while @pipest==nil||@pipest==-1
      @pipeout=CreateNamedPipe.call("\\\\.\\pipe\\"+@pipename+"out", 2, 8, 255, 16*1024**2, 16*1024**2, 1, nil) while @pipeout==nil||@pipeout==-1
                  writefile(Dirs.temp+"\\nvda.pipe", @pipename)
                  Log.debug("NVDA pipes registered: #{@pipein.to_s}, #{@pipeout.to_s}")
                                    @writes||=[]
                                    @reads||={}
            @starttime=Time.now.to_f
            @pipethread=Thread.new {
            pid = Win32API.new("kernel32", "GetCurrentProcessId", '', 'i').call
      begin
              dwritten=[0].pack("i")
      loop {
      if !FileTest.exists?(Dirs.temp+"\\nvda.pipe")
        play 'right'
        Thread.new {init}
        break
        end
      if Time.now.to_f-@starttime>1 && @iswaiting
@iswaiting=false
          end
            while @writes.size>0 and @pipeout!=nil and @waiting<10
              w=JSON.generate(@writes.first)+"\n"
                                  WriteFile.call(@pipeout, w, w.bytesize, dwritten, 0)
                                  @waiting+=1
                                  @writes.delete_at(0)
                                end
                                if @exiting==true
                                  @exited=true
                                  exit
                                  end
                                        if @pipein!=nil and (lv=avail)>0
                    r=read(lv)
                    while r[-1..-1]!="\n"
                      sleep(0.001)
                      r+=read(avail)
                    end
                    @checktime=Time.now.to_f
                      b=r.split("\n")
                      for l in b
              j=JSON.load(l)
              @waiting-=1
                                         @reads[j['id']]=j
                                         end
                                       end
            if @pipest!=nil and (lv=availst)>0
                    r=readst(lv)
                    while r[-1..-1]!="\n"
                      sleep(0.001)
                      r+=readst(availst)
                    end
                    @checktime=Time.now.to_f
                                        if !@prepared
                                  @prepared=true
                                  end
                    b=r.split("\n")
                      for l in b
              j=JSON.load(l)
if j['msgtype']==1
  @waiting-=1
              elsif j['msgtype']==2
  @gestures+=j['gestures']
elsif j['msgtype']==3
  @index=j['indexes'][-1]['index']
  @indid=j['indexes'][-1]['indid']
elsif j['msgtype']==4
  write({'ac'=>'init', 'pid'=>pid},nil,true) if j['statuses'].include?("connected")
  @cbckindexing=true if j['statuses'].include?("cbckindexing")
  end
                                         end
                                       end
                        sleep(0.025)
      }
    rescue Exception
      Log.error("NVDA: #{$!.to_s}, #{$@.to_s}")
      end
      }
          end
    def initialized?
              @initialized==true
            end
    def braille(text, pos=nil, push=false, type=0, index=nil, cursor=nil)
                        text=text+""
                        realtext=""
                        @oldbraille="" if @oldbraille==nil
                                                                        case type
                        when -1
                          return if index>=@oldbraille.size
                                                    indexb=index
                          indexb+=1 while indexb<@oldbraille.size-1 && @oldbraille[indexb]>0xBF
                                                    realtext=@oldbraille[0...index]+@oldbraille[(indexb+1)..-1]
                                                    index=realtext[0...index].chrsize
                          @oldrawbraille=""
                                                when 1
                                                  return if index>@oldbraille.size
                                                                                                    realtext=@oldbraille[0...index]+text+@oldbraille[index..-1]
                          index=realtext[0...index].chrsize
                          @oldrawbraille=""
                          when 0
            if @oldrawbraille!=text or @oldrawpos!=pos or push
        @oldrawbraille=text
        @oldrawpos=pos
      else
        return
      end
                                                                                                        text.gsub!(/\004INFNEW\{([^\}]+)\}\004/) {"[#{$1}]"}
                                                                                                  text.gsub!("\004NEW\004", "[]")
                                                                                                                                                  text.gsub!(/\004[^\004]+\004/,"")
                                                                                                                                                                              realtext=text
                                                                                                                                                  end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         if pos!=nil
                          pos=realtext[0...pos].chrsize+1
                          pos=0 if pos<0
                          pos=realtext.size-1 if pos>=realtext.size
                        else
                          pos=0
                        end
                        if cursor!=nil
                          cursor=realtext[0...cursor].chrsize
                        end
                                                                                                                                                  if @oldbraille!=realtext or push
        @oldpos=pos
        @oldcursor=cursor
                              ac={'ac'=>'braille', 'text'=>text}
      ac['pos']=pos if pos!=nil
      ac['cursor']=cursor
      ac['index']=index if index!=nil
      ac['type']=type if type!=nil
      if realtext==""
        ac['type']=0
        ac['text']=""
        ac['pos']=0
      end
      write(ac,nil,true) if @braille_alert==nil
      @oldbraille=realtext
    elsif (pos!=nil and @oldpos!=pos) or @oldcursor!=cursor
                        @oldpos=pos
                        @oldcursor=cursor
      write({'ac'=>'braillepos', 'pos'=>pos,'cursor'=>cursor},nil,true) if @braille_alert==nil
    end
  end
  def braille_alert(text)
    return if text==@braillealert
    @braillealertthr.exit if @braillealertthr!=nil
    @braille_alert=text
    ac={'ac'=>'braille', 'text'=>text}
              write(ac,nil,true)
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
              text=text[0...16384] if text.size>16384
              @stopped=false
              @index=nil
            @indid=nil
                                          sleep(0.01)
      write({'ac'=>'speak', 'text'=>text},nil,true)!=nil
    end
    def speakindexed(texts, indexes, indid=nil)
      @stopped=false
      @index=nil
            @indid=nil
              sleep(0.01)
      write({'ac'=>'speakindexed', 'texts'=>texts, 'indexes'=>indexes, 'indid'=>indid}, nil, true)
      end
    def getindex(id=true)
      if @cbckindexing
        if id==false
          return @index
        else
          return [@index,@indid]
          end
        end
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
          def getgestures
            return [] if @gestures.size==0 or !@initialized or @checked==false
            g=@gestures.deep_dup
            @gestures.clear
            return g
            end
          def prepared?
            @prepared==true
            end
          def check
            @checked=((Time.now.to_f-(@checktime||0))<=3)
                        return @checked
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
            return if @stopped==true
            @index=nil
            @indid=nil
            @stopped=true
                                                            write({'ac'=>'stop'},nil,true)!=nil
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
    def write(ac, timelimit=nil, async=false)
                              if timelimit==nil
              s=0
              ac.values.each {|x| s+=x.to_s.size}
              if s<1000
                timelimit=1
              else
                timelimit=8
                end
        end
            return if async==false and (!@initialized or !ac.is_a?(Hash) or check==false)
      st=nil
                                                                                                                                                                              ac['tp']=1
      ac['id']=(@@lastid||0)+1 if ac['id']==nil
      @@lastid=ac['id']
      ac['async']=true if async
                                                                                                                                                                                                @writes.push(ac)
                                                                                                                                                                                                return if async
                                                tm=Time.now.to_f
                        loop {
                sleep(0.001)
                        break if @reads[ac['id']]!=nil or Time.now.to_f-tm>timelimit
                  }
                  sleep(0.01) if @reads[ac['id']]==nil
                                                                                                          if @reads[ac['id']]!=nil
                                                  r=@reads[ac['id']]
                                                  @reads.delete(ac['id'])
                                                  st=r
                                                else
                                                                                                                                                          Log.warning("NVDA is not responding...")
              end
              return st
            end
            def availst
              dread=[0].pack("I")
      dleft=[0].pack("I")
      dtotal=[0].pack("I")
      buf=""
      PeekNamedPipe.call(@pipest,buf,0,dread,dtotal,dleft)
          return dtotal.unpack("I").first
        end
        def readst(size=nil)
            size=avail_st if size==nil
            return "" if size==0
        dread = [0].pack("i")
      buf="\0"*size
        ReadFile.call(@pipest, buf, size, dread, nil)        
        return "" if dread.unpack("i").first==0
        return buf[0..dread.unpack("i").first-1]
      end
    def waiting?
      return (@iswaiting==true)
    end
    def destroy
      File.delete(Dirs.temp+"\\nvda.pipe") if FileTest.exists?(Dirs.temp+"\\nvda.pipe")
              @pipethread.exit if @pipethread!=nil
        @pipethread=nil
              @initialized=false
        CloseHandle.call(@pipein) if @pipein!=nil
        CloseHandle.call(@pipeout) if @pipeout!=nil
        CloseHandle.call(@pipest) if @pipest!=nil
        @pipein=nil
        @pipeout=nil
        @pipest=nil
      end
    def join
      @exiting=true
      loop_update while !@exited
            File.delete(Dirs.temp+"\\nvda.pipe") if FileTest.exists?(Dirs.temp+"\\nvda.pipe")
      delay(0.1)
      end
    end
    end