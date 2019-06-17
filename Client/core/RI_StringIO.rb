#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class StringIO < IO
  attr_accessor :string, :pos
  def initialize(str="")
    @string=str
    @pos=0
  end
  def read(size)
    r=@string[@pos...@pos+size]
    if @pos+size>@string.bytesize
      @pos=@string.bytesize
    else
      @pos+=size
      end
    return r
  end
  def seek(o)
    @pos=o
    @pos=@string.size if @pos>@string.size
  end
  def binmode
    return self
  end
  def getc
    return nil if @pos>=@string.size
    read(1).unpack("c").first
  end
  def eof?
    return false if @pos<@string.size
    true
    end
  end
#Copyright (C) 2014-2019 Dawid Pieper