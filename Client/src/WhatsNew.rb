#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_WhatsNew
  def initialize(init=false,agtemp=nil,bid=nil)
    @init = init
    @agtemp=agtemp
    @bid=bid
    end
      def main
        if $name=="guest"
      alert(_("This section is unavailable for guests"))
      $scene=Scene_Main.new
      return
      end
      agtemp=@agtemp
              agtemp = srvproc("agent",{"client"=>"1"}) if agtemp == nil
                      err = agtemp[0]
messages = agtemp[8].to_i
posts = agtemp[9].to_i
blogposts = agtemp[10].to_i
blogcomments = agtemp[11].to_i
forums=agtemp[12].to_i
forumsposts=agtemp[13].to_i
friends=agtemp[14].to_i
birthday=agtemp[15].to_i
mentions=agtemp[16].to_i
nversion=agtemp[2].to_f
            nbeta=agtemp[3].to_i
            nalpha=agtemp[4].to_i
    $nbeta = nbeta
    $nversion = nversion
    $nalpha = nalpha
    @bid=srvproc("bin/buildid",{},1).to_i if @bid==nil
                                                                                            if @init == true     and (posts > 0 or messages > 0)
header = p_("WhatsNew", "What's new")
else
  header=""
        end
        nv=$nversion.to_s
        if $nbeta>$beta and $isbeta==1
          nv=$version.to_s+" BETA "+$nbeta.to_s
        elsif $isbeta==2
          nv=$version.to_s+" RC "+$nalpha.to_s
          end
        @sel = Select.new(["#{p_("WhatsNew", "New messages")} (#{messages.to_s})","#{p_("WhatsNew", "New posts in followed threads")} (#{posts.to_s})","#{p_("WhatsNew", "New posts on the followed blogs")} (#{blogposts.to_s})","#{p_("WhatsNew", "New comments on your blog")} (#{blogcomments.to_s})","#{p_("WhatsNew", "New threads on followed forums")} (#{forums.to_s})","#{p_("WhatsNew", "New threads on followed forums")} (#{forumsposts.to_s})","#{p_("WhatsNew", "New friends")} (#{friends.to_s})","#{p_("WhatsNew", "Friends' birthday")} (#{birthday.to_s})","#{p_("WhatsNew", "Mentions")} (#{mentions.to_s})",p_("WhatsNew", "Update available (%{version})")%{'version'=>"Elten #{nv}"}],true,0,header,true)
    @sel.disable_item(0) if messages <= 0
    @sel.disable_item(1) if posts <= 0
    @sel.disable_item(2) if blogposts <= 0
    @sel.disable_item(3) if blogcomments <= 0
    @sel.disable_item(4) if forums<= 0
    @sel.disable_item(5) if forumsposts<= 0
    @sel.disable_item(6) if friends<= 0
    @sel.disable_item(7) if birthday<= 0
    @sel.disable_item(8) if mentions<= 0
    @sel.disable_item(9) if @bid==Elten.build_id or @bid<=0
        if messages <= 0 and posts <= 0 and blogposts <= 0 and blogcomments <= 0 and forums<=0 and forumsposts<=0 and friends<=0 and birthday<=0 and mentions<=0 and (@bid==Elten.build_id or @bid<=0)
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
            $scene = Scene_Forum.new(0,-2)
            when 2
              $scene = Scene_WhatsNew_BlogPosts.new
              when 3
                $scene = Scene_Blog_Posts.new($name,"NEW")
                when 4
                  $scene = Scene_Forum.new(0,-4)
                  when 5
                    $scene = Scene_Forum.new(0,-6)
                when 6
                  $scene=Scene_Users_AddedMeToContacts.new(true)
                  when 7
                    $scene=Scene_Contacts.new(1)
                    when 8
                      $scene=Scene_Forum.new(0,-7)
                  when 9
                  $scene=Scene_Update_Confirmation.new
        end
        end
      break if $scene != self
      end
  end
  end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        class Scene_WhatsNew_BlogPosts
                    def main
            bt = srvproc("blog_fb_news",{})
            if bt[0].to_i < 0
              alert(_("Error"))
              $scene = Scene_WhatsNew.new
              return
            end
            if bt[1].to_i == 0
              alert(p_("WhatsNew", "There is nothing new on followedblogs."))
              $scene = Scene_WhatsNew.new
              return
            end
            for i in 0...bt.size
              bt[i].delete!("\r\n")
              end
                         @blogauthor = []
           @blogcategory = []
           @blogpost = []
           @blogpostname = []
           t = 0
           id = 0
           for i in 2..bt.size-1
                          case t
             when 0
                              @blogauthor[id] = bt[i]
               when 1
                 @blogcategory[id] = bt[i]
                 when 2
                   @blogpost[id] = bt[i]
                   when 3
                     @blogpostname[id] = bt[i]
             end
             t+=1
            if t == 4
              t = 0
              id += 1
              end
            end
            selh=["",p_("Blog", "Author")]
            sel = []
            for i in 0..@blogpostname.size-1
              o=@blogauthor[i]
              o=blogowners(o).join(", ") if o[0..0]=="["
              sel.push([@blogpostname[i], o])
            end
            @sel = TableSelect.new(selh,sel)
            loop do
              loop_update
              @sel.update
              update
              break if $scene != self
              end
            end
            def update
              if escape or (arrow_left and !$keyr[0x10])
                $scene = Scene_WhatsNew.new
              end
             if enter or (arrow_right and !$keyr[0x10])
               $scene = Scene_Blog_Read.new(@blogauthor[@sel.index],@blogcategory[@sel.index],@blogpost[@sel.index],0,0,$scene)
               end
              end
          end