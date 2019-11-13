#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Notes
  def main(index=0)
    if $name=="guest"
      speech(_("General:error_guest"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
  nt=srvproc("notes",{"get"=>"1"})
  if nt[0].to_i<0
    speech(_("General:error"))
    speech_wait
    $scene=Scene_Main.new
    return
    end
  t=0
  @notes=[]
  d=0
  for i in 2..nt.size-1
        case t
    when 0
      @notes[d]=Struct_Note.new(nt[i].to_i)
      t+=1
      when 1
     @notes[d].name=nt[i].delete("\r\n")
     t+=1
     when 2
       @notes[d].author=nt[i].delete("\r\n")
     t+=1
     when 3
     @notes[d].created=Time.at(nt[i].delete("\r\n").to_i)
     t+=1
     when 4
     @notes[d].modified=Time.at(nt[i].delete("\r\n").to_i)
     t+=1
     when 5
       if nt[i].delete("\r\n")=="\004END\004"
         t=0
         d+=1
       else
         @notes[d].text+=nt[i]
         end
    end
  end
  selt=[]
  for n in @notes
    selt.push(n.name+"\r\n#{_("Notes:opt_phr_author")}: "+n.author+"\r\n#{_("Notes:opt_phr_modified")}: "+sprintf("%04d-%02d-%02d %02d:%02d",n.modified.year,n.modified.month,n.modified.day,n.modified.hour,n.modified.min))
  end
  selt.push(_("Notes:opt_new"))
  @sel=Select.new(selt,true,index,_("Notes:head"))
  loop do
    loop_update
    @sel.update
    $scene=Scene_Main.new if escape
    if enter
      if @sel.index==@notes.size
        $scene=Scene_Notes_New.new
      else
        dialog_open
        show(@notes[@sel.index])
        dialog_close
        @sel.focus if @refresh!=true
        end
              end
          menu if alt and @sel.index<@notes.size
              if $key[0x2e] and @sel.index<@notes.size and @notes[@sel.index].author==$name
      delete(@notes[@sel.index])
      end
              if @refresh == true
                    @refresh = false
                    main(@sel.index)
                    return
          end
      break if $scene!=self
    end
  end
  def menu
    play("menu_open")
    play("menu_background")
        note=@notes[@sel.index]
    @menu=menulr([_("Notes:opt_read"),_("Notes:opt_edit"),_("General:str_delete"),_("General:str_cancel")])
    @menu.disable_item(2) if note.author!=$name
    loop do
      loop_update
      @menu.update
      break if escape or alt
      if enter
        Audio.bgs_stop
        case @menu.index
        when 0
          show(note)
          when 1
            show(note,true)
            when 2
              delete(note)
              when 3
                $scene=Scene_Main.new
            end
            break
      end
      end
    play("menu_close")
      Audio.bgs_stop
            end
  def show(note,edit=false)
    id=note.id
    shares=[]
nt=srvproc("notes",{"getshares"=>"1", "noteid"=>id})
if nt[0].to_i<0
  speech(_("General:error"))
  speech_wait
    return
end
if nt.size>1
for t in nt[1..nt.size-1]
  sh=t.delete("\r\n")
  sh=note.author if sh==$name
  shares.push(sh)
end
end
sharest=shares+[]
sharest.push(_("Notes:btn_add")) if note.author==$name
@fields=[Edit.new(note.name,"MULTILINE|READONLY",note.text,true),Button.new(_("Notes:opt_edit")),Select.new(sharest,true,0,_("Notes:head_sharedwith"),true),nil,Button.new(_("General:str_cancel"))]
@form=Form.new(@fields)
if edit == true
@form.fields[0].flags=Edit::Flags::MultiLine
@form.fields[1]=Button.new(_("General:str_save"))
end
@form.fields[3]=Button.new(_("General:str_delete")) if note.author==$name
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index==4)
break
return
    end
  if ((enter or space) and @form.index==1)
    if edit == false
    edit=true
    @form.fields[0].flags=Edit::Flags::MultiLine
    @form.index=0
    @form.fields[0].focus
    @form.fields[1]=Button.new(_("General:str_save"))
  else
    text=@form.fields[0].text_str
    bufid=buffer(text)
    nt=srvproc("notes",{"edit"=>"1", "buffer"=>bufid, "noteid"=>note.id})
                if nt[0].to_i<0
          speech(_("General:error"))
        else
          speech(_("Notes:info_notemodified"))
          speech_wait
          @refresh=true
          break
          end
    end
        end
  if enter and @form.index==2 and @form.fields[2].index==shares.size
    dialog_open
    inpt=Edit.new(_("Notes:type_sharenotewith"))
    loop do
      loop_update
      inpt.update
      if escape
        dialog_close
        break
        end
      inpt.settext(selectcontact) if Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN)
      if enter
        user=inpt.text_str.delete("\r\n").gsub("\004LINE\004","")
                user=finduser(user) if finduser(user).upcase==user.upcase
                if user_exist(user) == false
          speech(_("Notes:error_usernotfound"))
        else
          nt=srvproc("notes",{"noteid"=>note.id, "addshare"=>"1", "user"=>user})
          if nt[0].to_i<0
            speech(_("General:error"))
            speech_wait
          else
            speech(s_("Notes:info_sharedwith",{'user'=>user}))
            speech_wait
            shares.push(user)
            sharest=shares+[_("Notes:btn_add")]
            @form.fields[2].commandoptions=sharest
            dialog_close
            break
            end
          end
        end
    end
    loop_update
  end
