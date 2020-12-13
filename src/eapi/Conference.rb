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
@@channels=nil
@@volumes={}
@@channel=Channel.new
@@created=nil
@@hooks=[]
def self.open
  $agent.write(Marshal.dump({'func'=>'conference_open'}))
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
          def self.setopened
            @@opened=true
          end
          def self.setclosed
            @@opened=false
            @@channels=nil
@@volumes={}
@@channel=Channel.new
@@created=nil
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
      end
    end