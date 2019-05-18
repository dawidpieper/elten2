#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Polls
  def initialize(lastpoll=0)
    @lastpoll=lastpoll
    end
  def main
    polls=srvproc("polls","name=#{$name}\&token=#{$token}\&list=1")
if polls[0].to_i<0
  speech(_("General:error"))
  $scene=Scene_Main.new
  return
end
t=0
@polls=[]
id=0
pl=0
for i in 2..polls.size-1
  case t
  when 0
    id=polls[i].to_i
    @polls[pl]=Struct_Poll.new(id)
    t+=1
    when 1
      @polls[pl].name=polls[i].delete("\r\n")
      t+=1
      when 2
        @polls[pl].author=polls[i].delete("\r\n")
        t+=1
        when 3
          @polls[pl].created=polls[i].to_i
        t+=1
        when 4
          if polls[i].delete("\r\n")!="\004END\004"
        @polls[pl].description+=polls[i]
      else
        t=0
        pl+=1
        end
  end
end
selt=[]
for poll in @polls
if poll != nil
  selt.push("#{poll.name}\r\n#{_("Polls:opt_phr_author")}: #{poll.author}\r\n#{poll.description}")
  end
end
index=0
if @lastpoll != 0
for i in 0..@polls.size-1
  index=i if @polls[i].id==@lastpoll
      end
  end
@sel=Select.new(selt,true,index,_("Polls:head"))
loop do
  loop_update
  @sel.update
  $scene=Scene_Main.new if escape
      menu(true) if enter and @sel.commandoptions.size>0
    menu(false) if alt
  break if $scene!=self
  end
  end
def menu(kenter=false)
  play("menu_open")
         play("menu_background")
         loop_update
         sel=menulr([_("Polls:btn_vote"),_("Polls:opt_results"),_("General:str_delete"),_("Polls:opt_new"),_("General:str_refresh"),_("General:str_cancel")],true,0,"",true)
                  if kenter == true
sel.disable_item(2)
                    sel.disable_item(3)
         sel.disable_item(4)
         sel.disable_item(5)
       end
       if @sel.commandoptions.size>0
       if $name!="guest"
         v=srvproc("polls","name=#{$name}\&token=#{$token}\&voted=1\&poll=#{@polls[@sel.index].id}")
       if v[0].to_i<0
         speech(_("General:error"))
         speech_wait
         $scene=Scene_Main.new
         return
       end
       if v[1].to_i==1
         sel.index=1
         sel.disable_item(0)
                end
     if @polls[@sel.index].author!=$name and $rang_moderator==0
       sel.disable_item(2)
       end
       end         
       else
       sel.disable_item(0)
       sel.disable_item(1)
       sel.disable_item(2)
       end
       if $name=="guest"
         sel.index=1
         sel.disable_item(0)
         sel.disable_item(2)
         sel.disable_item(3)
         end
       sel.focus
       loop do
         loop_update
         sel.update
         if enter
           break
           end
         if alt or escape
           play("menu_close")
         Audio.bgs_stop
         return
         break
         end
         end
         case sel.index
         when 0
           $scene=Scene_Polls_Answer.new(@polls[@sel.index].id)
           when 1
             $scene=Scene_Polls_Results.new(@polls[@sel.index].id)
             when 2
               if simplequestion(s_("Polls:alert_delete", {'name'=>@polls[@sel.index].name})) == 1
                 pl=srvproc("polls","name=#{$name}\&token=#{$token}\&del=1\&id=#{@polls[@sel.index].id}")
                 if pl[0].to_i<0
                   speech(_("General:error"))
                 else
                   speech(_("Polls:info_deleted"))
                   @sel.disable_item(@sel.index)
                   @sel.focus
                 end
                 speech_wait
                 end
             when 3
               $scene = Scene_Polls_Create.new
               when 4
               $scene=Scene_Polls.new
               when 5
                 $scene=Scene_Main.new
         end
         play("menu_close")
         Audio.bgs_stop
  end
end

class Scene_Polls_Create
  def main
  @fields=[Edit.new(_("Polls:type_pollname"),"","",true),Edit.new(_("Polls:type_description"),"MULTILINE","",true),Select.new([_("Polls:opt_newquestion")],true,0,_("Polls:head_questions"),true),Button.new(_("Polls:btn_create")),Button.new(_("General:str_cancel"))]
  @form=Form.new(@fields)
  @questions=[]
  loop do
    loop_update
    @form.update
    if $key[0x2E] and @form.index==2 and @fields[2].index<@fields[2].commandoptions.size-1
      @questions.delete_at(@fields[2].index)
      @fields[2].commandoptions.delete_at(@fields[2].index)
      play("edit_delete")
      speech(@fields[2].commandoptions[@fields[2].index])
      end
    if escape
