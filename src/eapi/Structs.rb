# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module Structs
    module Session
      @@languages = ""
      class << self
        attr_accessor :name, :token, :gender, :fullname, :moderator, :greeting

        def languages
          @@languages
        end

        def languages=(l)
          @@languages = l
        end

        def logged?
          return @name != "" && @name != nil && @token != "" && @token != nil
        end
      end
    end

    module Configuration
      class << self
        attr_accessor :listtype, :usepan, :soundcard, :microphone, :controlspresentation, :contextmenubar, :soundthemeactivation, :typingecho, :linewrapping, :hidewindow, :synctime, :registeractivity, :voice, :language, :voicerate, :voicevolume, :soundtheme, :soundthemepath, :volume, :usefx, :bgsounds, :voicepitch
      end
    end

    module Lists
      class << self
        attr_accessor :locations, :langs
      end
    end

    module Dirs
      @@eltendata = nil
      class << self
        include EltenAPI
        attr_accessor :apps, :soundthemes, :extras, :temp

        def appdata
          getdirectory(26)
        end

        def user
          getdirectory(40)
        end

        def documents
          getdirectory(5)
        end

        def desktop
          getdirectory(16)
        end

        def music
          getdirectory(13)
        end

        def tmp
          buf = "\0" * 2048
          sz = Win32API.new("kernel32", "GetTempPathW", "ip", "i").call(1024, buf)
          d = deunicode(buf[0...sz * 2])
          d.chop! if d[-1..-1] == "\\"
          return d
        end

        def eltendata
          if @@eltendata == nil
            $portable = readini("./elten.ini", "Elten", "Portable", "0").to_i
            if $portable == 0
              @@eltendata = Dirs.appdata + "\\elten"
            else
              @@eltendata = ".\\eltendata"
            end
          end
          return @@eltendata
        end
      end
    end
  end

  include Structs
end
