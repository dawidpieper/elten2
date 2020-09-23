#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Polls
  def initialize(lastpoll=0)
    @lastpoll=lastpoll
    end
  def main
    @sel=TableBox.new([nil, p_("Polls", "Author"), p_("Polls", "Votes"), nil], [], 0, p_("Polls", "Polls"), true)
@sel.bind_context{|menu|context(menu)}
@allpolls=[]
refresh
@polls=[]
polls_filter
@sel.focus
loop do
  loop_update
  @sel.update
  $scene=Scene_Main.new if escape
      if enter and @sel.options.size>0
                 selt=[p_("Polls", "Vote"),p_("Polls", "Show results")]
       if Session.name!="guest"
         v=srvproc("polls",{"voted"=>"1", "poll"=>@polls[@sel.index].id})
       if v[0].to_i<0
         alert(_("Error"))
         $scene=Scene_Main.new
         return
       end
       if v[1].to_i==1
         selt[0]=nil
end
       end         
       if Session.name=="guest"
         selt[0]=""
         end
         case menuselector(selt)
         when 0
           $scene=Scene_Polls_Answer.new(@polls[@sel.index].id)
           when 1
             $scene=Scene_Polls_Results.new(@polls[@sel.index].id)
         end
        end
  break if $scene!=self
  end
end
def refresh
    polls=srvproc("polls",{"list"=>1, "details"=>2})
if polls[0].to_i<0
  alert(_("Error"))
  $scene=Scene_Main.new
  return
end
t=0
@allpolls=[]
id=0
pl=0
for i in 2..polls.size-1
  case t
  when 0
    id=polls[i].to_i
    @allpolls[pl]=Struct_Poll.new(id)
    t+=1
    when 1
      @allpolls[pl].name=polls[i].delete("\r\n")
      t+=1
      when 2
        @allpolls[pl].author=polls[i].delete("\r\n")
        t+=1
        when 3
          @allpolls[pl].created=polls[i].to_i
        t+=1
        when 4
            @allpolls[pl].language=polls[i].delete("\r\n")
        t+=1
        when 5
          @allpolls[pl].voted=true if polls[i].to_i>0
        t+=1
        when 6
          @allpolls[pl].votes=polls[i].to_i
        t+=1
        when 7
          if polls[i].delete("\r\n")!="\004END\004"
        @allpolls[pl].description+=polls[i]
      else
        t=0
        pl+=1
        end
  end
end
      end
def polls_filter
  @lastpoll=@polls[@sel.index].id if @polls.is_a?(Array) and @polls.size>0
  @polls=[]
knownlanguages = Session.languages.split(",").map{|lg|lg.upcase}
for pl in @allpolls
  @polls.push(pl) if LocalConfig["PollsShowUnknownLanguages"]==1 || knownlanguages.size==0 || knownlanguages.include?(pl.language[0..1].upcase)
  end
selt=[]
index=0
for poll in @polls
if poll != nil
  selt.push([poll.name, poll.author, poll.votes.to_s, poll.description])
    index=selt.size-1 if poll.id==@lastpoll
  end
end
    @sel.rows=selt
    @sel.reload
    @sel.index=index
  end
def context(menu)
                  if @sel.options.size>0
                           if Session.name!="guest"
                             if !@polls[@sel.index].voted
         menu.option(p_("Polls", "Vote"), nil, "v") {
                    $scene=Scene_Polls_Answer.new(@polls[@sel.index].id)
                  }
                end
                end
         menu.option(p_("Polls", "Show results"), nil, "t") {
                      $scene=Scene_Polls_Results.new(@polls[@sel.index].id)
         }
         if Session.moderator==1 or @polls[@sel.index].author==Session.name
         menu.option(_("Delete"), nil, :del) {
                        if confirm(p_("Polls", "Do you really want to delete %{name}?")%{'name'=>@polls[@sel.index].name}) == 1
                 pl=srvproc("polls",{"del"=>"1", "id"=>@polls[@sel.index].id})
                 if pl[0].to_i<0
                   alert(_("Error"))
                 else
                   alert(p_("Polls", "deleted"))
                   refresh
                   polls_filter
                   @sel.focus
                 end
                 speech_wait
                 end
         }
         end
       end
       if Session.languages.size>0
         s=p_("Polls", "Show polls in unknown languages")
      s=p_("Polls", "Hide polls in unknown languages") if LocalConfig['PollsShowUnknownLanguages']==1
      menu.option(s) {
      l=1
      l=0 if LocalConfig['PollsShowUnknownLanguages']==1
      LocalConfig['PollsShowUnknownLanguages']=l
polls_filter
@sel.focus
      }
         end
         menu.option(p_("Polls", "New poll"), nil, "n") {
                        $scene = Scene_Polls_Create.new
         }
         menu.option(_("Refresh"), nil, "r") {
                                         $scene=Scene_Polls.new
         }
         end
