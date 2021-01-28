# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Audio3D
  attr_reader :file, :x, :y, :z, :volume
@@ids=[]
  def initialize(file)
    fail("SteamAudio not loaded") if !load_hrtf
    id=nil
    id=rand(36**16).to_s(36) while id==nil || @@ids.include?(id)
    @id=id
    $agent.write(Marshal.dump({'func'=>'audio3d_new', 'file'=>file, 'id'=>@id}))
    @file=file
    @x,@y,@z=0,0,0
    @volume=100
  end
  def play
    $agent.write(Marshal.dump({'func'=>'audio3d_play', 'id'=>@id}))
  end
  def stop
    $agent.write(Marshal.dump({'func'=>'audio3d_stop', 'id'=>@id}))
  end
  def free
    $agent.write(Marshal.dump({'func'=>'audio3d_free', 'id'=>@id}))
  end
  def volume=(vol)
    vol=vol.to_i
    return @volume if !vol.is_a?(Integer)
    vol=100 if vol>100
    vol=0 if vol<0
    $agent.write(Marshal.dump({'func'=>'audio3d_volume', 'volume'=>vol/100.0, 'id'=>@id}))
    @volume=vol
    end
  def move(x,y,z)
        $agent.write(Marshal.dump({'func'=>'audio3d_move', 'x'=>x, 'y'=>y, 'z'=>z, 'id'=>@id}))
    @x,@y,@z=x,y,z
  end
  def validate_position(val)
    val=-1 if val<-1
    val=1 if val>1
    end
  def x=(val)
    move(validate_position(val),@y,@z)
  end
  def y=(val)
    move(@x,validate_position(val),@z)
  end
  def z=(val)
    move(@x,@y,validate_position(val))
    end
  end