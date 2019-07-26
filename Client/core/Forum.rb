#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Forum
  def initialize(pre=nil,preparam=nil,query="")
    @pre=pre
    @preparam=preparam
    @query=query
    @grpindex||=[]
    end
  def main
    #return $scene=Scene_Main.new if $eltsuspend
        if $name=="guest"
            @noteditable=true
            else
          @noteditable=isbanned($name)
          end
          getcache
                            return if $scene!=self
              if @pre==nil
    groupsmain
  else
        if @preparam.is_a?(String) or @preparam==nil or @preparam==-5
          foll=false
          foll=true if @preparam==-5
        @grpindex[0]=0
        @frmindex=0
    forum=nil
    for thread in @threads
      forum=thread.forum.name if thread.id==@pre
    end
        group=nil
    for tforum in @forums
            group=tforum.group.id if tforum.name==forum
          end
          group=-5 if @preparam==-5
@grpsetindex=group if group>0
@grpindex[0]=1 if @preparam==-5
i=0
for tforum in @forums
  if (tforum.group.id==group) or (tforum.followed and @preparam==-5)
    @frmindex=i if tforum.name==forum
    i+=1
    end
  end
  @lastgroup=group  
  threadsmain(forum)
else
  if @preparam==-3
    @grpindex[0]=@groups.size+2
    @results=[]    
    sr=srvproc("forum_search","name=#{$name}\&token=#{$token}\&query=#{@query.urlenc}")
    if sr[0].to_i<0
            speech(_("General:error"))
          else
            t=0
            for l in sr[2..sr.size-1]
              if t==0
                @results.push(l.to_i)
                t=1
              else
                t=0
                end
              end
              end
    end
  threadsmain(@preparam)
  end
    end
  end
  def groupsmain(type=-1)
        type=(@lastlist||0) if type==-1
    @lastlist=type
    index=0
    case type
    when 0
      @grpindex.delete_at(-1) while @grpindex.size>1
