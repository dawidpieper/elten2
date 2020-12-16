# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 



module EltenAPI
  class Conference
    class Channel
      attr_accessor :id, :name, :bitrate, :framesize, :public, :users
      def initialize
        @name=""
        @framesize=60
        @bitrate=64
        @public=true
        @users=[]
        @id=0
        end
    end
    class ChannelUser
     attr_accessor :id, :name
     def initialize(id, name)
       @id=id
       @name=name
       end
     end
     class ChannelUserVolume
       attr_accessor :user, :volume, :muted
       def initialize(user, volume, muted)
         @user=user
         @volume=volume
         @muted=muted
       end
       end
     class ConferenceHook
       attr_reader :hook, :block
       def initialize(hook, block)
         @hook=hook
         @block=block
         end
       end
     
    @@opened=false
@@volume=0
@@muted=false
@@stream_volume=0
    @@channels=nil
@@volumes={}
@@channel=Channel.new
@@created=nil
@@hooks=[]
@@streams={}
@@streaming=false
def self.open
  @@opened=false
  $agent.write(Marshal.dump({'func'=>'conference_open'}))
  t=Time.now.to_f
  while Time.now.to_f-t<3
    loop_update
    break if @@opened==true
    end
end
def self.close
  $agent.write(Marshal.dump({'func'=>'conference_close'}))
  end
def self.join(id)
  if @@opened==false
  self.open
  delay(1)
else
  return if @@channel.id==id
  end
  $agent.write(Marshal.dump({'func'=>'conference_joinchannel', 'channel'=>id}))
end
def self.leave
  if @@opened==false
  self.open
  delay(1)
  end
  $agent.write(Marshal.dump({'func'=>'conference_leavechannel'}))
end
def self.streaming?
  @@streaming
  end
def self.set_stream(file)
  $agent.write(Marshal.dump({'func'=>'conference_setstream', 'file'=>file}))
end
def self.remove_stream
  $agent.write(Marshal.dump({'func'=>'conference_removestream'}))
  @@streaming=false
  end
def self.move(x_plus, y_plus)
  $agent.write(Marshal.dump({'func'=>'conference_move', 'x_plus'=>x_plus, 'y_plus'=>y_plus}))
  end
def self.create(name="", public=true, bitrate=64, framesize=60, password=nil)
  if @@opened==false
  self.open
  delay(1)
  end
  @@created=nil
  $agent.write(Marshal.dump({'func'=>'conference_createchannel', 'name'=>name, 'public'=>public, 'bitrate'=>bitrate, 'framesize'=>framesize, 'password'=>password}))
  t=Time.now.to_f
  while Time.now.to_f-t<8
    loop_update
    break if @@created!=nil
  end
  return @@created
end
def self.update_channels
  if @@opened==false
  self.open
  delay(1)
  end
  @@channels=nil
  $agent.write(Marshal.dump({'func'=>'conference_listchannels'}))
  t=Time.now.to_f
  while Time.now.to_f-t<1
loop_update
    break if @@channels!=nil
    end
  end
  def self.muted
    @@muted
  end
  def self.muted=(mt)
    if @@opened==false
  self.open
  delay(1)
  end
    $agent.write(Marshal.dump({'func'=>'conference_setmuted', 'muted'=>mt==true}))    
    @@muted=(mt==true)
    end
  def self.input_volume
    @@volume
  end
  def self.input_volume=(vol)
    if @@opened==false
  self.open
  delay(1)
  end
    vol=0 if vol<0
    vol=100 if vol>100
$agent.write(Marshal.dump({'func'=>'conference_setinputvolume', 'volume'=>vol}))    
    @@volume=vol
  end
   def self.stream_volume
    @@stream_volume
  end
  def self.stream_volume=(vol)
    if @@opened==false
  self.open
  delay(1)
  end
    vol=0 if vol<0
    vol=100 if vol>100
$agent.write(Marshal.dump({'func'=>'conference_setstreamvolume', 'volume'=>vol}))    
    @@stream_volume=vol
  end
def self.volume(user)
  v=self.volumes[user]
  v||=ChannelUserVolume.new(user, 100, false)
  v
  end
def self.volumes
  return {} if @@volumes==nil
  vls={}
  for u in @@volumes.keys
    vls[u] = ChannelUserVolume.new(u, @@volumes[u][0], @@volumes[u][1])
    end
  return vls
end
def self.setvolume(user, volume, muted)
  if @@opened==false
  self.open
  delay(1)
  end
  $agent.write(Marshal.dump({'func'=>'conference_setvolume', 'user'=>user, 'volume'=>volume, 'muted'=>muted}))
  end
def self.channels
    channels=[]
  if @@channels.is_a?(Array)
    for cha in @@channels
      ch=Channel.new
      ch.id=cha['id'].to_i
      ch.name=cha['name'].to_s
      ch.framesize=cha['framesize'].to_f
      ch.bitrate=cha['bitrate'].to_i
      for u in cha['users']
        ch.users.push(ChannelUser.new(u['id'], u['name']))
      end
      channels.push(ch)
      end
  end
  return channels
  end
                  def self.opened?
            return @@opened
          end
          def self.channel
            return @@channel
            end
          def self.setopened(data)
            self.setclosed
            @@volume = data['volume']
            @@input_volume = data['input_volume']
            @@opened=true
          end
          def self.setclosed
            @@streams={}
            @@opened=false
            @@channels=nil
@@volumes={}
@@channel=Channel.new
@@created=nil
@@volume=0
@@stream_volume=0
          end
                    def self.setchannel(c)
                    params=JSON.load(c)
            if params.is_a?(Hash)
                          ch=Channel.new
            ch.id=(params['id']||0).to_i
            ch.name=params['name']
            ch.framesize=(params['framesize']||60).to_f
            ch.bitrate=(params['bitrate']||0).to_i
            ch.public=params['public']!=false
            ch.users=[]
            if params['users'].is_a?(Array)
              ch.users=params['users'].map{|u| ChannelUser.new(u['id'], u['name'])}
            end
            @@channel=ch
            trigger(:update)
          end
          rescue Exception
                      end
                      def self.setcreated(id)
                        @@created=id
                      end
                      def self.setchannels(chs)
                                                @@channels=JSON.load(chs)
                        rescue Exception
                        end
                        def self.setvolumes(vls)
                                                @@volumes=JSON.load(vls)
                        rescue Exception
                        end
                        def self.on(hook, &block)
                          if block!=nil
                          hk=ConferenceHook.new(hook, block)
                          @@hooks.push(hk)
                          return hk
                          end
                        end
                        def self.remove_hook(hk)
                          @@hooks.delete(hk)
                          end
                        def self.trigger(hook)
                          for hk in @@hooks
                            hk.block.call if hk.hook==hook
                            end
                          end
                          def self.setaddstream(params)
                            @@streams[params['stream']]=params['file']
                          end
                          def self.setremovestream(params)
                            @@streams.delete(params['stream'])
                            end
      end
    end