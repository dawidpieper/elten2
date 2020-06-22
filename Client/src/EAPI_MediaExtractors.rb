#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module MediaFinders
  @@finders=[]
  class <<self
    include EltenAPI
    def register(cls)
      return if !cls.is_a?(Class)
        EltenAPI::Log.debug("Registering media finder #{cls.to_s}")
      @@finders.push(cls)
    end
    def unregister(cls)
      Log.debug("Unregistering media finder #{cls}")
            @@finders.delete(cls)
    end
    def delete_all
      Log.info("Flushing media finders")
      c=@@finders.size
            unregister @@finders[0] while @@finders.size>0
            return c
      end
      def list
        return @@finders
      end
      def possible_media?(text)
        @@finders.each{|m|
        return true if m.possible_media?(text)
        }
        return false
        end
      def get_media(text)
        medias=[]
        @@finders.each{|m|
        begin
          medias+=m.get_media(text)
        rescue Exception
          Log.error("Failed to get media: "+$!.to_s+" "+$@.to_s)
          end
        }
        return medias
        end
  end
  end

class MediaFinder
  def initialize
    raise("Abstract class cannot be initialized")
  end
  def self.possible_media?(text)
    return false
    end
  def self.get_media(text)
    return []
    end
  end
  
  class MediaExtractor
  def initialize
    raise("Abstract class cannot be initialized")
  end
  def title
    return ""
    end
  def proceed
    return
    end
  end