loop_update
      $scene=Scene_Polls.new
      return
      break
    end
   if enter
     loop_update
     case @form.index
     when 2
       q=@fields[2].index
       qs=@questions[q]
       @questions[q]=["",0] if @questions[q]==nil
       @qfields=[Edit.new(_("Polls:head_question"),"",@questions[q][0],true),Select.new([_("Polls:opt_singlechoice"),_("Polls:opt_multiplechoice"),_("Polls:opt_textfield")],true,@questions[q][1],_("Polls:head_answertype"),true),Select.new(@questions[q][2..@questions[q].size-1]+[_("Polls:opt_newanswer")],true,0,_("Polls:head_answers")),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))]
       @qform=Form.new(@qfields)
              loop do
         loop_update
         @qform.update
         if @qfields[1].index<2 and @qfields[2]==nil
           @qfields[2]=Select.new(@questions[q][2..@questions[q].size-1]+[_("Polls:opt_newanswer")],true,0,_("Polls:head_answers"),true)
         elsif @qfields[1].index==2 and @qfields[2]!=nil
           @qfields[2]=nil
           end
  if $key[0x2E] and @qform.index==2 and @qfields[2].index<@qfields[2].commandoptions.size-1
      @questions[q].delete_at(@qfields[2].index+2)
      @qfields[2].commandoptions.delete_at(@qfields[2].index)
      play("edit_delete")
      speech(@qfields[2].commandoptions[@qfields[2].index])
      end
           if escape
        @questions[q]=qs
  loop_update
    break
  end
  if enter
    loop_update
    case @qform.index
    when 2
            @questions[q][2+@qfields[2].index]="" if @questions[q][2+@qfields[2].index]==nil
      @questions[q][2+@qfields[2].index]=input_text(_("Polls:type_answer"),"",@questions[q][2+@qfields[2].index])
      @qfields[2].commandoptions=@questions[q][2..@questions[q].size-1]+[_("Polls:opt_newanswer")]
@qfields[2].focus      
when 3
  if @questions[q].size>3 or @qfields[1].index==2
  @questions[q][0]=@qfields[0].text_str
  @questions[q][1]=@qfields[1].index
  break
elsif @questions[q].size==2
  speech(_("Polls:error_noanswer"))
else
  speech(_("Polls:error_questiononeanswer"))
  end
        when 4
          @questions[q]=qs
          @questions.delete_at(q) if qs==nil
          break
    end
    end
           end
qu=[]
           for q in @questions
  qu.push(q[0]) if q!=nil
  end
  @fields[2].commandoptions = qu+[_("Polls:opt_newquestion")]
  @fields[2].focus
           when 3
qus="["
for q in @questions
  qus+="["
  for a in q
    if a.is_a?(Integer)
      qus+=a.to_s+","
    else
      qus+="\""+a.gsub("\"","\\\"")+"\","
      end
    end
      qus.chop!
        qus+="],"
  end
             qus.chop!
             qus+="]"
  qus.gsub!("\r\n","  ")
dbuffer=buffer(@fields[1].text_str)
qbuffer=buffer(qus)
pl=srvproc("polls","name=#{$name}\&token=#{$token}\&create=1\&qbuffer=#{qbuffer.to_s}\&dbuffer=#{dbuffer.to_s}\&pollname=#{@fields[0].text_str}")
if pl[0].to_i<0
  speech(_("General:error"))
  speech_wait
else
  speech(_("Polls:info_pollcreated"))
  speech_wait
  $scene=Scene_Polls.new
  return
  break
  end
       when 4
           $scene=Scene_Polls.new
           return
           break
     end
     end
    end
  end
  end

  class Scene_Polls_Answer
  def initialize(id)
    @id=id
    end
  def main
pl=srvproc("polls","name=#{$name}\&token=#{$token}\&get=1\&poll=#{@id.to_s}")
if pl[0].to_i<0
  speech(_("General:error"))
  speech_wait
  $scene=Scene_Polls.new
  return
end
@name=pl[2].to_s.delete("\r\n")
@author=pl[3].to_s.delete("\r\n")
begin
@created=Time.at(pl[4].to_i)
rescue Exception
  retry
  end
    @questions=JSON.load(pl[5].to_s.delete("\r\n").delete(";"))
    @description=""
  for i in 6..pl.size-1
    @description+=pl[i]
  end
  txt="#{@name}\r\n#{_("Polls:opt_phr_author")}: #{@author}\r\n#{_("Polls:txt_phr_created")}: #{sprintf("%04d-%02d-%02d",@created.year,@created.month,@created.day)}\r\n\r\n#{@description}"
