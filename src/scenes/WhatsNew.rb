# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_WhatsNew
  def initialize(init = false, agtemp = nil, bid = nil)
    @init = init
    @agtemp = agtemp
    @bid = bid
  end

  def main
    if Session.name == "guest"
      alert(_("This section is unavailable for guests"))
      $scene = Scene_Main.new
      return
    end
    agtemp = @agtemp
    agtemp = srvproc("agent", { "client" => "1" }) if agtemp == nil
    err = agtemp[0]
    messages = agtemp[8].to_i
    posts = agtemp[9].to_i
    blogposts = agtemp[10].to_i
    blogcomments = agtemp[11].to_i
    forums = agtemp[12].to_i
    forumsposts = agtemp[13].to_i
    friends = agtemp[14].to_i
    birthday = agtemp[15].to_i
    mentions = agtemp[16].to_i
    followedblogposts = agtemp[17].to_i
    blogfollowers = agtemp[18].to_i
    blogmentions = agtemp[19].to_i
    groupinvitations = agtemp[20].to_i
    nversion = agtemp[2].to_f
    nbeta = agtemp[3].to_i
    nalpha = agtemp[4].to_i
    $nbeta = nbeta
    $nversion = nversion
    $nalpha = nalpha
    @bid = srvproc("bin/buildid", { "branch" => Elten.branch, "build_id" => Elten.build_id }, 1).to_i if @bid == nil
    if @init == true and (posts > 0 or messages > 0)
      header = p_("WhatsNew", "What's new")
    else
      header = ""
    end
    nv = $nversion.to_s
    if $nbeta > $beta and $isbeta == 1
      nv = $version.to_s + " BETA " + $nbeta.to_s
    elsif $isbeta == 2
      nv = $version.to_s + " RC " + $nalpha.to_s
    end
    @sel = ListBox.new([
      "#{p_("WhatsNew", "New messages")} (#{messages.to_s})",
      "#{p_("WhatsNew", "New posts in followed threads")} (#{posts.to_s})",
      "#{p_("WhatsNew", "New posts on the followed blogs")} (#{blogposts.to_s})",
      "#{p_("WhatsNew", "New comments on your blog")} (#{blogcomments.to_s})",
      "#{p_("WhatsNew", "New threads on followed forums")} (#{forums.to_s})",
      "#{p_("WhatsNew", "New posts on followed forums")} (#{forumsposts.to_s})",
      "#{p_("WhatsNew", "New friends")} (#{friends.to_s})",
      "#{p_("WhatsNew", "Friends' birthday")} (#{birthday.to_s})",
      "#{p_("WhatsNew", "Mentions")} (#{mentions.to_s})",
      "#{p_("WhatsNew", "New comments to followed blog posts")} (#{followedblogposts.to_s})",
      "#{p_("WhatsNew", "New blog followers")} (#{blogfollowers.to_s})",
      "#{p_("WhatsNew", "Blog mentions")} (#{blogmentions.to_s})",
      "#{p_("WhatsNew", "Waiting invitations")} (#{groupinvitations.to_s})",
      p_("WhatsNew", "Update available (%{version})") % { "version" => "Elten #{nv}" }
    ], header, 0, 0, true)
    @sel.disable_item(0) if messages <= 0
    @sel.disable_item(1) if posts <= 0
    @sel.disable_item(2) if blogposts <= 0
    @sel.disable_item(3) if blogcomments <= 0
    @sel.disable_item(4) if forums <= 0
    @sel.disable_item(5) if forumsposts <= 0
    @sel.disable_item(6) if friends <= 0
    @sel.disable_item(7) if birthday <= 0
    @sel.disable_item(8) if mentions <= 0
    @sel.disable_item(9) if followedblogposts <= 0
    @sel.disable_item(10) if blogfollowers <= 0
    @sel.disable_item(11) if blogmentions <= 0
    @sel.disable_item(12) if groupinvitations <= 0
    @sel.disable_item(13) if @bid == Elten.build_id or @bid <= 0
    if messages <= 0 and posts <= 0 and blogposts <= 0 and blogcomments <= 0 and forums <= 0 and forumsposts <= 0 and friends <= 0 and birthday <= 0 and mentions <= 0 and followedblogposts <= 0 and blogfollowers <= 0 and blogmentions <= 0 and groupinvitations <= 0 and (@bid == Elten.build_id or @bid <= 0)
      alert(p_("WhatsNew", "There is nothing new."))
      $scene = Scene_Main.new
      return
    end
    @sel.focus
    loop do
      loop_update
      @sel.update
      if escape
        $scene = Scene_Main.new
      end
      if enter or arrow_right
        case @sel.index
        when 0
          $scene = Scene_Messages.new(true)
        when 1
          $scene = Scene_Forum.new(0, -2)
        when 2
          $scene = Scene_Blog_Posts.new(Session.name, "NEWFOLLOWEDBLOGS")
        when 3
          $scene = Scene_Blog_Posts.new(Session.name, "NEW")
        when 4
          $scene = Scene_Forum.new(0, -4)
        when 5
          $scene = Scene_Forum.new(0, -6)
        when 6
          $scene = Scene_Users_AddedMeToContacts.new(true)
        when 7
          $scene = Scene_Contacts.new(1)
        when 8
          $scene = Scene_Forum.new(0, -7)
        when 9
          $scene = Scene_Blog_Posts.new(Session.name, "NEWFOLLOWED")
        when 10
          $scene = Scene_Blog_Followers.new(nil, Scene_WhatsNew.new)
        when 11
          $scene = Scene_Blog_Posts.new(Session.name, "NEWMENTIONED")
        when 12
          $scene = Scene_Forum.new(nil, nil, 4)
        when 13
          $scene = Scene_Update_Confirmation.new
        end
      end
      break if $scene != self
    end
  end
end