end

class Scene_Polls_Create
  def main
      @ln = []
      ls=[]
    lnindex = 0
    for lk in Lists.langs.keys
      l = Lists.langs[lk]
      ls.push(l["name"] + " (" + l["nativeName"] + ")")
      @ln.push(lk)
      lnindex = @ln.size - 1 if Configuration.language.downcase[0..1] == lk.downcase[0..1]
    end
    @fields=[EditBox.new(p_("Polls", "Poll name"),"","",true),EditBox.new(p_("Polls", "Description"),EditBox::Flags::MultiLine,"",true),ListBox.new(ls, p_("Polls", "Poll language"), lnindex, 0, true),ListBox.new([p_("Polls", "New question")],p_("Polls", "Questions"),0,0,true),CheckBox.new(p_("Polls", "Hide this poll")),Button.new(p_("Polls", "Create")),Button.new(_("Cancel"))]
  @form=Form.new(@fields)
  @questions=[]
  loop do
    loop_update
    @form.update
    if $key[0x2E] and @form.index==3 and @fields[3].index<@fields[3].options.size-1
      @questions.delete_at(@fields[2].index)
      @fields[3].options.delete_at(@fields[3].index)
      play("edit_delete")
      @fields[3].sayoption
      end
    if escape
loop_update
               $scene=Scene_Polls.new
                   return
      break
    end
   if enter or (space and @form.index>4)
     loop_update
     case @form.index
     when 3
       q=@fields[3].index
       qs=@questions[q]
       @questions[q]=["",0] if @questions[q]==nil
       @qfields=[EditBox.new(p_("Polls", "Question"),"",@questions[q][0],true),ListBox.new([p_("Polls", "Single choice"),p_("Polls", "Multiple choice"),p_("Polls", "Edit box")],p_("Polls", "Question type"),@questions[q][1], 0, true),ListBox.new(@questions[q][2..@questions[q].size-1]+[p_("Polls", "New answer")],p_("Polls", "Answers"), 0, 0, true),Button.new(_("Save")),Button.new(_("Cancel"))]
       @qform=Form.new(@qfields)
              loop do
         loop_update
         @qform.update
         if @qfields[1].index<2 and @qfields[2]==nil
           @qfields[2]=ListBox.new(@questions[q][2..@questions[q].size-1]+[p_("Polls", "New answer")],p_("Polls", "Answers"),0,0,true)
         elsif @qfields[1].index==2 and @qfields[2]!=nil
           @qfields[2]=nil
           end
  if $key[0x2E] and @qform.index==2 and @qfields[2].index<@qfields[2].options.size-1
      @questions[q].delete_at(@qfields[2].index+2)
      @qfields[2].options.delete_at(@qfields[2].index)
      play("edit_delete")
      @qfields[2].sayoption
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
      @questions[q][2+@qfields[2].index]=input_text(p_("Polls", "Answer"),"",@questions[q][2+@qfields[2].index])
      @qfields[2].options=@questions[q][2..@questions[q].size-1]+[p_("Polls", "New answer")]
@qfields[2].focus      
when 3
  if @questions[q].size>3 or @qfields[1].index==2
  @questions[q][0]=@qfields[0].text
  @questions[q][1]=@qfields[1].index
  break
elsif @questions[q].size==2
  alert(p_("Polls", "There are no answers to this question"))
else
  alert(p_("Polls", "There is only one answer to this question."))
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
  @fields[3].options = qu+[p_("Polls", "New question")]
  @fields[3].focus
           when 5
             qus=JSON.generate(@questions)
dbuffer=buffer(@fields[1].text)
qbuffer=buffer(qus)
pl=srvproc("polls",{"create"=>"1", "qbuffer"=>qbuffer.to_s, "dbuffer"=>dbuffer.to_s, "pollname"=>@fields[0].text, "lng"=>@ln[@form.fields[2].index], "hide"=>@fields[4].checked.to_i})
if pl[0].to_i<0
  alert(_("Error"))
else
  alert(p_("Polls", "The poll has been created."))
  $scene=Scene_Polls.new
  return
  break
  end
       when 6
           $scene=Scene_Polls.new
           return
           break
     end
     end
    end
  end
  end

  class Scene_Polls_Answer
  def initialize(id,toscene=nil)
    @id=id
    @toscene=toscene
    end
  def main
