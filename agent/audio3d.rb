# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Audio3D
  attr_reader :file, :x, :y, :z, :bilinear
  @@loaded = false
  @@hrtf = nil
  def self.load(frequency = 48000, framesize = 20)
    @@framesize = framesize
    @@frequency = frequency
    @@hrtf = SteamAudio.new(frequency, framesize)
    @@loaded = true
  end
  def self.free
    if @@hrtf != nil
      @@hrtf.free
      @@loaded = false
      @@hrtf = nil
    end
  end

  def initialize(frequency = 48000, channels = 2)
    fail("Audio3D not loaded") if !@@loaded
    @hrtf_effect = @@hrtf.add_effect(2)
    @x, @y, @z = 0, 0, 0
    @bilinear = false
    @stream = Bass::BASS_StreamCreate.call(@@frequency, 2, 256, -1, nil)
    Bass::BASS_ChannelPlay.call(@stream, 0)
    @source_mixer = Bass::BASS_Mixer_StreamCreate.call(@@frequency, 2, 0x1000 | 256 | 0x200000)
    @file = nil
    @source = nil
    @channels, @frequency = channels, frequency
    @mutex = Mutex.new
    @playing = false
    @thread = Thread.new { thread }
  end

  def play
    @playing = true
  end

  def stop
    @playing = false
  end

  def playing?
    @playing
  end

  def volume
    return 1 if @source == nil
    vl = [0].pack("f")
    Bass::BASS_ChannelGetAttribute.call(@source, 2, vl)
    return (vl.unpack("f").first)
  end

  def volume=(vol)
    return 1 if @source == nil
    vol = 1 if vol > 1
    vol = 0 if vol < 0
    Bass::BASS_ChannelSetAttribute.call(@source, 2, [vol].pack("f").unpack("i")[0])
    vol
  end

  def freesource
    @mutex.synchronize {
      Bass::BASS_StreamFree.call(@source) if @source != nil
      @source = nil
      @file = nil
    }
  end

  def file=(fl)
    freesource
    @mutex.synchronize {
      @source = Bass::BASS_StreamCreateFile.call(0, unicode(fl), 0, 0, 0, 0, [4 | 256 | 0x80000000 | 0x200000].pack("I").unpack("i").first)
      Bass::BASS_Mixer_StreamAddChannel.call(@source_mixer, @source, 0)
      @file = fl.freeze
    }
  end

  def put(data)
    freesource if @file != nil
    @mutex.synchronize {
      if @source != nil
        @source = Bass::BASS_StreamCreate.call(@frequency, @channels, 256 | 0x200000, -1, nil)
        Bass::BASS_Mixer_StreamAddChannel.call(@source_mixer, @source, 0)
      end
      Bass::BASS_StreamPutData.call(@source, data, data.bytesize)
    }
  end

  def validate_position(val)
    val = -1 if val < -1
    val = 1 if val > 1
    val
  end

  def x=(val)
    @x = validate_position(val)
  end

  def y=(val)
    @y = validate_position(val)
  end

  def z=(val)
    @z = validate_position(val)
  end

  def bilinear=(b)
    b = false if b != true
    @bilinear = b
    @@hrtf.set_bilinear(@hrtf_effect, b)
  end

  def free
    @thread.exit if @thread != nil
    @thread = nil
    freesource
    Bass::BASS_StreamFree.call(@source_mixer)
    Bass::BASS_StreamFree.call(@stream)
    @@hrtf.remove_effect(@hrtf_effect)
  end

  private

  def thread
    queue = "".b
    fsize = @@frequency / 1000.0 * @@framesize * 2 * 4
    buf = "\0" * fsize
    loop {
      while @playing == false
        sleep(@@framesize / 1000.0)
      end
      if (sz = Bass::BASS_ChannelGetData.call(@source_mixer, buf, fsize)) > 0
        queue += buf.byteslice(0...sz)
      end
      while queue.size >= fsize
        frame = queue.byteslice(0...fsize)
        queue = queue.byteslice(fsize..-1)
        out = ""
        @mutex.synchronize {
          x, y, z = @x, @y, @z
          z = 0.001 if x == 0 && y == 0 && z == 0
          out = @@hrtf.process(@hrtf_effect, frame, x, y, z) if @@loaded && @@hrtf != nil
          ps = 0
          ps += Bass::BASS_StreamPutData.call(@stream, out, out.bytesize) if @stream != nil
          ps += Bass::BASS_ChannelGetData.call(@stream, nil, 0x40000000) if @stream != nil
          t = ps / @@frequency.to_f / 4 / 2.0 - @@framesize / 1000.0
          sleep(@@framesize / 1000.0) if t > @@framesize / 1000.0 * 2.5
        }
      end
    }
  end
end
