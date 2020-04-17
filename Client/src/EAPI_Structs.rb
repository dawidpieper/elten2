#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module Structs
  module Session
    class <<self
      attr_accessor :name, :token, :gender, :fullname
      end
    end
    module Lists
      class <<self
        attr_accessor :locations, :langs
        end
      end
      module Dirs
        class <<self
          attr_accessor :appdata, :apps, :eltendata, :soundthemes, :extras
        end
        end
      end
      end