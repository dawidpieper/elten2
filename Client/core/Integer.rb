#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Fixnum
  alias greater >
  alias less <
  alias greaterq >=
  alias lessq <=
  def >(i)
        greater(i.to_f)
  end
  def <(i)
    less(i.to_f)
    end
  def >=(i)
    greaterq(i.to_f)
  end
  def <=(i)
    lessq(i.to_f)
    end
  end
  class Float
  alias greater >
  alias less <
  alias greaterq >=
  alias lessq <=
  def >(i)
        greater(i.to_f)
  end
  def <(i)
    less(i.to_f)
    end
  def >=(i)
    greaterq(i.to_f)
  end
  def <=(i)
    lessq(i.to_f)
    end
    end
#Copyright (C) 2014-2016 Dawid Pieper