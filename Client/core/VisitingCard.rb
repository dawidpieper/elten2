#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_VisitingCard
  def initialize(user=$name,scene=nil)
    @user = user
    @scene = scene
  end
  def main
    visitingcard(@user)
    $scene = @scene
    end
  end
#Copyright (C) 2014-2016 Dawid Pieper