sgroups=[]
spgroups=[]
sgloc=false
    for g in @groups
      if g.role==1||g.role==2
      sgroups.push(g)
    end
    if sgloc==false and g.lang.downcase==$language[0..1].downcase and g.recommended
      spgroups.push(g) if !sgroups.include?(g)
      sgloc=true if g.id!=1
      end
    end
    sgroups+=spgroups
    sgroups.sort! {|a,b|
    x=b.lang
    x="_" if b.lang.downcase==$language[0..1].downcase
    x+=sprintf("%04d",b.id)
    y=a.lang
    y="_" if a.lang.downcase==$language[0..1].downcase
    y+=sprintf("%04d",a.id)
        y<=>x
    }
        grpheadindex=2
        grpselt=[]
        for i in 0...sgroups.size
          group=sgroups[i]
      grpselt.push([group.name,group.forums.to_s,group.threads.to_s,group.posts.to_s,(group.posts-group.readposts).to_s])
      @grpindex[0]=i+grpheadindex if group.id==@grpsetindex
    end
        forfol=[]
    for forum in @forums
      if forum.followed
        forfol.push(forum.name)
      end
    end
    flt=flr=flp=0
    ft=fp=fr=0
    for thread in @threads
      if thread.followed
      ft+=1
      fp+=thread.posts
      fr+=thread.readposts
    end
    if forfol.include?(thread.forum.id)
      flt+=1
      flp+=thread.posts
      flr+=thread.readposts
            end
          end
          grpselt = [[_("Forum:opt_followedthreads"), nil, ft.to_s, fp.to_s, (fp-fr).to_s], [_("Forum:opt_followedforums"), forfol.size.to_s, flt.to_s, flp.to_s, (flp-flr).to_s]]+grpselt+[[_("Forum:opt_groupsrecommended")],[_("Forum:opt_groupsopen")],[_("Forum:opt_groupsinvited")],[_("Forum:opt_groupsall")],[_("Forum:opt_search")]]
          s=0
          @groups.each {|g| s+=1 if g.role==5}
          grpselt[grpheadindex+sgroups.size+2]=[nil] if s==0
          grpselh= [nil, _("Forum:opt_phr_forums"), _("Forum:opt_phr_threads"), _("Forum:opt_phr_posts"), _("Forum:opt_phr_unreads")]
          when 1
            sgroups=[]
            spgroups=[]
            for g in @groups
              if g.recommended
              if $language[0..1].downcase==g.lang.downcase
                sgroups.push(g)
              else
                spgroups.push(g)
                end
              end
            end
            sgroups+=spgroups
       grpheadindex=0
        grpselt=[]
        for group in sgroups
      grpselt.push([group.name+": "+group.description,group.forums.to_s,group.threads.to_s,group.posts.to_s,(group.posts-group.readposts).to_s])
    end     
    grpselh= [nil, _("Forum:opt_phr_forums"), _("Forum:opt_phr_threads"), _("Forum:opt_phr_posts"), _("Forum:opt_phr_unreads")]
    when 2
                  sgroups=[]
                              for g in @groups
              if g.open&&g.public&&!g.recommended
                              sgroups.push(g)
                              end
            end
            sgroups.sort! {|a,b| b.posts<=>a.posts}
       grpheadindex=0
        grpselt=[]
        for group in sgroups
      grpselt.push([group.name+": "+group.description,group.forums.to_s,group.threads.to_s,group.posts.to_s,(group.posts-group.readposts).to_s])
    end     
    grpselh= [nil, _("Forum:opt_phr_forums"), _("Forum:opt_phr_threads"), _("Forum:opt_phr_posts"), _("Forum:opt_phr_unreads")]
    when 3
                            sgroups=[]
                              for g in @groups
              if g.role==5
                              sgroups.push(g)
                              end
            end
            sgroups.sort! {|a,b| b.posts<=>a.posts}
       grpheadindex=0
        grpselt=[]
        for group in sgroups
      grpselt.push([group.name+": "+group.description,group.forums.to_s,group.threads.to_s,group.posts.to_s,(group.posts-group.readposts).to_s])
    end     
    grpselh= [nil, _("Forum:opt_phr_forums"), _("Forum:opt_phr_threads"), _("Forum:opt_phr_posts"), _("Forum:opt_phr_unreads")]
    when 4
                      sgroups=[]
                              for g in @groups
              if g.public||g.open
                              sgroups.push(g)
                              end
            end
            sgroups.sort! {|a,b| b.posts<=>a.posts}
       grpheadindex=0
        grpselt=[]
        for group in sgroups
      grpselt.push([group.name+": "+group.description,group.forums.to_s,group.threads.to_s,group.posts.to_s,(group.posts-group.readposts).to_s])
    end     
    grpselh= [nil, _("Forum:opt_phr_forums"), _("Forum:opt_phr_threads"), _("Forum:opt_phr_posts"), _("Forum:opt_phr_unreads")]
    end
        @grpindex[type]=0 if @grpindex[type]==nil
        @grpsetindex=nil
                  @grpsel=TableSelect.new(grpselh,grpselt,@grpindex[type],_("Forum:head"))
    loop do
      loop_update
      @grpsel.update
      if enter or (Input.trigger?(Input::RIGHT) and !$keyr[0x10])
                      @grpindex[type]=@grpsel.index
                              if @grpsel.index==grpheadindex-2
          return threadsmain(-1)
        elsif @grpsel.index==grpheadindex-1
          return forumsmain(-5)
        elsif @grpsel.index==grpheadindex+sgroups.size
          return groupsmain(1)
          elsif @grpsel.index==grpheadindex+sgroups.size+1
          return groupsmain(2)
          elsif @grpsel.index==grpheadindex+sgroups.size+2
          return groupsmain(3)
          elsif @grpsel.index==grpheadindex+sgroups.size+3
          return groupsmain(4)
          elsif @grpsel.index==grpheadindex+sgroups.size+4
          @query=input_text(_("Forum:type_searchphrase"),"ACCEPTESCAPE")
          loop_update
          if @query!="\004ESCAPE\004"
          @results=[]
          sr=srvproc("forum_search","name=#{$name}\&token=#{$token}\&query=#{@query.urlenc}")
          if sr[0].to_i<0
            speech(_("General:error"))
          else
            t=0
            for l in sr[2..sr.size-1]
              if t==0
                @results.push(l.to_i)
                t=1
              else
                t=0
                end
              end
          return threadsmain(-3)
          end
          end
          else
        g=sgroups[@grpsel.index-grpheadindex]
                            return forumsmain(g.id) if g.role==1 or g.role==2 or g.public
        end
        end
      if alt
        menut=[_("Forum:opt_open"),nil,nil,nil,nil,nil,_("General:str_refresh"),_("General:str_cancel"),_("Forum:opt_newgroup")]
        if @grpsel.index>=grpheadindex and @grpsel.index<grpheadindex+sgroups.size
        menut[2] = _("Forum:opt_members")
        menut[3] = _("Forum:opt_invite") if sgroups[@grpsel.index-grpheadindex].role==2
                menut[4] = _("Forum:opt_join") if sgroups[@grpsel.index-grpheadindex].role==0 and sgroups[@grpsel.index-grpheadindex].open and sgroups[@grpsel.index-grpheadindex].public
                menut[4] = _("Forum:opt_invitationaccept") if sgroups[@grpsel.index-grpheadindex].role==5
        menut[5] = _("Forum:opt_leave") if (sgroups[@grpsel.index-grpheadindex].role==1 or sgroups[@grpsel.index-grpheadindex].role==2) and sgroups[@grpsel.index-grpheadindex].founder!=$name
        menut[5] = _("Forum:opt_invitationrefuse") if sgroups[@grpsel.index-grpheadindex].role==5
                menut.push(_("Forum:opt_editgroup")) if sgroups[@grpsel.index-grpheadindex].founder==$name
        menut.push(_("Forum:opt_deletegroup")) if sgroups[@grpsel.index-grpheadindex].forums==0 and sgroups[@grpsel.index-grpheadindex].founder==$name
      end
                     sel = menuselector(menut)
                case sel
        when 0
                        @grpindex[type]=@grpsel.index
        if @grpsel.index==grpheadindex-2
          return threadsmain(-1)
        elsif @grpsel.index==grpheadindex-1
          return forumsmain(-5)
        elsif @grpsel.index==grpheadindex+sgroups.size
          return groupsmain(1)
        elsif @grpsel.index==grpheadindex+sgroups.size+1
          return groupsmain(2)
          elsif @grpsel.index==grpheadindex+sgroups.size+2
          @query=input_text(_("Forum:type_searchphrase"),"ACCEPTESCAPE")
          loop_update
          if @query!="\004ESCAPE\004"
          @results=[]
          sr=srvproc("forum_search","name=#{$name}\&token=#{$token}\&query=#{@query.urlenc}")
          if sr[0].to_i<0
            speech(_("General:error"))
          else
            t=0
            for l in sr[2..sr.size-1]
              if t==0
                @results.push(l.to_i)
                t=1
              else
                t=0
                end
              end
          return threadsmain(-3)
          end
          end
          else
        g=sgroups[@grpsel.index-grpheadindex]
            return forumsmain(g.id) if g.role==1 or g.role==2 or g.public==true
          end
          when 1

          when 2
          m=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=members\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}")
          if m[0].to_i<0
            speech(_("General:error"))
            speech_wait
          else
            selt = []
            users = []
            roles = []
            for i in 0...m[1].to_i
              users.push(m[2+i*2].delete("\r\n"))
              roles.push(m[2+i*2+1].to_i)
              t=users.last
              if sgroups[@grpsel.index-grpheadindex].founder==users.last
                t+=" (#{_("Forum:opt_phr_founder")})"
              elsif roles.last==2
                t+=" (#{_("Forum:opt_phr_moderator")})"
              elsif roles.last==3
                t+=" (#{_("Forum:opt_phr_banned")})"
              elsif roles.last==5
                t+=" (#{_("Forum:opt_phr_invited")})"
              end
              t+= ". "+getstatus(users.last)
              selt.push(t)
            end
            sel=Select.new(selt,true,0,_("Forum:head_members"))
            br=false
            loop do
              loop_update
              sel.update
              if escape or br
                loop_update
                                @grpsel.focus
                                break
                end
              usermenu(users[sel.index]) if enter
              if alt
                ment=[users[sel.index], "", "", _("General:str_cancel")]
                men=menulr(ment)
                if sgroups[@grpsel.index-grpheadindex].founder!=$name or users[sel.index]==$name
                men.disable_item(1)
                              else
                if roles[sel.index]==1
                men.commandoptions[1]=_("Forum:opt_moderationgrant")
                                              elsif roles[sel.index]==2
                men.commandoptions[1]=_("Forum:opt_moderationdeny")
                men.commandoptions[2] = _("Forum:opt_passadmin")
              elsif roles[sel.index]==3
                men.disable_item(1)
                men.commandoptions[2]=_("Forum:opt_userunban")
                end
              end
              if (sgroups[@grpsel.index-grpheadindex].founder!=$name and sgroups[@grpsel.index-grpheadindex].role!=2) or $name==users[sel.index]
                men.disable_item(2)
                else
                if roles[sel.index]==1
                  if sgroups[@grpsel.index-grpheadindex].open
                    men.commandoptions[2] = _("Forum:opt_userban")
                    else
                 men.commandoptions[2] = _("Forum:opt_userkick")
                 end
               elsif roles[sel.index]==3
                 men.commandoptions[2] = _("Forum:opt_userunban")
               elsif roles[sel.index]==3
                 men.disable_item(2) if sgroups[@grpsel.index-grpheadindex].founder!=$name
                  end
                                end
                play("menu_open")
                play("menu_background")
                brm=false
                loop do
                loop_update
                men.update
                if enter or (Input.trigger?(Input::DOWN) and men.index==0)
                case men.index
                when 0
                  if usermenu(users[sel.index],true)=="ALT"
                    brm=true
                  else
                    men.focus
                  end
                  when 1
                    cat=""
                    if roles[sel.index]==1
                      cat="moderationgrant"
                    else
                      cat="moderationdeny"
                      end
                      confirm(s_("Forum:alert_#{cat}", {'user'=>users[sel.index], 'groupname'=>sgroups[@grpsel.index-grpheadindex].name})) {
                      r=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=privileges\&pr=#{cat}\&user=#{users[sel.index]}\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}")
if r[0].to_i<0
  speech(_("General:error"))
else
if roles[sel.index]==2
  roles[sel.index]=1
  sel.commandoptions[sel.index].sub!(_("Forum:opt_phr_moderator"),"")
else
  roles[sel.index]=2
  sel.commandoptions[sel.index].sub!(" "," (#{_("Forum:opt_phr_moderator")}) ")
end
speech(_("Forum:info_privileges"))
  end
                      }
                                        brm=true
                                        when 2
                                          if roles[sel.index]==1 or roles[sel.index]==3
                                            cat=""
                                            if roles[sel.index]==1
                                              if sgroups[@grpsel.index-grpheadindex].open
                                              cat="ban"
                                            else
                                              cat="kick"
                                              end
                                            else
                                              cat="unban"
                                            end
                                            confirm(s_("Forum:alert_user#{cat}", {'user'=>users[sel.index], 'groupname'=>sgroups[@grpsel.index-grpheadindex].name})) {
                      r=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=user\&pr=#{cat}\&user=#{users[sel.index]}\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}")
                                            if r[0].to_i<0
  speech(_("General:error"))
else
if roles[sel.index]==3
  roles[sel.index]=1
else
  roles[sel.index]=3
  end
speech(_("Forum:info_privileges"))
                                          end
                                          }
                                        else
                                                                                      confirm(s_("Forum:alert_passadmin", {'user'=>users[sel.index], 'groupname'=>sgroups[@grpsel.index-grpheadindex].name})) {
                      r=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=privileges\&pr=passadmin\&user=#{users[sel.index]}\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}")
                                            if r[0].to_i<0
  speech(_("General:error"))
else
sgroups[@grpsel.index-grpheadindex].founder=users[sel.index]
  sel.commandoptions[sel.index].sub!(" "," (#{_("Forum:opt_phr_founder")}) ")
  for i in 0...users.size
    sel.commandoptions[i].sub!(_("Forum:opt_phr_founder"),"") if users[i]==$name
    end
  speech(_("Forum:info_privileges"))
end
}
                                            end
                                          brm = true
                when 3
                  br=true
                                  end
                end
                if alt or escape or br or brm
                  play("menu_close")
                  Audio.bgs_stop
                  break
                  end
                end
                end
                            end
                          end
                          when 3
                            u=input_text(_("Forum:type_invite"), "ACCEPTESCAPE")
                            if u!="\004ESCAPE\004"
                                                          u=finduser(u) if u.downcase==finduser(u).downcase
                            if user_exist(u)==false
                              speech(_("Forum:error_usernotfound"))
                              speech_wait
                              else
                                                          r=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=invite\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}\&user=#{u}")
                                                          case r[0].to_i
                                                          when 0
                                                            speech(_("Forum:info_invited"))
                                                            when -1
                                                              speech(_("General:error_db"))
                                                              when -2
                                                                speech(_("General:error_tokenexpired"))
                                                                when -3
                                                                  speech(_("General:error_permissions"))
                                                                  when -4
                                                                    speech(_("Forum:error_usernotfound"))
                                                                    when -5
                                                                      speech(_("Forum:error_useralreadyingroup"))
                                                                    end
                                                                    speech_wait
                            end
                          end
                          loop_update
                          @grpsel.focus
                          when 4
              confirm(s_("Forum:alert_join", {'groupname'=>sgroups[@grpsel.index-grpheadindex].name})) {
              g=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=join\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}")
              if g[0].to_i==0
                speech(_("Forum:info_joined"))
                sgroups[@grpsel.index-grpheadindex].role=1
              else
                speech(_("General:error"))
                end
              }
              speech_wait
            @grpsel.focus
            when 5
              confirm(s_("Forum:alert_leave", {'groupname'=>sgroups[@grpsel.index-grpheadindex].name})) {
              g=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=leave\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}")
              if g[0].to_i==0
                speech(_("Forum:info_left"))
                sgroups[@grpsel.index-grpheadindex].role=0
              else
                speech(_("General:error"))
                end
              }
                        speech_wait
            @grpsel.focus
        when 6
                          @grpindex[type]=@grpsel.index
                getcache
        return groupsmain
            when 7
          $scene=Scene_Main.new
          return
          when 8
            newgroup
            when 9
              g=sgroups[@grpsel.index-grpheadindex]
                              fields=[Edit.new(_("Forum:type_groupname"),"",g.name,true), Edit.new(_("Forum:type_groupdescription"),"multiline",g.description,true), Select.new([_("Forum:opt_grouptypehidden"),_("Forum:opt_grouptypepublic")],true,g.public.to_i,_("Forum:head_grouptype"),true),Select.new([_("Forum:opt_groupjointypeopen"),_("Forum:opt_groupjointypemoderated")],true,g.open.to_i,_("Forum:head_groupjointype"),true),nil,Button.new(_("General:str_cancel"))]
                              if g.recommended
                                fields[2].disable_item(0)
                                fields[3].disable_item(0)
                                end
          form=Form.new(fields)
          loop do
            loop_update
            form.update
            if form.fields[4]==nil and form.fields[0].text!=""
              form.fields[4]=Button.new(_("General:str_save"))
            elsif form.fields[4]!=nil and form.fields[0].text==""
              form.fields[4]=nil
            end
            case form.fields[2].index
                            when 0
                              form.fields[3].commandoptions=[_("Forum:opt_groupjointypeclosed"),_("Forum:opt_groupjointypemoderated")]
                                          when 1
                            form.fields[3].commandoptions=[_("Forum:opt_groupjointypemoderated"),_("Forum:opt_groupjointypeopen")]
            end
            if form.fields[4]!=nil and form.fields[4].pressed?
                                                        r=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=edit\&groupid=#{g.id.to_s}\&groupname=#{form.fields[0].text.urlenc}\&bufdescription=#{buffer(form.fields[1].text).to_s}\&public=#{form.fields[2].index.to_s}\&open=#{form.fields[3].index.to_s}")
                                          if r[0].to_i<0
                                            speech(_("General:error"))
                                          else
                                            speech(_("General:info_saved"))
                                          end
                                          speech_wait
                                          getcache
                                          return groupsmain(@lastlist)
                                                        end
            break if escape or form.fields[5].pressed?
          end
          loop_update
            when 10
              confirm(s_("Forum:alert_deletegroup", {'groupname'=>sgroups[@grpsel.index-grpheadindex].name})) {
              if srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=delete\&groupid=#{sgroups[@grpsel.index-grpheadindex].id.to_s}")[0].to_i<0
                speech(_("General:error"))
              else
                speech(_("Forum:info_groupdeleted"))
              end
              speech_wait
              getcache
              return groupsmain(type)
              }
        end
      end
      if type==0
                if escape
        $scene=Scene_Main.new
        return
      end
    else
      if escape or (Input.trigger?(Input::LEFT) and !$key[0x10])
        return groupsmain(0)
        end
      end
      end
    end
    def newgroup
      ln=[]
      lnindex=0
      for lk in $langs.keys
        l=$langs[lk]
        ln.push(l['name']+" ("+l['nativeName']+")")
        lnindex=ln.size-1 if $language.downcase[0..1]==lk.downcase[0..1]
        end
                fields=[Edit.new(_("Forum:type_groupname"),"","",true), Edit.new(_("Forum:type_groupdescription"),"multiline","",true), Select.new(ln,true,lnindex,_("Forum:head_language"),true), Select.new([_("Forum:opt_grouptypehidden"),_("Forum:opt_grouptypepublic")],true,0,_("Forum:head_grouptype"),true),Select.new([_("Forum:opt_groupjointypeopen"),_("Forum:opt_groupjointypemoderated")],true,0,_("Forum:head_groupjointype"),true),nil,Button.new(_("General:str_cancel"))]
          form=Form.new(fields)
          loop do
            loop_update
            form.update
            if form.fields[5]==nil and form.fields[0].text!=""
              form.fields[5]=Button.new(_("Forum:btn_groupcreate"))
            elsif form.fields[5]!=nil and form.fields[0].text==""
              form.fields[5]=nil
            end
            case form.fields[3].index
                            when 0
                              form.fields[4].commandoptions=[_("Forum:opt_groupjointypeclosed"),_("Forum:opt_groupjointypemoderated")]
                                          when 1
                            form.fields[4].commandoptions=[_("Forum:opt_groupjointypemoderated"),_("Forum:opt_groupjointypeopen")]
            end
            if form.fields[5]!=nil and form.fields[5].pressed?
                                          r=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=create\&groupname=#{form.fields[0].text.urlenc}\&bufdescription=#{buffer(form.fields[1].text).to_s}\&lang=#{$langs.keys[form.fields[2].index].to_s}\&public=#{form.fields[3].index.to_s}\&open=#{form.fields[4].index.to_s}")
                                          if r[0].to_i<0
                                            speech(_("General:error"))
                                          else
                                            speech(_("Forum:info_groupcreated"))
                                          end
                                          speech_wait
                                          getcache
                                          return groupsmain(@lastlist)
                                                        end
            break if escape or form.fields[6].pressed?
          end
          loop_update
      end
    def forumsmain(group=-1)
      group=@lastgroup if group==-1
      group=0 if group==-1
      @lastgroup=group
      sforums=[]
      if group>=0
              for f in @forums
        sforums.push(f) if f.group.id==group
      end
    elsif group==-5
            for f in @forums
        sforums.push(f) if f.followed
      end
      end
      frmselt=[]
           for forum in sforums
                  ftm=[forum.fullname]
