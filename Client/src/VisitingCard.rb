#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_VisitingCard
  def initialize(user=Session.name,scene=nil)
    @user = user
    @scene = scene
  end
  def main
    visitingcard(@user)
    $scene = @scene
    end
  end