qs=[]
for q in @questions
  if q[1]==2
    qs.push(Edit.new(q[0],"","",true))
  else
    comment=""
    if q[1]==0
      multi=false
      comment="Pytanie jednokrotnego wyboru"
    else
      multi=true
      comment="Pytanie wielokrotnego wyboru"
    end
        qs.push(Select.new(q[2..q.size-1],true,0,q[0]+" (#{comment}): ",true,multi))
    end
end
@fields=[Edit.new(_("Polls:read_poll"),"MULTILINE|READONLY",txt,true)]+qs+[Button.new(_("Polls:btn_vote")),Button.new(_("General:str_cancel"))]
@form=Form.new(@fields)
loop do
  loop_update
  @form.update
  if escape
    $scene=Scene_Polls.new(@id)
    return
    break
  end
if enter
  if @form.index==@form.fields.size-2
    ans=""
    for i in 1..@questions.size
case @questions[i-1][1]
when 0
  ans+=(i-1).to_s+":"+@form.fields[i].index.to_s+"\r\n"
  when 1
for j in 0..@form.fields[i].commandoptions.size-1
    ans+=(i-1).to_s+":"+j.to_s+"\r\n" if @form.fields[i].selected[j]==true
  end
  when 2
    ans+=(i-1).to_s+":"+@form.fields[i].text_str.gsub(";"," ").gsub(":"," ").delete("\r\n")+"\r\n" if @form.fields[i].text!=""
end
    end
    ans.chop!
    buf=buffer(ans)    
    pl=srvproc("polls","name=#{$name}\&token=#{$token}\&answer=1\&poll=#{@id.to_s}\&buffer=#{buf.to_s}")
    if pl[0].to_i<0
      speech(_("General:error"))
    else
      speech(_("Polls:info_voted"))
      speech_wait
      $scene=Scene_Polls.new(@id)
    return
    break
      end
  elsif @form.index==@form.fields.size-1
        $scene=Scene_Polls.new(@id)
    return
    break
    end
end

  end
    end
  end
  
  class Scene_Polls_Results
    def initialize(id)
      @id=id
    end
    def main
      pl=srvproc("polls","name=#{$name}\&token=#{$token}\&get=1\&poll=#{@id.to_s}")
if pl[0].to_i<0
  speech(_("General:error"))
  speech_wait
  $scene=Scene_Polls.new
  return
end
@name=pl[2].to_s.delete("\r\n")
@author=pl[3].to_s.delete("\r\n")
begin
@created=Time.at(pl[4].to_i)
rescue Exception
  retry
  end
  @questions=JSON.load(pl[5].to_s.delete("\r\n").delete(";"))
    @description=""
  for i in 6..pl.size-1
    @description+=pl[i]
  end
  txt="#{@name}\r\n#{_("Polls:opt_phr_author")}: #{@author}\r\n#{_("Polls:txt_phr_created")}: #{sprintf("%04d-%02d-%02d",@created.year,@created.month,@created.day)}\r\n\r\n#{@description}\r\n"
     pl=srvproc("polls","name=#{$name}\&token=#{$token}\&results=1\&poll=#{@id.to_s}") 
if pl[0].to_i<0
  speech(_("General:error"))
  speech_wait
  $scene=Scene_Polls.new(@id)
  return
end
txt+="#{_("Polls:txt_phr_votes")}: #{pl[1]}\r\n"
@votes=pl[1].to_i
@answers=[]
for i in 2..pl.size-1
  q,a=pl[i].delete("\r\n").split(":")
  q=q.to_i
    @answers[q]=[] if @answers[q]==nil
  a=a.to_i if @questions[q][1]<2
    @answers[q].push(a)
end
for q in 0..@questions.size-1
  if @answers[q]!=nil
  txt+=@questions[q][0].to_s+"\r\n"
if @questions[q][1]<2
  a=a.to_i
 for i in 2..@questions[q].size-1
   a=i-2
pr=(@answers[q].count(a).to_f/@votes.to_f*100.0).to_i
txt+=@questions[q][i]+": "+pr.to_s+"%\r\n"
   end
else
  for a in @answers[q]
    txt+=": "+a+"\r\n"
    end
end  
end
txt+="\r\n\r\n"
  end
input_text(s_("Polls:read_results",{'name' => @name}),"READONLY",txt)
$scene=Scene_Polls.new(@id)
    end
    end
  
class Struct_Poll
  attr_accessor :id
  attr_accessor :name
  attr_accessor :author
  attr_accessor :description
  attr_accessor :created
    def initialize(id=0)
    @id=id
    @name=""
    @author=""
    @description=""
    @created=0
  end
end
#Copyright (C) 2014-2018 Dawid Pieper