if group==-5
for g in @groups
    ftm[0]+=" (#{g.name}) " if g.id==forum.group.id
  end
  end
    ftm+=[forum.threads.to_s, forum.posts.to_s, (forum.posts-forum.readposts).to_s]
    ftm[0]+="\004NEW\004" if forum.posts-forum.readposts>0
                  frmselt.push(ftm)
              end
      @frmindex=0 if @frmindex==nil
      frmselh=[nil, _("Forum:opt_phr_threads"), _("Forum:opt_phr_posts"), _("Forum:opt_phr_unreads")]
      @frmsel=TableSelect.new(frmselh,frmselt,@frmindex,_("Forum:head_selforum"))
      loop do
        loop_update
        @frmsel.update
        if (Input.trigger?(Input::LEFT) and !$keyr[0x10]) or escape
          @frmindex=nil
          return groupsmain
        end
        if alt
          mns=[_("Forum:opt_open"),_("Forum:opt_followforum"),_("Forum:opt_markforumasread"),_("General:str_refresh"),_("General:str_cancel")]
          mns[1]=_("Forum:opt_unfollowforum") if sforums.size>0 and sforums[@frmsel.index].followed==true
          mns=[nil,nil,nil,_("General:str_refresh"),_("General:str_cancel")] if @frmsel.commandoptions.size==0
          groupclass=Struct_Forum_Group.new
          @groups.each {|g| groupclass=g if g.id==group}
          if groupclass.founder==$name or groupclass.role==2
          mns+=[_("Forum:opt_newforum")]
          if sforums.size>0
          mns+=[_("Forum:opt_editforum"),_("Forum:opt_changeforumpos")]
          mns.push(_("Forum:opt_deleteforum")) if sforums[@frmsel.index].posts==0
        end
        end
          case menuselector(mns)
          when 0
            @frmindex=@frmsel.index
          return threadsmain(sforums[@frmsel.index].name)
          when 1
            if sforums[@frmsel.index].followed==false
                if srvproc("forum_ft","name=#{$name}\&token=#{$token}\&add=2\\&forum=#{sforums[@frmsel.index].name}")[0].to_i<0
  speech(_("General:error"))
else
  speech(_("Forum:info_forumfollowed"))
  sforums[@frmsel.index].followed=true
  end
