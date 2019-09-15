#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module Recorder
  class Recording
    attr_reader :proc
    def initialize(filename,quality=0)
      dev=nil
      for i in 0..10
      d=Recorder.devices
      break if d.size>0
      end
      return if d.size==0
      d.keys.each {|k| dev=k if d[k]==$interface_microphone}
      dev=d.keys[0] if dev==nil
      s="bin\\ffmpeg -y -f dshow -i audio=\"#{dev}\" "
      s+="-b:a #{quality.to_s}k" if quality>0
      s+=" \"#{filename}\""
      @proc=ChildProc.new(s)
    end
    def stop
      @proc.write("q") if @proc!=nil
            end
    end
  class <<self
    def devices
      f=ChildProc.new("cmd /c bin\\ffmpeg -list_devices true -f dshow -i dummy 2>\&1")
      loop_update while f.avail==0
      r=f.read
            while !r.include?("dummy: Immediate exit requested")
        loop_update
        r+=f.read if f.avail>0
                end
      d=r
      s=false
      devices={}
      t=nil
      for l in d.delete("\r").split("\n")
        next if !l.downcase.include?("dshow")
        if s==true
          if t==nil and (/\[dshow[^\]]+\] +\"([^\"]+)\"/=~l)!=nil
            t=$1
          elsif (/\[dshow[^\]]+\] +Alternative name +\"([^\"]+)\"/=~l)!=nil
            devices[$1]=t
            t=nil
            end
        else
          s=true if l.include?("DirectShow audio devices")
                    end
        end
        return devices
    end
    def start(file,quality=0)
      Recording.new(file,quality)
      end
    end
  end
#Copyright (C) 2014-2019 Dawid Pieper