if $key[0x2e] and @form.index==2 and note.author==$name and @form.fields[2].index<shares.size
  if simplequestion(s_("Notes:alert_unshare",{'user'=>@form.fields[2].commandoptions[@form.fields[2].index]}))==1
  user=shares[@form.fields[2].index]
            nt=srvproc("notes",{"noteid"=>note.id, "delshare"=>"1", "user"=>user})
          if nt[0].to_i<0
            speech(_("General:error"))
            speech_wait
          else
            speech(s_("Notes:info_unsharedwith",{'user'=>user}))
                        shares.delete(user)
            sharest=shares+[_("Notes:btn_add")]
@form.fields[2].index-=1
@form.fields[2].index=0 if @form.fields[2].index<0
            @form.fields[2].commandoptions=sharest
            speech_wait
          end
        end
        @form.fields[2].focus
  end
if (enter or space) and @form.index==3
  if delete(note) == true
break
else
  @form.fields[3].focus
  end
  end
  
    end
        end
def delete(note)
  id=note.id
  if simplequestion(s_("Notes:alert_delete", {'name' => note.name})) == 0
    return false
  else
    nt=srvproc("notes",{"delete"=>"1", "noteid"=>id})
    if nt[0].to_i<0
      speech(_("General:error"))
      speech_wait
      return false
    end
    speech(_("Notes:info_notedeleted"))
    @refresh=true
    speech_wait
    return true
        end
  end
        end

class Scene_Notes_New
  def main
    @fields=[Edit.new(_("Notes:type_title"),"","",true),Edit.new(_("Notes:type_content"),"MULTILINE","",true),Button.new(_("Notes:btn_add")),Button.new(_("General:str_cancel"))]
    @form=Form.new(@fields)
    btn=@form.fields[2]
    loop do
      loop_update
      if (@form.fields[0].text=="" or @form.fields[1].text=="") and @form.fields[2]!=nil
        btn=@form.fields[2]
        @form.fields[2]=nil
      elsif (@form.fields[0].text!="" and @form.fields[1].text!="") and @form.fields[2]==nil
        @form.fields[2]=btn
        end
      @form.update
      break if escape or ((enter or space) and @form.index==3)
      if ((enter or space) and @form.index==2)
        name=@form.fields[0].text_str
        text=@form.fields[1].text_str
        bufid=buffer(text)
        nt=srvproc("notes",{"create"=>"1", "notename"=>name, "buffer"=>bufid})
                if nt[0].to_i<0
          speech(_("General:error"))
        else
          speech(_("Notes:info_notecreated"))
          speech_wait
          break
          end
        end
    end
    $scene=Scene_Notes.new
  end
  end

class Struct_Note
attr_accessor :id
attr_accessor :name
attr_accessor :text
attr_accessor :author
attr_accessor :modified
attr_accessor :created
def initialize(id=0)
  @id=id
  @created=Time.now
  @modified=Time.now
  @author=$name
  @text=""
  @name=""
end
end
#Copyright (C) 2014-2019 Dawid Pieper