else
  if srvproc("forum_ft","name=#{$name}\&token=#{$token}\&remove=2\\&forum=#{sforums[@frmsel.index].name}")[0].to_i<0
    speech(_("General:error"))
  else
    speech(_("Forum:info_forumunfollowed"))
        sforums[@frmsel.index].followed=false
        if id==-1
          speech_wait
      return groupsmain(id)
          end
    end
  end
  if group==-5
    speech_wait
        return forumsmain(group)
      end
      when 2
        confirm(_("Forum:alert_markforumasread")) do
          if srvproc("forum_markasread","name=#{$name}\&token=#{$token}\&forum=#{sforums[@frmsel.index].name}")[0].to_i==0
            for t in @threads
              t.readposts=t.posts if t.forum.name==sforums[@frmsel.index].name
            end
            sforums[@frmsel.index].readposts=sforums[@frmsel.index].posts
            @frmsel.commandoptions[@frmsel.index].gsub!("\004NEW\004","")
            @frmsel.commandoptions[@frmsel.index].gsub!(/#{_("Forum:opt_phr_unreads")}\: (\d+)/,"#{_("Forum:opt_phr_unreads")}: 0")
                        speech(_("Forum:info_forummarkedasread"))
                        speech_wait
          else
            speech(_("General:error"))
            speech_wait
            end
          end
  when 3
            @frmindex=@frmsel.index
            return forumsmain(group)
            when 4
              $scene=Scene_Main.new
              return
              when 5
                newforum
                getcache
                return forumsmain(group)
                when 6
                  form=Form.new([Edit.new(_("Forum:type_forumname"),"",sforums[@frmsel.index].fullname,true), Edit.new(_("Forum:type_forumdescription"),"multiline",sforums[@frmsel.index].description,true), nil, Button.new(_("General:str_cancel"))])
                  loop do
                    loop_update
                    form.update
                    if form.fields[2]==nil and form.fields[0].text!=""
                      form.fields[2]=Button.new(_("General:str_save"))
                    elsif form.fields[2]!=nil and form.fields[0].text==""
                      form.fields[2]=nil
                    end
                    if form.fields[2]!=nil and form.fields[2].pressed?
                                    u="ac=forumedit\&forum=#{sforums[@frmsel.index].name.urlenc}\&forumname=#{form.fields[0].text.urlenc}"
              if form.fields[1].text!=""
                b=buffer(form.fields[1].text)
                u+="\&bufforumdescription=#{b.to_s}"
              end
              f=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&#{u}")
              if f[0].to_i<0
                speech(_("General:error"))
              else
                speech(_("General:info_saved"))
              end
              speech_wait
              getcache
                return forumsmain(group)
                      end
                    break if escape or form.fields[3].pressed?
                  end
                  loop_update
                  @frmsel.focus
                  when 7
                    selt=[]
                    sforums.each {|f| selt.push(f.fullname)}
                    ind=selector(selt+[_("Forum:opt_changeforumposend")],_("Forum:head_changeforumpos"),0,-1)
                    if ind!=-1
                      r=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=forumchangepos\&forum=#{sforums[@frmsel.index].name}\&position=#{ind.to_s}")
                      if r[0].to_i<0
                        speech(_("General:error"))
                      else
                        speech(_("General:info_saved"))
                      end
                      speech_wait
                      getcache
                      return forumsmain(group)
                    else
                      @frmsel.focus
                      end
                when 8
                  confirm(_("Forum:alert_deleteforum")) {
                                    f=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&ac=forumdelete\&forum=#{sforums[@frmsel.index].name}")
                  if f[0].to_i<0
                    speech(_("General:error"))
                  else
                    speech(_("Forum:info_forumdeleted"))
                  end
                  speech_wait
                  getcache
                return forumsmain(group)
                }
                          end
          end
                if (enter or (Input.trigger?(Input::RIGHT) and !$keyr[0x10])) and sforums.size>0
          @frmindex=@frmsel.index
          return threadsmain(sforums[@frmsel.index].name)
          end
          end
        end
        def newforum
          fields=[Edit.new(_("Forum:type_forumname"),"","",true), Edit.new(_("Forum:type_forumdescription"),"multiline","",true), Select.new([_("Forum:opt_forumtypetext"),_("Forum:opt_forumtypevoice")],true,0,_("Forum:head_forumtype"),true),nil,Button.new(_("General:str_cancel"))]
          form=Form.new(fields)
          loop do
            loop_update
            form.update
            if form.fields[3]==nil and form.fields[0].text!=""
              form.fields[3]=Button.new(_("Forum:btn_forumcreate"))
            elsif form.fields[3]!=nil and form.fields[0].text==""
              form.fields[3]=nil
            end
            if form.fields[3]!=nil and form.fields[3].pressed?
              groupclass=Struct_Forum_Group.new
              @groups.each {|g| groupclass=g if g.id==@lastgroup}
              u="ac=forumcreate\&groupid=#{groupclass.id.to_s}\&forumname=#{fields[0].text.urlenc}\&forumtype=#{form.fields[2].index.to_s}"
              if form.fields[1].text!=""
                b=buffer(form.fields[1].text)
                u+="\&bufforumdescription=#{b.to_s}"
              end
              f=srvproc("forum_groups","name=#{$name}\&token=#{$token}\&#{u}")
              if f[0].to_i<0
                speech(_("General:error"))
              else
                speech(_("Forum:info_forumcreated"))
              end
              speech_wait
              break
              end
            break if escape or form.fields[4].pressed?
            end
          end
    def threadsmain(id)
      @forum=id
      index=@lastthreadindex
      @lastthreadindex=nil
      index=0 if index==nil
      @forumtype=0
      for forum in @forums
        @forumtype=forum.type if forum.name==id
        end
      sthreads=[]
      if id==-7
                  mnt=srvproc("mentions","name=#{$name}\&token=#{$token}\&list=1")
          @mentions=[]
          if mnt[0].to_i==0
t=0
for m in mnt[1..mnt.size-1]
  case t
  when 0
@mentions.push(Struct_Forum_Mention.new(m.to_i))
t+=1
when 1
  @mentions.last.author=m.delete("\r\n")
t+=1
when 2
  @mentions.last.thread=m.to_i
  t+=1
  when 3
    @mentions.last.post=m.to_i
    t+=1
    when 4
      @mentions.last.message=m.delete("\r\n")
                  t=0
end
end
end
        end
      for t in @threads
                case id
        when -7
                                     for mention in @mentions
   if t.id==mention.thread
     t.mention=mention
     sthreads.push(t)
     end
    end
             when -6
        folfor=[]
        for forum in @forums
          folfor.push(forum.name) if forum.followed==true
          end
          sthreads.push(t) if folfor.include?(t.forum.name) and t.readposts<t.posts
                when -4
        folfor=[]
        for forum in @forums
          folfor.push(forum.name) if forum.followed==true
          end
          sthreads.push(t) if folfor.include?(t.forum.name) and t.readposts==0
          when -3
          sthreads.push(t) if @results.include?(t.id) and t.forum.group.recommended or t.forum.group.role==1 or t.forum.group.role==2
        when -2
        sthreads.push(t) if t.followed==true and t.readposts<t.posts
          when -1
          sthreads.push(t) if t.followed==true
          when 0
            sthreads.push(t)
          else
                    sthreads.push(t) if t.forum.name==id
      end
    end
        if id==-2 and sthreads.size==0
      speech(_("Forum:info_nonewfollowedthr"))
      speech_wait
      return $scene=Scene_WhatsNew.new
      end
      if id==-4 and sthreads.size==0
      speech(_("Forum:info_nonewfollowedforumsthreads"))
      speech_wait
      return $scene=Scene_WhatsNew.new
      end
      if id==-6 and sthreads.size==0
      speech(_("Forum:info_nonewfollowedforumsposts"))
      speech_wait
      return $scene=Scene_WhatsNew.new
    end
    if id==-7 and sthreads.size==0
      speech(_("Forum:info_nonewmentions"))
      speech_wait
      return $scene=Scene_WhatsNew.new
    end  
    index=sthreads.size-1 if index>=sthreads.size
      thrselt=[]
      for i in 0..sthreads.size-1
        thread=sthreads[i]
        index=i if thread.id==@pre
        tmp=[thread.name]
                tmp[0]+="\004INFNEW{#{_("Forum:opt_phr_thrisnew")}: }\004" if thread.readposts<thread.posts and (id!=-2 and id!=-4 and id!=-6 and id!=-7)
        if id==-7
          tmp[0]+=" . #{_("Forum:opt_phr_mentionedby")}: #{thread.mention.author} (#{thread.mention.message})"
        end
        if id==-3
          tmp[0]+=" (#{thread.forum.fullname}, #{thread.forum.group.name})"
          end
                tmp+=[thread.author.lore, thread.posts.to_s, (thread.posts-thread.readposts).to_s]
                thrselt.push(tmp)
        end
      @pre=nil
      @preparam=nil
            header=_("Forum:head_selthr")
      header="" if id==-2 or id==-4 or id==-6 or id==-7
      thrselh = [nil, _("Forum:opt_phr_author"), _("Forum:opt_phr_posts"), _("Forum:opt_phr_unreads")]
      @thrsel=TableSelect.new(thrselh,thrselt,index,header)
      loop do
        loop_update
        @thrsel.update
        if (Input.trigger?(Input::LEFT) and !$keyr[0x10]) or escape
          if id.is_a?(String)
            return forumsmain 
          elsif id==-2 or id==-4 or id==-6 or id==-7
            return $scene=Scene_WhatsNew.new
            else
            return groupsmain
          end
        end
        if enter or (Input.trigger?(Input::RIGHT) and !$keyr[0x10]) and sthreads.size>0
if @lastgroup==-5
          $scene=Scene_Forum_Thread.new(sthreads[@thrsel.index],-5,@query)
        else
          if id==-7
            $scene=Scene_Forum_Thread.new(sthreads[@thrsel.index],id,@query,sthreads[@thrsel.index].mention)
            else
          $scene=Scene_Forum_Thread.new(sthreads[@thrsel.index],id,@query)
          end
          end
break
return
          end
        if alt
          mselt=[_("Forum:opt_open"),_("Forum:opt_followthr"),_("Forum:opt_newthr"),_("General:str_refresh"),_("General:str_cancel")]
          group=Struct_Forum_Group.new
          for f in @forums
            group=f.group if f.name==id
            end
          mselt[2]=nil if id.is_a?(String)==false or (@noteditable and group.recommended==1) or (group.role==0 and group.open==false) or group.role==3
          if sthreads.size==0
            mselt[0]=nil
            mselt[1]=nil
          else
            mselt[1]=_("Forum:opt_unfollowthr") if sthreads[@thrsel.index].followed==true
            mselt+=[_("Forum:opt_movethr"),_("Forum:opt_rename"),_("Forum:opt_deletethr")] if ($rang_moderator==1&&sthreads[@thrsel.index].forum.group.recommended)||sthreads[@thrsel.index].forum.group.role==2
                          end
          case menuselector(mselt)
          when 0
            $scene=Scene_Forum_Thread.new(sthreads[@thrsel.index],id)
            break
            return
            when 1
              if sthreads[@thrsel.index].followed==false
                if srvproc("forum_ft","name=#{$name}\&token=#{$token}\&add=1\\&thread=#{sthreads[@thrsel.index].id}")[0].to_i<0
  speech(_("General:error"))
else
  speech(_("Forum:info_thrfollowed"))
  sthreads[@thrsel.index].followed=true
  end
else
  if srvproc("forum_ft","name=#{$name}\&token=#{$token}\&remove=1\\&thread=#{sthreads[@thrsel.index].id}")[0].to_i<0
    speech(_("General:error"))
  else
    speech(_("Forum:info_thrunfollowed"))
        sthreads[@thrsel.index].followed=false
        if id==-1
          speech_wait
      return threadsmain(id)
          end
    end
  end
  when 2
    newthread
    getcache
    return threadsmain(id)
  when 3
    @pre=sthreads[@thrsel.index].id              
    getcache
                  return threadsmain(id)
                  when 4
                    $scene=Scene_Main.new
                    return
                    when 5
selt=[]
ind=0
mforums=[]
for f in @forums
  mforums.push(f) if f.group.role==2 or ($rang_moderator==1&&f.group.recommended)
  end
  for f in mforums
      selt.push(f.fullname+" ("+f.group.name+")")
  ind=i if forum.name==sthreads[@thrsel.index].forum.name
  end
destination=selector(selt,_("Forum:head_movethrlocation"),ind,-1)
if destination!=-1
  if srvproc("forum_mod","name=#{$name}\&token=#{$token}\&move=1\&threadid=#{sthreads[@thrsel.index].id}\&destination=#{mforums[destination].name}")[0].to_i<0
    speech(_("General:error"))
  else
        speech(_("Forum:info_threadmoved"))
getcache  
@lastthreadindex=@thrsel.index
        speech_wait
        return threadsmain(id)
      end
        end
                      when 6
                        name=input_text(_("Forum:type_thrnewname"),"ACCEPTESCAPE",sthreads[@thrsel.index].name)
                        if name!="\004ESCAPE\004"
                          if srvproc("forum_mod","name=#{$name}\&token=#{$token}\&rename=1\&threadid=#{sthreads[@thrsel.index].id}\&threadname=#{name.urlenc}")[0].to_i<0
                            speech(_("General:error"))
                          else
                            speech(_("Forum:info_renamed"))
getcache  
@lastthreadindex=@thrsel.index
                            speech_wait
                            return threadsmain(id)
                                                        end
                          end
                        when 7
                          confirm(s_("Forum:alert_thrdelete", {'thrname'=>sthreads[@thrsel.index].name})) do
                          if srvproc("forum_mod","name=#{$name}\&token=#{$token}\&delete=1\&threadid=#{sthreads[@thrsel.index].id}")[0].to_i<0
                            speech(_("General:error"))
                          else
                            speech(_("Forum:info_thrdeleted"))
getcache  
@lastthreadindex=@thrsel.index
                            speech_wait
                            return threadsmain(id)
                          end
                          end
          end
          end
                end
      end
def newthread
                              fields = []
                            thread=text = ""
                            rectitlest=recpostst=0
forums=[]
forumclasses=[]
forumindex=0
                            for g in @groups
                              for f in @forums
                                if f.type==@forumtype
                                if f.group.id==g.id
                                  forums.push(f.fullname+" (#{g.name})")
                                forumclasses.push(f)
                                forumindex=forums.size-1 if f.name==@forum
                                                              end
                                end
                                end
                              end
                            if @forumtype == 0                            
                                                          fields = [Edit.new(_("Forum:type_thrname"),"","",true), Edit.new(_("Forum:type_postcontent"),"MULTILINE","",true), CheckBox.new(_("Forum:opt_followthr")), Select.new(forums,true,forumindex,_("Forum:head")), nil, Button.new(_("General:str_cancel"))]
                                                         fields[6] = Edit.new(_("Forum:type_nick"),"","",true) if $rang_moderator == 1 or $rang_developer == 1
                                                       else
                                                         fields = [Edit.new(_("Forum:type_thrname"),"","",true), Button.new(_("Forum:btn_recpost")), nil, CheckBox.new(_("Forum:opt_followthr")), Select.new(forums,true,forumindex,_("Forum:head")), nil, Button.new(_("General:str_cancel"))]
                                                       end
                                                                                                               form = Form.new(fields)
                                                         loop do
                                                          loop_update
                                                          if @forumtype == 0 and (form.fields[0].text!="" and form.fields[1].text!="")
                                                            form.fields[4]=Button.new(_("Forum:btn_send"))
                                                          elsif @forumtype == 0
                                                            form.fields[4]=nil
                                                          end
                                                          form.update
                                                          if @forumtype == 0            
                                                          if ($key[0x11] == true or form.index == 4) and enter
                                                                        play("list_select")
                                                                                                                                                thread = form.fields[0].text_str
                                                                        text = form.fields[1].text_str
                                                                        break
                                                                      end
                                                                    else
                                                       if (enter or space) and form.index == 1
                                                       if recpostst == 0 or recpostst == 2
                                                                          play("recording_start")
                                                                          recording_start("temp/audiothreadpost.wav")
                                                                          form.fields[1]=Button.new(_("Forum:btn_recpoststop"))
                                                                          recpostst=1
                                                                          form.fields[2]=nil
                                                                        elsif recpostst == 1
                                                                          recording_stop
                                                                            play("recording_stop")
                                                                            recpostst=2
                                                                            form.fields[1]=Button.new(_("Forum:btn_recagain"))
                                                                            form.fields[2]=Button.new(_("Forum:btn_playpost"))
fields[5]=Button.new(_("Forum:btn_send"))
                                                                            end                                                                            
                                                                      end
                                                       player("temp/audiothreadpost.wav","",true) if (enter or space) and form.index == 2 and recpostst == 2
                                                                      if (enter or space) and form.index==5
                                                                        if recpostst==1
                                                                          play("recording_stop")
                                                                        recording_stop
                                                                      end
                                                                      break
                                                                        end
                                                       end
                                                                      if escape or (((form.index == 6 and @forumtype>=1) or (form.index==5 and @forumtype==0)) and enter)
                                                                        recording_stop if @rectitlest==1 or @recpostst==1
                                                                        loop_update
                                                                        return
                                                                        break
                                                                        end
                              end
                              if @forumtype == 0                          
                                                              buf = buffer(text).to_s
                            addtourl=""
                                                              addtourl = "\&uselore=1\&lore=#{form.fields[6].text_str}" if form.fields[6] != nil
                                                              addtourl += "&follow=1" if form.fields[2].checked==1
                            ft = srvproc("forum_edit","name=" + $name + "&token=" + $token + "&forumname=" + forumclasses[form.fields[3].index].name + "&threadname=" + thread.urlenc + "&buffer=" + buf + addtourl)
                          else
                            waiting
                                          speech(_("Forum:wait_converting"))
            File.delete("temp/audiothreadpost.opus") if FileTest.exists?("temp/audiothreadpost.opus")
      executeprocess("bin\\ffmpeg.exe -y -i \"temp\\audiothreadpost.wav\" -b:a 96K temp/audiothreadpost.opus",true)
        flp=read("temp/audiothreadpost.opus")
                                boundary=""
        boundary="----EltBoundary"+rand(36**32).to_s(36) while flp.include?(boundary)
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{flp}\r\n--#{boundary}--"
    length=data.size    
            host = $srv.delete("/")
    q = "POST /srv/forum_edit.php?name=#{$name}\&token=#{$token}\&threadname=#{form.fields[0].text_str.urlenc}\&forumname=#{forumclasses[form.fields[4].index].name.urlenc}\&audio=1\&follow=#{form.fields[3].checked.to_s} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
a = connect(host,80,q).delete("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech(_("General:error"))
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = strbyline(sn)
ft = bt[1].to_i
waiting_end
end
if ft[0].to_i == 0
  speech(_("Forum:info_thrcreated"))
else
  speech(_("General:error_thrcreation"))
end
speech_wait
end
def getcache
  #return agetcache
  c=srvproc("forum_struct","name=#{$name}\&token=#{$token}",1).split("\r\n")
  if c[0].to_i<0
    speech(_("General:error"))
    @groups=[]
    @forums=[]
    @threads=[]
    $scene=Scene_Main.new
    return
    end
  l=1
  while l<c.size
    objs=c[l+1].to_i
    strobjs=c[l+2].to_i
            if c[l]=="groups"
            groupscache(c[(l+3)..(l+3+objs*strobjs)],objs,strobjs)
          elsif c[l]=="forums"
            forumscache(c[(l+3)..(l+3+objs*strobjs)],objs,strobjs)
          elsif c[l]=="threads"
            threadscache(c[(l+3)..(l+3+objs*strobjs)],objs,strobjs)
    end
    l+=3+objs*strobjs
  end
    end
  def groupscache(c,objs,strobjs)
    @groups=[]
        for i in 0...objs
      for j in 0...strobjs
                line=c[i*strobjs+j]
        case j
        when 0
          @groups.push(Struct_Forum_Group.new(line.to_i))
          when 1
            @groups.last.name=line
            when 2
              @groups.last.founder=line
              when 3
                @groups.last.description=line.gsub("$","\r\n")
                when 4
                  @groups.last.lang=line
                  when 5
                  @groups.last.recommended=true if line.to_i==1
                  when 6
                    @groups.last.open=true if line.to_i==1
                    when 7
                      @groups.last.public=true if line.to_i==1
                      when 8
                        @groups.last.role=line.to_i
                                                when 9
                          @groups.last.forums=line.to_i
                          when 10
                            @groups.last.threads=line.to_i
                            when 11
                              @groups.last.posts=line.to_i
                              when 12
                                @groups.last.readposts=line.to_i
                              end
        end
      end
    end
  def forumscache(c,objs,strobjs)
        @forums=[]
        for i in 0...objs
      for j in 0...strobjs
                line=c[i*strobjs+j]
        case j
        when 0
          @forums.push(Struct_Forum_Forum.new(line))
          when 1
            @forums.last.fullname=line
            when 2
              @forums.last.type=line.to_i
              when 3
                @groups.each {|g| @forums.last.group=g if g.id==line.to_i}
                when 4
                  @forums.last.description=line.gsub("$","\r\n")
                  when 5
                    @forums.last.followed=true if line.to_i>0
                    when 6
                      @forums.last.threads=line.to_i
                      when 7
                        @forums.last.posts=line.to_i
                        when 8
                          @forums.last.readposts=line.to_i
      end
    end
  end
end
  def threadscache(c,objs,strobjs)
    @threads=[]
        for i in 0...objs
      for j in 0...strobjs
                line=c[i*strobjs+j]
        case j
        when 0
          @threads.push(Struct_Forum_Thread.new(line.to_i))
          when 1
            @threads.last.name=line
            when 2
              @threads.last.author=line
            when 3
              @forums.each {|f| @threads.last.forum=f if f.id==line}
              when 4
                @threads.last.followed=true if line.to_i>0
                when 5
                  @threads.last.posts=line.to_i
                  when 6
                    @threads.last.readposts=line.to_i
      end
    end
  end
  end
    def agetcache
c=srvproc("forum_list","name=#{$name}\&token=#{$token}")
if c[0].to_i<0
  speech(_("General:error"))
  return $scene=Scene_Main.new
  end
@cache=c
@time=c[1].to_i
index=0
@tgroups=[]
@tforums=[]
@tthreads=[]
t=0
for i in 2..c.size-1
o=c[i].delete("\r\n")
if o=="\004GROUPS\004"
t=1
elsif o=="\004FORUMS\004"
t=2
elsif o=="\004THREADS\004"
t=3
else
case t
when 1
@tgroups.push(c[i])
when 2
@tforums.push(c[i])
when 3
@tthreads.push(c[i])
end
end
end
@groups=[]
t=0
for l in @tgroups
case t
when 0
@groups.push(Struct_Forum_Group.new(l.to_i))
when 1
@groups.last.name=l.delete("\r\n")
when 2
@groups.last.forums=l.to_i
when 3
@groups.last.threads=l.to_i
when 4
@groups.last.posts=l.to_i
when 5
@groups.last.readposts=l.to_i
      end
t+=1
t=0 if t==6
end
@forums=[]
t=0
for l in @tforums
case t
when 0
@forums.push(Struct_Forum_Forum.new(l.delete("\r\n")))
when 1
@forums.last.fullname=l.delete("\r\n")
when 2
g=nil
for gr in @groups
  g=gr if l.to_i==gr.id
end
  @forums.last.group=g
when 3
@forums.last.type=l.to_i
when 4
@forums.last.threads=l.to_i
when 5
@forums.last.posts=l.to_i
when 6
@forums.last.readposts=l.to_i
when 7
  @forums.last.followed=l.to_b
end
t+=1
t=0 if t==8
end
@threads=[]
t=0
for l in @tthreads
case t
when 0
@threads.push(Struct_Forum_Thread.new(l.to_i))
when 1
@threads.last.name=l.delete("\r\n")
when 2
f=nil
for fr in @forums
  f=fr if fr.name==l.delete("\r\n")
end
f=Struct_Forum_Forum.new(l.delete("\r\n")) if f==nil
  @threads.last.forum=f
when 3
@threads.last.posts=l.to_i
when 4
@threads.last.author=l.delete("\r\n")
when 5
@threads.last.readposts=l.to_i
when 6
@threads.last.followed=l.to_b
when 7
@threads.last.lastupdate=l.to_i
end
t+=1
t=0 if t==8
end
end
def getstruct
  getcache
  return {'groups'=>@groups,'forums'=>@forums,'threads'=>@threads}
  end
end

class Scene_Forum_Thread
  def initialize(thread,param=nil,query="",mention=nil)
            @threadclass=thread
    @param=param
        @query=query
    @mention=mention
    @thread=@threadclass.id
    srvproc("mentions","name=#{$name}\&token=#{$token}\&notice=1\&id=#{mention.id}") if mention!=nil
    end
  def main
    #return $scene=Scene_Main.new if $eltsuspend
    if $name=="guest"
            @noteditable=true
            else
          @noteditable=isbanned($name)
          @noteditable=true if (@threadclass.forum.group.role==0 and @threadclass.forum.group.open==false) or @threadclass.forum.group.role==3
          end
    getcache
        index=-1
    @fields=[]
    for i in 0..@posts.size-1
      post=@posts[i]
      index=i if index==-1 and @param==-3 and post.post.downcase.include?(@query.downcase)
      index=i if @mention!=nil and @param==-7 and post.id==@mention.post
      @fields.push(Edit.new(post.authorname,"MULTILINE|READONLY",post.post+post.signature+post.date+"\r\n"+(i+1).to_s+"/"+@posts.size.to_s,true))
    end
    index=0 if index==-1
    index=@lastpostindex if @lastpostindex!=nil
    @type=0
    @type=1 if @posts.size>0 and @posts[0].post.include?("\004AUDIO\004")
    if @noteditable==false
    case @type
    when 0
      @fields+=[Edit.new(_("Forum:type_reply"),"MULTILINE","",true),nil,nil]
    else
      @fields+=[Button.new(_("Forum:btn_recnewpost")),nil,nil]
    end
  else
    @fields+=[nil,nil,nil]
    end
    @fields.push(Button.new(_("Forum:btn_back")))
    @form=Form.new(@fields,index)
    loop do
      loop_update
      @form.update
      navupdate
      if @noteditable==false
      case @type
      when 0
        textsendupdate
        when 1
          audiosendupdate
          end
      end
      menu if alt    
      if escape or ((space or enter) and @form.index==@fields.size-1)
        $scene=Scene_Forum.new(@thread,@param,@query)
        return
        end
      break if $scene!=self
        end
  end
  def navupdate
    if $key[0x11] and !$key[0x12]
      if $key[0xbc]
        @form.index=0
        @form.focus
      elsif $key[0xbe]
        @form.index=@postscount-1
        @form.focus
      elsif $key[0x44] and @type==0 and @form.index<@postscount and @noteditable==false
        @form.fields[@postscount].settext("\r\n--Cytat (#{@posts[@form.index].authorname}):\r\n#{@posts[@form.index].post}\r\n--Koniec cytatu\r\n#{@form.fields[@postscount].text_str}")
                @form.fields[@postscount].index=0
        @form.index=@postscount
        @form.focus
      elsif $key[0x4A]
        selt=[]
          for i in 0..@posts.size-1
    selt.push((i+1).to_s+" z "+@postscount.to_s+": "+@posts[i].author)
    end
  dialog_open
    @form.index=selector(selt,_("Forum:head_selpost"),@form.index,@form.index)
    dialog_close
  @form.focus         
        elsif $key[0x4e] and @noteditable==false
          @form.index=@postscount
          @form.focus
          elsif $key[0x55] and @readposts<@postscount
            @form.index=@readposts
            @form.focus
          end
          end
        end
        def textsendupdate
                    if @form.fields[@postscount].text=="" and @form.fields[@postscount+2]!=nil
                        @form.fields[@postscount+2]=nil
          elsif @form.fields[@postscount].text!="" and @form.fields[@postscount+2]==nil
            @form.fields[@postscount+2]=Button.new(_("Forum:btn_send"))
          end
          if ((enter or space) and @form.index==@postscount+2) or (enter and $key[0x11] and @form.index==@postscount)
            buf = buffer(@form.fields[@postscount].text_str).to_s
            st=srvproc("forum_edit","name=#{$name}&token=#{$token}\&threadid=#{@thread.to_s}\&buffer=#{buf}")
if st[0].to_i<0
  speech(_("General:error"))
else
  speech(_("Forum:info_postcreated"))
end
speech_wait
return main
            end
        end
        def audiosendupdate
         @recording = 0 if @recording == nil
           if (enter or space) and @form.index==@form.fields.size-4
             if @recording==0 or @recording==2
                 @recording=1
    recording_start("temp/audiopost.wav")
    play("recording_start")
    @form.fields[@form.fields.size-4]=Button.new(_("Forum:btn_recstop"))
    @form.fields[@form.fields.size-3]=nil
      elsif @recording == 1
    recording_stop
    play("recording_stop")
    @form.fields[@form.fields.size-4]=Button.new(_("Forum:btn_recagain"))
    @form.fields[@form.fields.size-3]=Button.new(_("Forum:btn_play"))
    @form.fields[@form.fields.size-2]=Button.new(_("Forum:btn_sendaudio"))
    @recording = 2
             end
           end
             player("temp/audiopost.wav","",true) if (enter or space) and @form.index == @form.fields.size-3
             if (enter or space) and @form.index == @form.fields.size-2 and @recording == 2
                   if @recording == 1
      play("recording_stop")
      recording_stop
    end
waiting
speech(_("Forum:wait_converting"))
      File.delete("temp/audiopost.opus") if FileTest.exists?("temp/audiopost.opus")
      executeprocess("bin\\ffmpeg.exe -y -i \"temp\\audiopost.wav\" -b:a 96K temp/audiopost.opus",true)
      speech(_("Forum:wait_postsendpreparation"))
        data = ""
                        fl = read("temp/audiopost.opus")
            host = $srv
                   boundary=""
                boundary="----EltBoundary"+rand(36**32).to_s(36) while fl.include?(boundary)
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
      q = "POST /srv/forum_edit.php?name=#{$name}\&token=#{$token}\&threadid=#{@thread.to_s}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
      a = connect(host,80,q).delete("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
return speech(_("General:error")) if s==nil
  sn = a[s..a.size - 1]
          ft = strbyline(sn)
                waiting_end
                if ft[0].to_i == 0
  speech(_("Forum:info_postcreated"))
else
  speech(_("Forum:error_postcreation"))
end
speech_wait
return main
               end
             end
def menu
  play("menu_open")
  play("menu_background")
  cat=0
  sel=["#{_("Forum:opt_phr_author")}",_("Forum:opt_reply"),_("Forum:opt_navigation"),_("Forum:opt_mention"),_("Forum:opt_listen"),_("Forum:opt_followthr"),_("General:str_refresh"),_("General:str_cancel")]
    sel.push(_("Forum:opt_moderation")) if @form.index<@postscount && ((($rang_moderator==1&&@threadclass.forum.group.recommended)||(@threadclass!=nil&&@threadclass.forum.group.role==2)) || (@posts[@form.index].author==$name))
  sel[5]=_("Forum:opt_unfollowthr") if @followed==true
  sel[0]=@posts[@form.index].authorname if @form.index<@postscount
  index=0
  index=1 if @form.index>=@postscount
  @menu=@origmenu=menulr(sel,true,index,"",true)
  @menu.disable_item(0) if @form.index>=@postscount
  @menu.disable_item(3) if @form.index>=@postscount
  @menu.disable_item(5) if @form.index>=@posts.size
  @menu.focus
  res=-1
  loop do
    loop_update
@menu.update
 if enter or (Input.trigger?(Input::DOWN) and cat==0 and @menu.index!=3 and @menu.index!=4 and @menu.index!=5 and @menu.index!=6)
   case cat
   when 0
    case @menu.index
    when 0
           if usermenu(@posts[@form.index].author,true)=="ALT"
        break
      else
        if $scene==self
        @menu.focus
        loop_update
      else
        break
      end
            end
            when 1
      if @form.index>=@postscount
        res=4
        break
        else
        cat=1
        @menu=menulr([_("Forum:opt_reply"),_("Forum:opt_quote")])
        @menu.disable_item(1) if @type==1
      end
      when 2
        ls=[_("Forum:opt_gotopost"),_("Forum:opt_searchthr"),_("Forum:opt_gotofirst"),_("Forum:opt_gotolast")]
        ls.push(_("Forum:opt_gotounread")) if @readposts<@postscount
        cat=2
        @menu=menulr(ls)
        @menu.disable_item(1) if @type==1
        when 3
          res=15
          break
when 4
  res=16
  break
          when 5
          res=1
        break
                        when 6
                    res=2
        break
                    when 7
          res=3
        break
          when 8
          cat=3
          ls=[_("Forum:opt_edit")]
          ls+=[_("Forum:opt_movepost"),_("Forum:opt_deletepost"),_("Forum:opt_slidepost")] if $rang_moderator==1 or @threadclass.forum.group.role==2
          @menu=menulr(ls,true,0,"",false)
          @menu.disable_item(0) if @type==1
          @menu.focus
        end
                when 1
res=4+@menu.index          
break
                  when 2
res=6+@menu.index
break
            when 3
            res=11+@menu.index
            break
              end
            end
 if Input.trigger?(Input::UP) and cat>0
   cat=0
   @menu=@origmenu
   @menu.focus
   end
 if alt or escape
   break
   end
    end
  play("menu_close")
  Audio.bgs_fade(100)
  case res
  when 1
                  if @followed==false
                if srvproc("forum_ft","name=#{$name}\&token=#{$token}\&add=1\\&thread=#{@thread}")[0].to_i<0
  speech(_("General:error"))
else
  speech(_("Forum:info_thrfollowed"))
  @followed=true
  end
else
  if srvproc("forum_ft","name=#{$name}\&token=#{$token}\&remove=1\\&thread=#{@thread}")[0].to_i<0
    speech(_("General:error"))
  else
    speech(_("Forum:info_thrunfollowed"))
        @followed=false
    end
  end
    when 2
      return main
      when 3
      return $scene=Scene_Forum.new(@thread,@param)
      when 4
        @form.index=@postscount
        @form.focus
        when 5
          @form.fields[@postscount].settext("\r\n--Cytat (#{@posts[@form.index].authorname}):\r\n#{@posts[@form.index].post}\r\n--Koniec cytatu\r\n#{@form.fields[@postscount].text_str}")
                @form.fields[@postscount].index=0
        @form.index=@postscount
        @form.focus
          when 6
            selt=[]
          for i in 0..@posts.size-1
    selt.push((i+1).to_s+" z "+@postscount.to_s+": "+@posts[i].author)
    end
  dialog_open
    @form.index=selector(selt,_("Forum:head_selpost"),@form.index,@form.index)
    dialog_close
  @form.focus         
            when 7
                           search=input_text(_("Forum:type_searchphrase"),"ACCEPTESCAPE")
                           if search!="\004ESCAPE\004"
              selt=[]
          sr=[]
          ind=-1
          for i in 0..@posts.size-1
    if @posts[i].post.downcase.include?(search.downcase)
      selt.push((i+1).to_s+" z "+@postscount.to_s+": "+@posts[i].author)
      sr.push(i)
      ind=selt.size-1 if i>=@form.index and ind==-1
      end
    end
  ind=0 if ind==-1
    if selt.size>0
    dialog_open
    ind=selector(selt,_("Forum:head_selpost"),ind,-1)
    @form.index=sr[ind] if ind!=-1
        dialog_close
  @form.focus         
else
  speech(_("Forum:error_phrasenotfound"))
    end
  end
    when 8
                @form.index=0
                @form.focus
                when 9
                  @form.index=@postscount-1
                  @form.focus
                  when 10
                    @form.index=@readposts
                    @form.focus
                    when 11
dialog_open
                      form=Form.new([Edit.new(_("Forum:type_editpost"),"MULTILINE",@posts[@form.index].post),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
                      loop do
                        loop_update
                        form.update
                        if form.fields[0].text_str.size>1 and (((enter or space) and form.index==1) or (enter and $key[0x11] and form.index<2))
                          buf=buffer(form.fields[0].text_str)
if srvproc("forum_mod","name=#{$name}\&token=#{$token}\&edit=1\&postid=#{@posts[@form.index].id.to_s}\&threadid=#{@thread.to_s}\&buffer=#{buf}")[0].to_i<0
  speech(_("General:error"))
else
  speech(_("Forum:info_postmodified"))
  speech_wait
  dialog_close
  @lastpostindex=@form.index
  return main
  end
                          end
                        break if escape or ((enter or space) and form.index==2)
                                                  end
                      dialog_close
                        when 12
                          @struct=Scene_Forum.new.getstruct
                          @groups=@struct['groups']
                          @forums=@struct['forums']
                          @threads=@struct['threads']
                          groups=[]
for group in @groups
  groups[group.id]=group.name
end
forums={}
forumsgroups={}
selt=[]
mthreads=[]
curr=0
for t in @threads
  mthreads.push(t) if t.forum.group.role==2 or ($rang_moderator==1 and t.forum.group.recommended)
  end
for t in mthreads
  selt.push(t.name+" ("+t.forum.fullname+" ("+t.forum.group.name+")"+")")
  curr=selt.size-1 if t.id==@thread
end
destination=selector(selt,_("Forum:head_movepostlocation"),curr,-1)
if destination!=-1
    if srvproc("forum_mod","name=#{$name}\&token=#{$token}\&move=2\&postid=#{@posts[@form.index].id}\&destination=#{mthreads[destination].id}\&threadid=#{@thread}")[0].to_i<0
    speech(_("General:error"))
  else
    speech(_("Forum:info_postmoved"))
        @lastpostindex=@form.index
    speech_wait
    return main
    end
  end
when                        13
                                                    confirm(_("Forum:alert_Deletepost")) do
                                                      prm=""
                                                      if @posts.size==1
                                                      prm="name=#{$name}\&token=#{$token}\&threadid=#{@thread}\&delete=1"
                                                    else
                                                      prm="name=#{$name}\&token=#{$token}\&postid=#{@posts[@form.index].id}\&threadid=#{@thread}\&delete=2"
                                                    end
                                                    if srvproc("forum_mod",prm)[0].to_i<0
                                                      speech(_("General:error"))
                                                    else
                                                      speech(_("Forum:info_postdeleted"))
                                                      speech_wait
                                                      if @posts.size==1
                                                        $scene=Scene_Forum.new(@thread,@param,@query)
                                                      else
                                                                                                                @lastpostindex=@form.index
                                                        return main
                                                      end
                                                    end
                                                    end
                                                    when 14
                                                      sels=[]
                                                      for post in @posts
                                                        sels.push((sels.size+1).to_s+": "+post.author+": "+post.date)
                                                                                                              end
                                                      dest=selector(sels,_("Forum:head_postslidewith"),@form.index,-1)
                                                      if dest!=-1
                                                        if srvproc("forum_mod","name=#{$name}\&token=#{$token}\&move=3\&source=#{@posts[@form.index].id.to_s}\&destination=#{@posts[dest].id.to_s}")[0].to_i==0
                                                          speech(_("Forum:info_postslided"))
                                                        else
                                                          speech(_("General:error"))
                                                        end
                                                        speech_wait
                                                        @posts[@form.index],@posts[dest]=@posts[dest],@posts[@form.index]
                                                        @form.fields[@form.index],@form.fields[dest]=@form.fields[dest],@form.fields[@form.index]
                                                        @form.focus
                                                        end
                                                    when 15
                                                        users=[]
                                                        us=srvproc("contacts_addedme","name=#{$name}\&token=#{$token}")
                                                        if us[0].to_i<0
                                                          speech(_("General:error"))
                                                          speech_wait
                                                          return
                                                        end
                                                        for u in us[1..us.size-1]
                                                          users.push(u.delete("\r\n"))
                                                        end
                                                        if users.size==0
                                                          speech(_("Forum:info_noonecontactedyou"))
                                                          speech_wait
                                                          return
                                                        end
                                                        form=Form.new([Select.new(users,true,0,"Użytkownik"),Edit.new(_("Forum:info_message"),"","",true),Button.new(_("Forum:opt_mention")),Button.new(_("General:str_cancel"))])
                                                        loop do
                                                          loop_update
                                                          form.update
                                                          if escape or ((enter or space) and form.index==3)
                                                            loop_update
                                                            @form.focus
                                                            break
                                                          end
                                                          if (enter or space) and form.index==2
                                                            mt=srvproc("mentions","name=#{$name}\&token=#{$token}\&add=1\&user=#{users[form.fields[0].index]}\&message=#{form.fields[1].text_str}\&thread=#{@thread}\&post=#{@posts[@form.index].id}")
                                                            if mt[0].to_i<0
                                                              speech(_("General:error"))
                                                            else
                                                              speech(_("Forum:info_mentionsent"))
                                                              speech_wait
                                                              @form.focus
                                                              break
                                                              end
                                                            end
                                                          end
                                                                                        when 16
                                if $voice==-1 and @type==0
                                  text=""
                                  for pst in @posts[@form.index..@posts.size]
                                    text+=pst.author+"\r\n"+pst.post+"\r\n"+pst.date+"\r\n\r\n"
                                  end
                                  speech(text)
                                else
                                  speech_wait
                                  cur=@form.index-1
                                  while cur<@posts.size
                                    loop_update
                                    if speech_actived==false and Win32API.new("screenreaderapi","sapiIsPaused",'','i').call==0
                                      cur+=1
                                    play("signal")
                                    pst=@posts[cur]
                                    speech("#{(cur+1).to_s}: "+pst.author+":\r\n"+pst.post) if pst!=nil
                                                                     end
                                  if (Input.trigger?(Input::RIGHT) and !$keyr[0x10])
                                    speech_stop
                                    cur=@posts.size-2 if cur>@posts.size-2
                                    end
                                    if (Input.trigger?(Input::LEFT) and !$keyr[0x10])
                                      speech_stop
                                      cur-=2
                                      cur=-1 if cur<-1
                                      end
                                                                     if space
                                    if Win32API.new("screenreaderapi","sapiIsPaused",'','i').call==0
                                      Win32API.new("screenreaderapi","sapiSetPaused",'i','i').call(1)
                                    else
                                      Win32API.new("screenreaderapi","sapiSetPaused",'i','i').call(0)
                                      end
                                    end
                                    if escape
                                      speech_stop
                                                                            break
                                      end
                                    end
                                  loop_update
                                    @form.focus
                                    end
                                                        end
  loop_update  
  end
  def getcache
    c=srvproc("forum_thread","name=#{$name}\&token=#{$token}\&thread=#{@thread.to_s}")
        return if c[0].to_i<0
    @cache=c
    @cachetime=c[1].to_i
    @postscount=c[2].to_i
    @readposts=c[3].to_i
    @followed=c[4].to_b
    @posts=[]
t=0
    for l in c[5..c.size-1]
      case t
      when 0
        break if l.to_i==0
        @posts.push(Struct_Forum_Post.new(l.to_i))
        t+=1
        when 1
          @posts.last.author=l.delete("\r\n").maintext
          @posts.last.authorname=l.delete("\r\n").lore
          t+=1
          when 2
            if l.delete("\r\n")=="\004END\004"
              t+=1
            else
              @posts.last.post+=l
            end
            when 3
              @posts.last.date=l.delete("\r\n")
              t+=1
              when 4
               if l.delete("\r\n")=="\004END\004"
              t=0
            else
              @posts.last.signature+=l
            end 
      end
    end
    
    end
  end
  
class Struct_Forum_Group
                            attr_accessor :id
                            attr_accessor :name
                            attr_accessor :forums
                            attr_accessor :threads
                            attr_accessor :posts
                            attr_accessor :readposts
                            attr_accessor :lang
                            attr_accessor :role
                            attr_accessor :open
                            attr_accessor :public
                            attr_accessor :recommended
                            attr_accessor :description
                            attr_accessor :founder
                            def initialize(id=0)
                              @id=id
                              @name=""
                              @forums=0
                              @threads=0
                              @posts=0
                              @readposts=0
                              @role=0
                              @open=false
                              @public=false
                              @recommended=false
                              @description=""
                              @founder=""
                            end
                            end
                          
                                class Struct_Forum_Forum
                                  attr_accessor :name
                                  attr_accessor :group
                                  attr_accessor :fullname
                                  attr_accessor :threads
                                  attr_accessor :posts
                                  attr_accessor :type
                                  attr_accessor :readposts
                                  attr_accessor :followed
                                  attr_accessor :description
                                  def initialize(name="")
                                    @name=name
                                    @group=Struct_Forum_Group.new(0)
                                    @fullname=""
                                    @posts=0
                                    @threads=0
                                    @type=0
                                    @readposts=0
                                    @followed=false
                                    @description=""
                                  end
                                  def id
                                    return @name
                                  end
                                  def id=(id)
                                    @name=id
                                    end
                                  end
                                  
                                  class Struct_Forum_Thread
                                    attr_accessor :id
                                    attr_accessor :name
                                    attr_accessor :posts
                                    attr_accessor :readposts
                                    attr_accessor :author
                                    attr_accessor :followed
                                    attr_accessor :lastupdate
                                    attr_accessor :forum
                                    attr_accessor :mention
                                    def initialize(id=0,name="")
                                      @id=id
                                      @name=name
                                      @posts=0
                                      @readposts=0
                                      @author=""
                                      @followed=false
                                    @lastupdate=0
                                    @forum=""  
                                    end\
                                  end
                                  
                                  class Struct_Forum_Post
                                    attr_accessor :id
                                    attr_accessor :author
                                    attr_accessor :post
                                    attr_accessor :authorname
                                                                        attr_accessor :signature
                                                                        attr_accessor :date
                                    def initialize(id=0)
                                      @id=id
                                      @author=""
                                      @post=""
                                      @authorname=""
                                                                            @signature=""
                                    @date=""
                                                                            end
                                                                          end
                                                                          class Struct_Forum_Mention
                                                                            attr_accessor :id
                                                                            attr_accessor :author
                                                                            attr_accessor :thread
                                                                            attr_accessor :post
                                                                            attr_accessor :message
                                                                            def initialize(id=0)
                                                                              @id=id
                                                                              @thread=0
                                                                              @post=0
                                                                              @message=0
                                                                              @author=""
                                                                            end
                                                                            end
#Copyright (C) 2014-2019 Dawid Pieper