pl=srvproc("polls", {"get"=>"1", "poll"=>@id.to_s})
if pl[0].to_i<0
  alert(_("Error"))
  if @toscene==nil
               $scene=Scene_Polls.new
             else
               $scene=@toscene
               end
  return
end
@name=pl[2].to_s.delete("\r\n")
@author=pl[3].to_s.delete("\r\n")
@created=Time.at(pl[4].to_i)
    @questions=JSON.load(pl[5].to_s.delete("\r\n").delete(";"))
    @description=""
  for i in 6..pl.size-1
    @description+=pl[i]
  end
  txt="#{@name}\r\n#{p_("Polls", "Author")}: #{@author}\r\n#{p_("Polls", "Created")}: #{format_date(@created, true)}\r\n\r\n#{@description}"
qs=[]
for q in @questions
  if q[1]==2
    qs.push(EditBox.new(q[0],"","",true))
  else
    comment=""
    if q[1]==0
      multi=false
      comment=p_("Polls", "Single choice question")
    else
      multi=true
      comment=p_("Polls", "Multiple choice question")
    end
    flags=0
    flags|=ListBox::Flags::MultiSelection if multi
        qs.push(ListBox.new(q[2..q.size-1],q[0]+" (#{comment}): ",0,flags,true))
    end
end
@fields=[EditBox.new(p_("Polls", "Poll"),EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly,txt,true)]+qs+[Button.new(p_("Polls", "Vote")),Button.new(_("Cancel"))]
@form=Form.new(@fields)
loop do
  loop_update
  @form.update
  if escape
    if @toscene==nil
               $scene=Scene_Polls.new(@id)
             else
               $scene=@toscene
               end
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
for j in 0..@form.fields[i].options.size-1
    ans+=(i-1).to_s+":"+j.to_s+"\r\n" if @form.fields[i].selected[j]==true
  end
  when 2
    ans+=(i-1).to_s+":"+@form.fields[i].text.gsub(";"," ").gsub(":"," ").delete("\r\n")+"\r\n" if @form.fields[i].text!=""
end
    end
    ans.chop!
    buf=buffer(ans)    
    pl=srvproc("polls", {"answer"=>1, "poll"=>@id.to_s, "buffer"=>buf.to_s})
    if pl[0].to_i<0
      alert(_("Error"))
    else
      alert(p_("Polls", "Your vote has been saved."))
      if @toscene==nil
               $scene=Scene_Polls.new(@id)
             else
               $scene=@toscene
               end
    return
    break
      end
  elsif @form.index==@form.fields.size-1
        if @toscene==nil
               $scene=Scene_Polls.new(@id)
             else
               $scene=@toscene
               end
    return
    break
    end
end

  end
    end
  end
  
  class Scene_Polls_Results
    def initialize(id,toscene=nil)
      @id=id
      @toscene=toscene
    end
    def main
      pl=srvproc("polls", {"get"=>"1", "poll"=>@id.to_s})
if pl[0].to_i<0
  alert(_("Error"))
  $scene=Scene_Polls.new
  return
end
@name=pl[2].to_s.delete("\r\n")
@author=pl[3].to_s.delete("\r\n")
@created=Time.at(pl[4].to_i)
    @questions=JSON.load(pl[5].to_s.delete("\r\n").delete(";"))
    @description=""
  for i in 6..pl.size-1
    @description+=pl[i]
  end
  txt="#{@name}\r\n#{p_("Polls", "Author")}: #{@author}\r\n#{p_("Polls", "Created")}: #{format_date(@created, true)}\r\n\r\n#{@description}\r\n"
     pl=srvproc("polls", {"results"=>"1", "poll"=>@id.to_s}) 
if pl[0].to_i<0
  alert(_("Error"))
  if @toscene==nil
               $scene=Scene_Polls.new
             else
               $scene=@toscene
               end
  return
end
txt+="#{p_("Polls", "The number of votes")}: #{pl[1]}\r\n"
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
input_text(p_("Polls", "Poll results: %{name}")%{'name' => @name},EditBox::Flags::ReadOnly,txt)
if @toscene==nil
               $scene=Scene_Polls.new(@id)
             else
               $scene=@toscene
               end
    end
    end
  
class Struct_Poll
  attr_accessor :id
  attr_accessor :name
  attr_accessor :author
  attr_accessor :description
  attr_accessor :created
  attr_accessor :voted
  attr_accessor :language
  attr_accessor :votes
    def initialize(id=0)
    @id=id
    @name=""
    @author=""
    @description=""
    @created=0
    @voted=false
    @language=""
    @votes=0
  end
end