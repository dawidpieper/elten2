#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module QuickActions
    class QuickAction
      attr_accessor :label, :key
      attr_reader :action, :params
      def initialize(action, label="", params=[], key=0)
        @label, @action, @params, @key = label, action, params, key
      end
      def detail
        l=@label
        if @key!=0
          l+=" ("
          l+="SHIFT+" if @key<0
          l+="F"+@key.abs.to_s
          l+=")"
          end
        return l
        end
      def call
        if @action.is_a?(Symbol)
          call_symbol
          else
        insert_scene(@action.new(*@params))
        end
      end
      def gettime
        if $advanced_synctime == 1
                      time = Time.at(srvproc("time",{"int"=>1},1).to_i)
                    else
                                            time=Time.now
                                          end
                                          return time
        end
      def call_symbol
        case @action
        when :lastspeech
          speech($speech_lasttext)
          when :tray
            $totray=true
        when :date
          alert(gettime.strftime("%Y-%m-%d"), false)
          when :time
            alert(gettime.strftime("%H:%M:%S"), false)
            when :volumedown
                $volume -= 5 if $volume > 5
  writeconfig("Interface","MainVolume",$volume)
  eplay("list_focus")
              when :volumeup
                  $volume += 5 if $volume < 100
  writeconfig("Interface","MainVolume",$volume)
  eplay("list_focus")
                when :playlistprevious
  if $playlistbuffer != nil
    if $playlistindex != 0
    $playlistindex -= 1
  else
    $playlistindex=$playlist.size-1
    end
    end
                  when :playlistnext
                    $playlistindex += 1 if $playlistbuffer!=nil
                                       when :playlistvolumedown
                          $playlistvolume = 0.8 if $playlistvolume == nil
  if $playlistvolume > 0.01
    $playlistvolume -= 0.1
  $playlistvolume=0.01 if $playlistvolume==0
    eplay("list_focus",$playlistvolume*-100) if $playlistbuffer==nil or $playlistpaused==true
  end
                      when :playlistvolumeup
                          $playlistvolume = 0.8 if $playlistvolume == nil
  if $playlistvolume < 1
  $playlistvolume += 0.1
  eplay("list_focus",$playlistvolume*-100) if $playlistbuffer==nil or $playlistpaused==true
  end
                        when :playlistpause
                              if $playlist.size>0 and $playlistbuffer!=nil
if $playlistpaused == true
  $playlistbuffer.play
  $playlistpaused = false
else
  $playlistpaused=true
  $playlistbuffer.pause  
end
end
        end
        end
      end
  class <<self
    @@actions=nil
    def get
      load_actions if @@actions==nil
            @@actions.dup
    end
    def load_actions
      @@actions=[]
      if !FileTest.exists?(Dirs.eltendata+"\\quickactions.dat")
        load_defaults
      else
        d=load_data(Dirs.eltendata+"\\quickactions.dat")
        for ac in d
                    if ac[0][0..0]==":"
            ac[0]=ac[0].to_sym
          else
            begin
            ac[0]=Object.const_get(ac[0])
          rescue Exception
            next
            end
          end
          register(*ac)
          end
      end
    rescue Exception
      load_defaults
    end
    def load_defaults
      acs=[
      [Scene_WhatsNew, p_("EAPI_QuickActions", "What is new?"), [], 10],
            [Scene_Contacts, p_("EAPI_QuickActions", "My contacts"), [], 9],
      [Scene_Online, p_("EAPI_QuickActions", "Who is online?"), [], -9],
      [Scene_Messages, p_("EAPI_QuickActions", "Messages"), [], -10],
      [Scene_Chat, p_("EAPI_QuickActions", "Chat"), [], -11],
      [Scene_Forum, p_("EAPI_QuickActions", "Forum")],
      [Scene_Blog, p_("EAPI_QuickActions", "Blogs")],
      [Scene_Console, p_("EAPI_QuickActions", "Console"), [], 7]
      ]+predefined_procs
      acs.each{|a|
      register(*a)
      }
    end
    def predefined_procs
            [
            [:time, p_("EAPI_QuickActions", "Say time"), [], 8],
      [:date, p_("EAPI_QuickActions", "Say date"), [], -8],
      [:lastspeech, p_("EAPI_QuickActions", "Speech last text"), [], 11],
      [:tray, p_("EAPI_QuickActions", "Minimize Elten to tray"), [], 3],
      [:volumedown, p_("EAPI_QuickActions", "Volume down"), [], 5],
      [:volumeup, p_("EAPI_QuickActions", "Volume up"), [], 6],
      [:playlistprevious, p_("EAPI_QuickActions", "Playlist: previous track"), [], -4],
      [:playlistnext, p_("EAPI_QuickActions", "Playlist: next track"), [], -7],
      [:playlistvolumedown, p_("EAPI_QuickActions", "Playlist: volume down"), [], -5],
      [:playlistvolumeup, p_("EAPI_QuickActions", "Playlist: volume up"), [], -6],
      [:playlistpause, p_("EAPI_QuickActions", "Playlist: toggle pause"), [], -3]
      ]
      end
    def register(scene, label="", params=[], key=0)
      @@actions.push(QuickAction.new(scene, label, params, key))
    end
    def create(scene, label="", params=[], key=0)
      register(scene, label, params, key)
      save_actions
    end
    def delete(index)
      @@actions.delete_at(index)
      save_actions
    end
    def rename(index, label)
      @@actions[index].label=label
      save_actions
    end
    def rekey(index, key)
      @@actions[index].key=key
      save_actions
    end
    def up(index)
      @@actions[index-1], @@actions[index] = @@actions[index], @@actions[index-1]
      save_actions
    end
    def down(index)
            @@actions[index+1], @@actions[index] = @@actions[index], @@actions[index+1]
      save_actions
      end
    def save_actions
      a=[]
      for ac in @@actions
        b=[]
        if ac.action.is_a?(Symbol)
          b[0]=":"+ac.action.to_s
        elsif ac.action.is_a?(Class)
          b[0]=ac.action.name
        else
          next
        end
                b[1]=ac.label.to_s
        b[2]=ac.params
        b[3]=ac.key
        a.push(b)
        end
      save_data(a, Dirs.eltendata+"\\quickactions.dat")
      end
    end
  end
  end