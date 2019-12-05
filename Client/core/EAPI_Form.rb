#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

      module EltenAPI
  # Controls and forms related class
  module Controls
    # A form class  
    class Form
      # @return   [Numeric] a form index
      attr_accessor :index
      # @return [Array] an array of form fields
        attr_accessor :fields
        # Creates a form
        #
        # @param fields [Array] an array of form fields
        # @param index [Numeric] the initial index
        def initialize(fields,index=0,silent=false)
          @fields = fields
          @index = index
          @silent=silent
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
              @fields[@index] = Edit.new(@fields[@index][1],@fields[@index][2],@fields[@index][3],false,@fields[@index][4])
            end
            end
          @fields[@index].focus if @fields[@index]!=nil
          play("form_marker") if @silent==false
          loop_update
        end
        
        # Updates a form
        def update
          @index-=1 while @fields[@index]==nil and @index>0
      @index+=1 while @fields[@index]==nil and @index<@fields.size-1
                                      if $key[0x09] == true
                                        speech_stop
            if $key[0x10] == false and @fields[@index].subindex==@fields[@index].maxsubindex
              ind=@index
              @index += 1
              while @fields[@index] == nil and @index<@fields.size
                @index+=1
              end
              if @index >= @fields.size
                @index=ind
                play("border")
            end
          elsif $key[0x10] and @fields[@index].subindex==0
ind=@index
            @index-=1
            while @fields[@index]==nil
              @index-=1
              end
            if @index < 0
              @index = ind
                          play("border")
                                      end
          end
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
@fields[@index] = Edit.new(@fields[@index][1],@fields[@index][2],@fields[@index][3],false,@fields[@index][4])
            end
            end
                      @fields[@index].focus
        else
                    @fields[@index].update
                  end
                  end
                def focus
                  @fields[@index].focus if @fields[@index]!=nil
                  end
                  end
                
                # Reads a text from user and returns it
                #
                # @param header [String] a window caption
                # @param type [String] the window type
                #  @see Edit
                # @param text [String] an initial text
  def input_text(header="",type="normaltext",text="")
  ro = false
  if type.is_a?(String)
  type.gsub("READONLY") {
  ro = true
  }
  ae = false
    type.gsub("ACCEPTESCAPE") {
  ae = true
  }
  ml = false
      type.gsub("MULTILINE") {
  ml = true
  }
        type.gsub("MULTILINES") {
  ml = true
  }
  end
  dialog_open
  inp = Edit.new(header,type,text)
  loop do
loop_update
    inp.update
    rtmp = false
    rtmp = true if ml == false or $key[0x11] == true
    break if enter and rtmp == true
    if (ro == true or (type.is_a?(Numeric) and (type&Edit::Flags::ReadOnly)>0)) and (escape or alt or enter)
      r = ""
  r = "\004ALT\004" if alt
    r = "\004TAB\004" if $key[0x09] == true and $key[0x10] == false
    r = "\004SHIFTTAB\004" if $key[0x09] == true and $key[0x10] == true
    r = "\004ESCAPE\004" if escape
    Audio.bgs_stop
    dialog_close  
    return r
      break
      end
    if escape and ae == true
      Audio.bgs_stop
      dialog_close
      return("\004ESCAPE\004")
      break
      end
    end
    inp.finalize
    Audio.bgs_stop
    r=inp.text_str
  dialog_close
  loop_update
    return r
  end
  
  class FormChild
    def subindex
      return 0
    end
    def maxsubindex
      return 0
      end
    end
  
  class Edit < FormChild
    attr_accessor :index
        attr_accessor :flags
    attr_reader :origtext
    attr_accessor :silent    
    attr_accessor :audiotext
    attr_accessor :check
    def initialize(header="",type="",text="",quiet=false,init=false,silent=false)
            @header=header
@flags=0
@flags=type if type.is_a?(Integer)
@silent=silent
if type.is_a?(String)
  @flags=@flags|Flags::MultiLine if type.downcase.include?("multiline")
    @flags=@flags|Flags::ReadOnly if type.downcase.include?("readonly")
  @flags=@flags|Flags::Password if type.downcase.include?("password")
  @flags=@flags|Flags::Numbers if type.downcase.include?("numbers")
end
        settext(text)
                @origtext=text
      @index=@check=0
@redo=@undo=[]
focus if quiet==false
    end
    def update
            if $focus==true
        $focus=false
        focus
      end
      oldindex=@index
      oldtext=@text
      if $speechindexedthr!=nil and $speechid==@speechindexed and @speechindexed!=nil and $speechindex!=@index and ($speechindex||0)>0
        @index=$speechindex
              end
navupdate
      editupdate
      ctrlupdate
      mediaupdate if @audiotext!="" and @audiotext!=nil                                                            
      if oldindex!=@index or oldtext!=@text
          NVDA.braille(@text, @index) if NVDA.check
        end
            esay
        end
def editupdate
  return readupdate if (@flags&Flags::ReadOnly)!=0
      if (c=getkeychar)!="" and (c.to_i.to_s==c or (@flags&Flags::Numbers)==0) and (@flags&Flags::ReadOnly)==0
                speech_stop
        einsert(c)
                               if ((wordendings=" ,./;'\\\[\]-=<>?:\"|\{\}_+`!@\#$%^&*()_+").include?(c)) and (($interface_typingecho == 1 or $interface_typingecho == 2))
                 s=@text[(@index>50?@index-50:0)...@index]
                                  w=(s[(0 ... s.length).find_all { |i| wordendings.include?(s[i..i]) or s[i..i]=="\n"}.sort[-2]||0..(s.size-1)])
if (w=~/([a-zA-Z0-9ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]+)/)!=nil
  espeech(w)
  play("edit_space") if c==" "
else
  espeech(c) if @interface_typingecho!=1
  end
elsif $interface_typingecho==0 or $interface_typingecho==2
         espeech(c)
      end
    elsif c!=""
            play("border") if (c!=" " or $speechaudio==nil)
      end
    if enter
      speech_stop
          if (@flags&Flags::MultiLine)>0 and $key[0x11]==false and (@flags&Flags::ReadOnly)==0
      einsert("\n")
      play("edit_endofline")
    elsif ((@flags&Flags::MultiLine)==0 or $key[0x11]) and (@flags&Flags::ReadOnly)==0
      play("list_select")
            end
          end
          if $key[0x2e] and (@index<@text.size or @check<@text.size) and (@flags&Flags::ReadOnly)==0
            play("edit_delete")
            c=[@index,@check].sort
                                                                  c[0]=charborders(c[0])[0]
                              c[1]=charborders(c[1])[1]
                                                                                                        edelete(c[0],c[1])
                                                                          espeech(@text[@index..@index+1].split("")[0])
          end
          if $key[0x08] and (@index>0 or @check>0) and (@flags&Flags::ReadOnly)==0
play("edit_delete")
c=[]
if @index!=@check
c=[@index,@check].sort
c[0]=charborders(c[0])[0]
                              c[1]=charborders(c[1])[1]
else
  oind=ind=@index-1
  ind=charborders(ind)[0]
  c=[ind,oind]
  end
                                                                                                                                espeech(@text[c[0]..c[1]].split("")[0])
            edelete(c[0],c[1])                                    
                                                end
                    end
def readupdate
            if enter 
url=nil
@elements.each {|e| url=e.param[1] if (e.bindex<=@index and e.eindex>=@index) and e.type==Element::Link}
@elements.each {|e| url=e.param[1] if (e.bindex>=linebeginning and e.eindex<=lineending) and e.type==Element::Link} if url==nil
              if url!=nil
                                      speak(_("EAPI_Form:wait_link"))
        run("explorer \"#{url}\"")
        loop_update
        end
      end
              e=nil
      if $key[72]
      e=find_element(Element::Header,nil,$keyr[0x10],@index)
    elsif $key[0x31..0x36].include?(true)
      k=1
      (1..6).each {|i| k=i if $key[0x30+i]}
        e=find_element(Element::Header,k,$keyr[0x10],@index)
      elsif $key[75]
        e=find_element(Element::Link,nil,$keyr[0x10],@index)
        elsif $key[73]
        e=find_element(Element::ListItem,nil,$keyr[0x10],@index)
        end
  if e!=nil
    @index=e.bindex
    espeech(@text[e.bindex..e.eindex])
    elsif getkeychar!=""
    play("border")
    end
  end
                    def navupdate
            @vindex=$key[0x10]?@check:@index
            @ch=false
          if arrow_right and ($key[0x10]==false or $speechaudio==nil)
                                  @vindex=charborders(@vindex)[1]
          if @vindex>=@text.size
                    play("border")
                                      elsif @vindex==@text.size-1
                    @vindex=@text.size
                    play("edit_endofline")
                  else
                    if $key[0x11]==false
                              ind=@vindex+1
        oi=ind
        ind=charborders(ind)[1]
                espeech(@text[@vindex+1..ind])
                @vindex=oi
              else
                                                @vindex=((@vindex+($key[0x10]?((@vindex>=(@text.size-1))?1:2):1) ... (@vindex<@text.size-100?@vindex+100:@text.length)).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort[0]||@text.size-1)
                                @vindex+=($key[0x10]?((@vindex>=@text.size-1)?0:-1):1)
                                                                                                (@vindex==@text.size)?play("edit_endofline"):espeech(@text[($key[0x10]?((0 .. @vindex).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort.last||0):@vindex)..(@vindex+1 ... @text.length).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort[0]||@text.size-1])
                                                                                              end
                              end
                                              elsif arrow_left and ($key[0x10]==false or $speechaudio==nil)
        if @vindex<=0
                    play("border")
                  else
        if $key[0x11]==false
                    ind=@vindex-1
                  ind=charborders(ind)[0]
                                            espeech(@text[ind..@vindex-1])
                @vindex=ind
              else
                @vindex=((((@vindex>100)?(@vindex-100):0) ... @vindex-1).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort.last||-1)+1
                @vindex-=1 if $key[0x10] and @check>@vindex and @vindex>0
                espeech(@text[@vindex..(@vindex+1 ... @text.length).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort[0]||@text.size-1])
                end
              end
            elsif arrow_up and !$keyr[0x2d]
              b=linebeginning
              e=lineending
                            if b==0
                play("border")
                espeech(e>0?(@text[0..e-1]):"")
              else
                                l=@vindex-b
                em=lineending(b-1)
                bm=linebeginning(b-1)
                l=em-bm if em-bm<l
                l=0 if e-b<=1
                                @vindex=bm+l
                espeech(em>0?(@text[bm..em-1]):"")
                end
            elsif arrow_down and !$keyr[0x2D]
              b=linebeginning
              e=lineending
              if e==@text.size
                play("border")
                espeech(@text[b..e-1])
              else
                l=@vindex-b
                ep=lineending(e+1)
                bp=linebeginning(e+1)
                l=ep-bp if ep-bp<l
                l=0 if e-b<=1
                                @vindex=bp+l
                espeech(@text[bp..ep-1])
                end
        end
        if $key[0x24]
                    @ch=@vindex=$key[0x11]?0:linebeginning
                            espeech($key[0x11]?@text[linebeginning..lineending]:@text[@vindex..@text.size-1].split("")[0]) if @vindex<@text.size
                                      elsif $key[0x23]
          @ch=@vindex=$key[0x11]?(@text.size):lineending
          espeech($key[0x11]?@text[linebeginning..lineending]:(((t=@text[lineending..lineending])=="")?"\n":t))
                                                end
                                                        if $key[0x21]
                    if linebeginning==0
                play("border")
                espeech(@text[0..lineending-1])
              else
                lines=getlines
                curline=curlineind=0
                for i in 0..lines.size-1
l=lines[i]
if l<=@vindex                  
curline=l
curlineind=i
end
                                  end
                inlineindex=@vindex-curline
                                  if curlineind<15
                  @vindex=inlineindex
                else
                  inlineindex=lines[curlineind-14]-lines[curlineind-15] if inlineindex>lines[curlineind-14]-lines[curlineind-15]
                  @vindex=lines[curlineind-15]+inlineindex
                  end
                espeech(@text[linebeginning..lineending-1])
                end
            elsif $key[0x22]
              if lineending==@text.size
                play("border")
                                espeech(@text[linebeginning..lineending-1])
              else
                                lines=getlines
                curline=curlineind=0
                for i in 0..lines.size-1
l=lines[i]
if l<=@vindex                  
curline=l
curlineind=i
end
                                  end
                                                  inlineindex=@vindex-curline
                                  if curlineind>lines.size-17
                                                                                          @vindex=lines[-1]+inlineindex
                  @vindex=@text.size if @vindex>@text.size
                else
                  inlineindex=lines[curlineind+16]-lines[curlineind+15] if inlineindex>lines[curlineind+16]-lines[curlineind+15]
                                    @vindex=lines[curlineind+15]+inlineindex
                                    end
                espeech(@text[linebeginning..lineending-1])
                end
          end
                    if $key[0x10]==false and (@index!=@vindex or @ch!=false)
            @check=@index=@vindex
            Audio.bgs_stop
                      elsif ($key[0x10]==true and @check!=@vindex) or ($key[0x11] and $key[65] and !$key[0x12])
            if $key[0x11] and $key[65] and !$key[0x12]
                        @index=0
            @check=@text.size
          else
            @check=@vindex
                        end
                                    if @index!=@check
            @tosay+="\r\n(#{s_("EAPI_Common:info_phr_checked",'check'=>getcheck)})"
            play("edit_checked")
          else
            Audio.bgs_stop
            end
          end
          Audio.bgs_stop if escape or (enter and $key[0x11]) or $key[0x9]
            esay
          end
          def ctrlupdate
if $key[0x11]   and $key[0x12]==false
  if $key[67]
    Clipboard.set_data(unicode(getcheck.gsub("\n","\r\n")),13)
    alert(_("EAPI_Form:info_copied"), false)
  end
  if $key[88] and (@flags&Flags::ReadOnly)==0
    Clipboard.set_data(unicode(getcheck.gsub("\n","\r\n")),13)
    c=[@index,@check].sort
    edelete(c[0],c[1])
    alert(_("EAPI_Form:info_cut"), false)
  end
  if $key[86]
    einsert(Clipboard.get_unic.delete("\r"))
    alert(_("EAPI_Form:info_pasted"), false)
  end
    if $key[90] and @undo.size>0
      u=@undo.last
        @undo.delete_at(@undo.size-1)
u[0]==1?edelete(u[1],u[1]+u[2].size,false):einsert(u[2],u[1],false)
                    @redo.push(u)
          alert(_("EAPI_Form:info_undone"), false)
    end
      if $key[89] and @redo.size>0
      r=@redo.last
        @redo.delete_at(@redo.size-1)
                r[0]==2?edelete(r[1],r[1]+r[2].size,false):einsert(r[2],r[1],false)
                    @undo.push(r)          
          alert(_("EAPI_Form:info_repeated"), false)
    end
        $key[0x10]?translator(getcheck):espeech(translatetext(0,$language,getcheck)) if $key[84]
    if $key[70]
      search=input_text(_("EAPI_Form:type_searchphrase"),"ACCEPTESCAPE",@lastsearch||"")
      if search!="\004ESCAPE\004"
        @lastsearch=search
            ind=@index<@text.size-1?@text[@index+1..@text.size-1].downcase.index(search.downcase):0
      ind+=@index+1 if ind!=nil
  ind=@text[0..@index].downcase.index(search.downcase) if ind==nil
    if ind==nil
  alert(_("EAPI_Form:info_nomatch"), false)
else
  @index=ind
  readtext(@index)
  end
    end
    
    end
    speechtofile("",getcheck.gsub("\n","\r\n")) if $key[80]
    if $key[82] and FileTest.exists?($tempdir+"/savedtext.tmp") and @readonly!=true and (@flags&Flags::ReadOnly)==0 and @audiotext==nil
      @undo=[]  
      settext(readfile($tempdir+"/savedtext.tmp"))
  alert(_("EAPI_Form:info_loaded"), false)
  end
      if $key[83]
                writefile($tempdir+"\\savedtext.tmp",@text)
        alert(_("General:info_saved"), false)
        end
  end
  readtext(@index) if @index<@text.size and (($key[115] or ($keyr[0x2d] and arrow_down))) and (@audiotext==nil or @index>0)
  espeech(@text[linebeginning..lineending]) if $keyr[0x2d] and arrow_up
  esay
end
def mediaupdate
  return if @audiotext==nil or @audiotext=="" 
  if $key[0x11] and $key[83]
            dialog_open
        form=Form.new([FilesTree.new(_("EAPI_Form:head_dst"),getdirectory(40)+"\\",true,true,"Music"),Edit.new(_("EAPI_Form:type_Filename"),"",@header.delete("\r\n").delete("\"").delete("/").delete("\\")+".mp3"),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
        loop do
          loop_update
          form.update
          break if escape or ((space or enter) and form.index==3)
          if (space or enter) and form.index==2
            dest=form.fields[0].selected+"\\"+form.fields[1].text_str
            sou=@audiotext
            sou.sub!("/",$url) if sou[0..0]=="/"
                        speak(_("EAPI_Form:wait_downloading"))
                        if !FileTest.exists?(dest) or confirm("EAPI_Form:alert_override")==1
                        waiting
                        executeprocess("bin\\ffmpeg -y -i \"#{sou}\" \"#{dest}\"",true)
                        waiting_end
                        alert(_("EAPI_Form:info_downloaded"))
                        end
                                    break
            end
          end
          dialog_close
    end
    ($speechaudio==nil)?speech("\004AUDIO\004"+@audiotext+"\004AUDIO\004"+@text.gsub("\n","\r\n")):$speechaudio.position+=5 if $key[115]
    if $key[0x20]
      if $speechaudio!=nil and $speechaudio.closed==false
      if $speechaudiopaused!=true
          $speechaudio.pause
          $speechaudiopaused=true
        else
          $speechaudio.play
          $speechaudiopaused=false
        end
      else
        $speechaudiopaused=false
        speech("\004AUDIO\004#{@audiotext}\004AUDIO\004")
        end
    end
return if $speechaudio==nil    
                  if $speechaudio!=nil and $key[0x10]==true
      if arrow_left
      $speechaudio.position-=5
      delay(0.1)
    elsif arrow_right
      $speechaudio.position+=5
      delay(0.1)
        end
  end      
  
  end
  def linebeginning(index=@vindex)
                  return 0 if index==0
    return 0 if @text.size==0
l=((((index>3000?index-3000:0) ... index).find_all { |i| @text[i..i]=="\n"}[-1])||-1)+1
  r=((index ... (index<@text.size-3000?@index+3000:@text.size)).find_all { |i| @text[i..i]=="\n"}[0])||@text.size    
  ls=getvlines(l,r)
  ind=l
  for n in ls
    ind=n if n<=index
  end
      return ind
end
def lineending(index=@vindex)
              return 0 if @text.size==0
  l=((((index>3000?index-3000:0) ... index).find_all { |i| @text[i..i]=="\n"}[-1])||-1)+1
  r=((index ... (index<@text.size-3000?@index+3000:@text.size)).find_all { |i| @text[i..i]=="\n"}[0])||@text.size
        ls=getvlines(l,r)
      ln=0
    for i in 0...ls.size-1
    ln=i if ls[i]<=index
  end
  ind=ls[ln+1]-1            
    return ind
  end
  def charborders(ind)
    left=0
    right=0
    for i in 0..3
      for j in 0..3
        t=@text[ind-i..ind+j]
        if ind-i>=0 && ind+j<@text.size && t!=nil && t.split("").size==1
          left=i
          right=j
          end
      end
    end
    left+=1 while left>ind
    right-=1 while ind+right>=@text.size
    return [ind-left, ind+right]
    end
def getvlines(l,r)
    return [l,r+1] if r-l<120 or (@flags&Flags::MultiLine)==0 or (@flags&Flags::DisableLineWrapping)>0 or $interface_linewrapping==0
  ls=[l]
    for c in l...r
           if @text[c..c]==" " and c-ls[-1]>120 and c!=r-1
                        for oc in c..r
if @text[oc..oc]!=" "
              ls.push(oc)
              break if oc>=r
              break
              end
      end
          end
    end
    ls.delete_at(-1) if ls[-1]>=r          
    ls.push(r+1) if ls[-1]!=r+1
                  return ls
  end
  def getlines
        ns=(0...@text.size).find_all {|c| @text[c..c]=="\n"}
        ns.push(@text.size-1)
        lines=[]
        for i in 0..ns.size-1
                    prior=-1
          prior=ns[i-1] if i>0
          lines+=getvlines(prior+1,ns[i])
          lines.delete_at(-1)
          end
              return lines
          end
  def getcheck
  return @text if @index==@check
  st=[@index,@check].sort
  from=st[0]
  to=st[1]
  to=charborders(to)[1]
  return @text[from..to]
  end
  def einsert(text,index=@index,toundo=true)
    text.delete!("\n") if (@flags&Flags::ReadOnly)!=0
    if (@flags&Edit::Flags::Numbers)>0
    text=text.to_i.to_s
    text="" if text!="0" and text.to_i==0
    end
  @undo.push([1,index,text]) if toundo==true
@undo.delete_at(0) if @undo.size>100
@redo=[] if toundo==true
    @text.insert(index,text)
  @index+=text.size
  @check=@index
end
def edelete(from,to,toundo=true)
@check=@index=from if @index>from
@undo.push([2,from,@text[from..to]]) if toundo==true
@redo=[] if toundo==true
@undo.delete_at(0) if @undo.size>100
@text[from..to]=""
Audio.bgs_stop
  end
  def espeech(text)
  @tosay=text
  end
def esay
  if @tosay!="" and @tosay!=nil
        if (@flags&Flags::Password)==0
          @speechindexed=nil
          speech_stop
    speech(@tosay)
  else
    play("edit_password_char")
  end
  @tosay=""
end
end
def settext(text,reset=true)
          @text=text.delete("\r").gsub("\004LINE\004","\n").gsub(/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/) do
          $dialogvoice.volume=0 if $dialogvoice!=nil
          @audiotext=$1
      ""
    end
    @text.gsub!(/\004ATTACH\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004ATTACH\004/,"")
    @text.chop! while @text[@text.size-1..@text.size-1]=="\n"
    @elements=[]    
    if (@flags&Flags::MarkDown)!=0
          @text.gsub!(/(^http(s?)\:\/\/([^\n]+)$)/) {"[#{$1}](#{$1})"}
      md_proceed
    else
          @text.indices(/http(s?)\:\/\/([^ \n]+)/).each {|ind| @elements.push(Element.new(ind,ind+(@text[ind..-1].index(/[ \n]/)||@text.size)-1,Element::Link,[0,@text[ind...ind+(@text[ind..-1].index(/[ \n]/)||@text.size-ind)]]))}
    end
    @index=0 if reset==true
  @index=@text.size if @index>@text.size
end
def md_proceed
  @elements=[]
  ind=0
            @text.gsub!(/(\[[^\]]+\])(\[[^\]]+\])/) do
                            a=$1
              b=$2
              if ( (/^[\t ]*#{Regexp.escape($2)}\:[\t ]*([^\n]+\n?)/)=~@text)!=nil
                                a+"(#{$1})"
                else
              a+b
              end
            end
            @text.gsub!(/(^[\t ]*(\[[^\]]+\])\:[ %t]*([^\n]+)$)/) do
              if @text.indices($3).size>1
                ""
              else
                $1
              end
            end
            @text.gsub!(/\[\:(\d+)\]/) {"["+$1+"]"}
      ind=0  
      while (m=@text[ind..-1].match(/(^[ \t]*([\#]+)[ \t]*([^\n]*)$)|(^([^\n]+)\n[ \t]*([\=\-]+)$)|(\[([^\]]+)\]\(([^[ \)]]+)([ ]*)((\"[^\"]*\")?)\))|(^([*-])([^\n]+)$)/))!=nil
                                    b=ind+m.begin(0)
    e=ind+m.end(0)
    if m.values_at(1)[0]!=nil
                          cnt=@text[b..e-2].strip
        level=0
            level=cnt.count("#")
              while " \t\#=-".include?(@text[b..b])
                @text[b..b]=""
                e-=1
                end
              @elements.push(Element.new(b,e-1,Element::Header,level))
            elsif m.values_at(4)[0]!=nil
                            @text[m.begin(6)..m.end(6)]=""
              e-=(m.values_at(6)[0].size+1)
              level=1
              level=2 if m.values_at(6)[0..0]=="-"
              @elements.push(Element.new(b,e,Element::Header,level))
              elsif m.values_at(7)[0]!=nil
                                  label=m.values_at(8)[0]
    url=m.values_at(9)[0]
        @text[b..e-1]=label
    e=b+label.size
                        @elements.push(Element.new(b,e-1,Element::Link,[0,url]))
                      elsif m.values_at(13)!=nil
                        @elements.push(Element.new(b,e,Element::ListItem))
                                            end
                      ind=b+1
                    end
                                                        end
                def find_element(type=0,flags=nil,revdir=false,index=@index)
                  e=Element.new(@text.size,-1,0)
                  for el in @elements
                    e=el if (el.type==type and (flags==nil or el.param==flags)) and (((revdir==false and el.bindex>index and el.bindex<e.bindex) or (revdir==true and el.eindex<index and el.eindex>e.eindex)))
                  end
                  return nil if e.type==0
                  return e
                  end
def finalize
  text_str
  end
  def text_str
  return @text.gsub("\n","\004LINE\004")
end
def text
  @text.gsub("\n","\r\n")
  end
  def focus(spk=true)
      play("edit_marker") if spk
      tp=_("EAPI_Form:fld_edit")
      tp=_("EAPI_Form:fld_text") if (@flags&Flags::ReadOnly)>0
      tp=_("EAPI_Form:fld_media") if @audiotext!=nil
      head=@header.to_s + " ... " + tp + ": " + ((@audiotext!=nil)?"\004AUDIO\004#{@audiotext}\004AUDIO\004":"")
                  return speak(head + ((@audiotext!=nil)?"\004AUDIO\004#{@audiotext}\004AUDIO\004":"") + text.gsub("\n"," "),1,false) if @audiotext!=nil and @audiotext!="" and spk
                        readtext(0,head) if spk
                        NVDA.braille(@header.to_s+"  "+@text, @header.to_s.size+2+@index) if NVDA.check
    end
    def readtext(index=0,head="")
      return speak(head) if @text=="" and head!="" and head!=nil
      return if @text==""
                        sents={}
                  pi=index
                  ch=["!","?","."]
                                                (index...@text.size).find_all{|c| @text[c+1..c+1]==" " or @text[c+1..c+1]=="\n"}.each do |i|
        if ch.include?(@text[i..i]) or @text[i+1..i+1]=="\n"
          sents[pi]=@text[pi..i+1]
          pi=i+2
                                        end
                                      end
                                      sents[pi]=@text[pi..-1]
                                      sents[0]=head+"\r\n"+(sents[0]||"") if head!=nil and head!=""
                                      id=rand(1e9)
        speak_indexed(sents,id)
@speechindexed=id
      end
    class Flags
MultiLine=1
ReadOnly=2
Password=4
  Numbers=8
  DisableLineWrapping=16
  MarkDown=32
end
    class Element
    attr_accessor :bindex, :eindex, :type, :param
    Header=1
    Link=2
        ListItem=3
    Quote=5
    def initialize(bindex=0,eindex=0,type=0,param=nil)
      @bindex,@eindex,@type,@param=bindex,eindex,type,param
    end
  end
end

class Editor < FormChild
attr_accessor :silent
def text
@field.text
end
def origtext
@field.origtext
end
def audiotext
@field.audiotext
end
def check
@field.check
end

def initialize(header="",type="",text="",quiet=false,init=false,silent=false)
@field=Edit.new(header,type,text,quiet,init,silent)
@form=Form.new([@field])
end

def subindex
@form.index
end

def maxsubindex
@form.fields.size-1
end

def update
@form.update
end

def settext(text,reset=true)
@field.settext(text,reset)
end
def finalize
@field.finalize
end
def text_str
@field.text_str
end

def focus
@form.focus
end
end
      
    # A listbox class
    class Select < FormChild
      # @return [Numeric] a listbox index
attr_accessor :index
# @return [Array] listbox options
attr_reader :commandoptions    
attr_reader :grayed
attr_reader :selected
attr_accessor :silent
attr_accessor :header
# Creates a listbox
#
# @param options [Array] an options list
# @param border [Boolean] restrain the listbox
# @param index [Numeric] an initial index
# @param header [String] a listbox caption
# @param quiet [Boolean] don't read a caption at creation
# @param multi [Boolean] support multiple selection
# @param lr [Boolean] create left-right listbox
# @param silent [Boolean] don't play listbox sounds
def initialize(options,border=true,index=0,header="",quiet=false,multi=false,lr=false,silent=false)
    $lastkeychar=nil
  options=options.deep_dup
      border=false if $interface_listtype == 1
      index = 0 if index == nil
           index = 0 if index >= options.size
      index+=options.size if index<0
      self.index = index
                        @lr=lr
self.commandoptions=(options)
                                                @selected = []
                                                            for i in 0..@commandoptions.size - 1
              @grayed[i] = false if @grayed[i]!=true
              @selected[i] = false
              end
            @border = border
            @multi = multi
@silent=silent
            header="" if header==nil
            index=0 if index<0
            @index=0 if @index<0
                                    @header = header
              focus if quiet == false
                                        end
            
            def commandoptions=(options)
              @commandoptions=[]
              @grayed||=[]
              @hotkeys||={}
                                      hk=false
                                                ands=0
                        options.each {|o| ands+=1 if o!=nil&&o.include?("\&")}
                                                hk=true if ands>options.size/3
                                                                        for i in 0..options.size - 1
                                                                          gray=false
              if options[i]!=nil
if @lr or hk
                for j in 0..options[i].size-1
  @hotkeys[options[i][j+1..j+1].upcase[0]] = i if options[i][j..j] == "&"
end
end
opt=options[i]
opt.delete!("&") if @lr or hk
else
  opt=""
  gray=true
end
@commandoptions.push(opt)
@grayed[@commandoptions.size-1]=true if ((opt==nil)&&!lr)||gray
end            
end
            
            # Update the listbox
    def update
                  if $focus == true
    focus
    $focus = false
  end
  speech((@index+1).to_s+" / "+@commandoptions.size.to_s) if $key[115] and !$keyr[0x10]
    if $key[0x11]   and $key[0x12] and $key[82]
      for i in 0..@commandoptions.size-1
        @commandoptions[i]=@commandoptions[i].split("").reverse.join if @commandoptions[i].is_a?(String)
        speech("Coś niejasne?")
        end
      end
    oldindex = self.index
      options = @commandoptions
if ((@lr and arrow_left) or (!@lr and arrow_up)) and !$keyr[0x10] and !$keyr[0x2D]
  @run = true
  self.index -= 1
        while ishidden(self.index) == true
    self.index -= 1
  end
    if self.index < 0
    oldindex = -1 if @border == false
    self.index = 0
    while ishidden(self.index) == true
      self.index += 1
      end
self.index = options.size - 1 if @border == false
  end  
  elsif ((@lr and arrow_right) or (!@lr and arrow_down)) and !$keyr[0x10]  and !$keyr[0x2D]
@run = true
    self.index += 1
    while ishidden(self.index) == true
    self.index += 1
  end
  if self.index >= options.size
    oldindex = -1 if @border == false
    self.index = options.size - 1
    while ishidden(self.index) == true
      self.index -= 1
      end
self.index = 0 if @border == false
  end  
end
speech(@commandoptions[@index]) if $keyr[0x2D] and arrow_up
  if $keyr[0x10] and (arrow_up or arrow_down)
  tgs=tags
  ind=(tgs.index(@tag)||-1)+1
  
      if arrow_up
      ind-=1
    elsif arrow_down
      ind+=1
    end
            ind=ind%(tgs.size+1)
              if ind==0
    @tag=nil
    speak(_("EAPI_Form:opt_phr_alltags"))
  else
    @tag=tgs[ind-1]
    self.index+=1 while ishidden(self.index) and self.index<options.size-1
    self.index-=1 while ishidden(self.index) and self.index>0
    o=options[self.index].gsub(/\[#{Regexp.escape(@tag)}\]/i, "")
    speak(@tag+": "+o)
    end
  end
  if $key[0x23] == true
@run = true
        self.index = options.size - 1
      while ishidden(self.index) == true
    self.index -= 1
    end
    end
  if $key[0x24] == true
@run = true
        self.index = 0
      while ishidden(self.index) == true
    self.index += 1
    end
    end
  if $key[0x21] == true and @lr==false
    if self.index > 14
            for i in 1..15
              self.index-=1
              while ishidden(self.index) == true and self.index>15-i
    self.index -= 1
  end
              end
          else
            self.index = 0
            end
            @run = true
        while ishidden(self.index) == true
    self.index += 1
  end
    end
        if $key[0x22] == true and @lr==false
       if self.index < (options.size - 15)
            for i in 1..15
              self.index+=1
                  while ishidden(self.index) == true and self.index<@commandoptions.size-i
    self.index += 1
  end              
              end
          else
            self.index = options.size-1
            end
            @run = true
  while ishidden(self.index) == true and self.index<@commandoptions.size
    self.index += 1
  end
        end
        suc = false
        k=getkeychar
                                  if k != "" and k != " "
                                            k=@lastkey+k if @lastkey!=nil and @lastkeytime>Time.now.to_f-0.25 and k!=@lastkey and @lr==false
            @lastkeytime=Time.now.to_f
          @lastkey=k
          i=k.upcase[0]
          if @hotkeys[i]==nil and @hotkeys.size<=@commandoptions.size/2
                  @run = true
        for j in self.index + (k.split("").size==1?1:0)..options.size - 1
          if suc == false              
          if options[j][0..k.size-1].upcase==k.upcase and ishidden(j)!=true
          suc = true
          self.index = j
          while ishidden(self.index) == true
    self.index += 1
    end
  end
  end
        end
                for j in 0..self.index
        options[j]=" " if options[j]==nil
        if suc == false          
        if options[j][0..k.size-1].upcase==k.upcase and ishidden(j)!=true
          suc = true
                    self.index = j
          while ishidden(self.index) == true
    self.index += 1
    end
  end
  end
      end
      if suc == false
      else
      end
          elsif @hotkeys[i]!=nil
      @index = @hotkeys[i]
      $enter = 2
      end
      end
        if enter
      play("list_select") if @silent == false
    end
    self.index = 0 if self.index >= options.size
  if self.index == -1
        while ishidden(self.index) == true
    self.index += 1
  end
  end
if self.index >= @commandoptions.size
      while ishidden(self.index) == true
    self.index -= 1
    end
  end
  if @run == true
  speech_stop
o = options[self.index]
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
  end
o += "...\r\n#{_("EAPI_Form:opt_phr_shortkey")}" + ASCII(ss) if ss.is_a?(Integer)
o += "\r\n\r\n(#{_("EAPI_Common:opt_phr_checked")})" if @selected[self.index] == true
o||=""
o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
o=("\004NEW\004"+" "+(($interface_soundthemeactivation==1)?"":$1+" ")+o).gsub(/\004INFNEW\{([^\}]+)\}\004/,"")
}
o=o.gsub(/\[#{Regexp.escape(@tag)}\]/i, "") if @tag!=nil
  speech(o)
  play("list_checked") if @selected[self.index] == true
  focus(@header, false)
end
k=k.to_s if k.is_a?(Integer)
    if oldindex != self.index
  self.index = 0 if options.size == 1 or options[self.index] == nil
  play("list_focus") if @silent == false
@run = false
elsif oldindex == self.index and @run == true and (k.split("").size<=1 or (@commandoptions[self.index][0...k.size].upcase!=k.upcase))
    play("border") if @silent == false
    @run = false
  end
  if space and @multi == true
    if @selected[@index] == false
      @selected[@index] = true
      play("list_checked")
      alert(_("EAPI_Form:info_checked") ,false)
    else
      @selected[@index] = false
      play("list_unchecked")
      alert(_("EAPI_Form:info_unchecked"), false)
      end
    end
  end
  
  
def focus(header=@header, spk=true)
   play("list_marker") if @lr==false and spk
              while ishidden(self.index) == true
                            self.index += 1
            end
            if self.index > @commandoptions.size - 1
              while ishidden(self.index) == true
              self.index -= 1
              end
              end
            options=@commandoptions
            sp=""
            if @header!=nil and @header!=""  
            sp = header
                            sp+=": " if !" .:?!,".include?(sp[-1..-1])
              sp+=" " if sp[-1..-1]!=" "
              end
            if options.size>0
              o = options[self.index].delete("&")
              o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
o=("\004NEW\004"+" "+(($interface_soundthemeactivation==1)?"":$1+" ")+o).gsub(/\004INFNEW\{([^\}]+)\}\004/,"")
}
sp += o
ss = false
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
  end
sp += "...\r\n#{_("EAPI_Form:opt_phr_shortkey")}" + ASCII(ss) if ss.is_a?(Integer)
end            
sp += _("EAPI_Form:info_listempty") if @commandoptions.size==0
speech(sp) if spk
NVDA.braille(sp) if NVDA.check
end

# Hides a specified item
#
# @param id [Numeric] the id of an item to hide
    def disable_item(id)
  @grayed[id] = true
  options = @commandoptions
  while ishidden(self.index) == true
    self.index += 1
  end
  if self.index >= options.size
    oldindex = -1 if @border == false
    self.index = options.size - 1
    while ishidden(self.index) == true
      self.index -= 1
      end
self.index = 0 if @border == false
  end  
end
def enable_item(id)
  @grayed[id]=false
end
def ishidden(id)
  return false if id<0 || id>=@commandoptions.size
  r=@grayed[id]==true
  r=true if @tag!=nil and !@commandoptions[id].downcase.include?("["+@tag.downcase+"]")
  return r
end
def tags
  tgs=[]
  @commandoptions.each {|t|
tgs+=t.scan(/\[([^[\[\]]]+)\]/).map{|x| x[0].downcase}
  }
 tgs.delete(nil) 
  return tgs.uniq
end
def settag(tag)
  
  end
def selected?
  return enter
end
def expanded?
  return !$keyr[0x10] && ((@lr && arrow_down) || (!@lr && arrow_right))
end
def collapsed?
  return !$keyr[0x10] && ((@lr && arrow_up) || (!@lr && arrow_left))
end
end

# A button class
        class Button < FormChild
        # @return [String] the label of a button
          attr_accessor :label
          
          # Creates a button
          #
          # @param label [String] a button label
        def initialize(label="")
          @label = label
          @pressed=false
        end
        
        # Updates a button
        def update
          if $focus == true
    focus
    $focus = false
  end
  speech(@label) if $keyr[0x2D] and arrow_up
  @pressed = (enter||space)
          end
        def focus
          play("button_marker")
          speech(@label + "... " + _("EAPI_Form:fld_button"))
          NVDA.braille(@label) if NVDA.check
        end
        def pressed?
          return @pressed
          end
      end
      
      # A checkbox class
      class CheckBox < FormChild
        # @return [String] a checkbox label
        attr_accessor :label
        # @return [Numeric] 0 if non-checked, 1 if checked
        attr_accessor :checked
        
        # Creates a checkbox
        #
        # @param checked [Numeric] specifies the default state of a checkbox (0 - not checked, 1 - checked)
        # @param label [String] a checkbox label
        def initialize(label="",checked=0)
          @label = label
          @checked = checked.to_i
        end
        
        # Updates a checkbox
        def update
          if $focus == true
    focus
    $focus = false
  end
  focus(true,false) if $keyr[0x2D] and arrow_up
          if space or enter
            if @checked == 1
              @checked = 0
              alert(_("EAPI_Form:st_unchecked"), false)
            else
              @checked = 1
              alert(_("EAPI_Form:st_checked"), false)
            end
            focus(false)
            end
          end
        
                    def focus(spk=true, snd=true)
          play("checkbox_marker") if spk and snd
          text = @label + " ... "
          if @checked == 0
            text += _("EAPI_Form:st_unchecked")
          else
            text += _("EAPI_Form:st_checked")
          end
          text += " "
          text += _("EAPI_Form:fld_checkbox")
          speech(text) if spk
          NVDA.braille(text)
        end
      end        
      
      # Creates a files tree
      class FilesTree < FormChild
        # @param header [String] a window caption
        attr_accessor :header
        # @return [String] selected file name
                attr_accessor :file
                                attr_reader :cpath
                                # @return [Array] file extensions to show
                attr_accessor :exts
                
                # Creates a files tree
                # @param header [String] a window caption
                # @param path [String] an initial path
                # @param hidefiles [Boolean] hide files
                # @param quiet [Boolean] don't write the caption at creation
                # @param file [String] a file to focus
                # @param exts [Array] an array of file extensions to show
                def initialize(header="",path="",hidefiles=false,quiet=false,file=nil,exts=nil,specialvoices=true)
                            $filestrees||={}
                                                @id=path+"/"+(file||"")+":"+(exts.join("")||"")+":::"+header
                @hidefiles=hidefiles
        @header=header
        @specialvoices=specialvoices
        @exts=exts
          if $filestrees[@id]!=nil
            f=$filestrees[@id]
            @file=f[1]
            @path=f[0]
                        #@file=nil if !FileTest.exists?(@path+"/"+@file)
          else
                    @path=path
        @file=""
                          @file=file if file!=nil
                        end
                        focus if quiet==false
        end
        
        # Updates a files tree
      def update(init=false)
        if $focus
          $focus=false
          speech(@file)
          end
        if @sel == nil or @refresh == true
              if @path == ""
                              buf = "\0" * 1024
          len = Win32API.new("kernel32", "GetLogicalDriveStrings", ['L', 'P'], 'L').call(buf.length, buf)
          @disks=buf.split("\0")
          for i in 0..@disks.size-1
            @disks[i].chop! if @disks[i][-1..-1]=="\\"
            end
@adds=[_("EAPI_Form:opt_desktop"),_("EAPI_Form:opt_documents"),_("EAPI_Form:opt_music")]
@addfiles=[getdirectory(16),getdirectory(5),getdirectory(13)]
ind=@disks.find_index(@file)      
ind=0 if ind==nil
                h=""
h=@header if init==true
@sel=Select.new(@disks+@adds,true,ind,h)
      @sel.silent=true if @specialvoices
      @files=@disks+@addfiles
else
  fls=Dir.entries(@path).polsort
fls.delete("..")
fls.delete(".")
if @hidefiles == true
  for i in 0..fls.size-1
    fls[i]=nil if File.file?(@path+fls[i])
  end
  fls.delete(nil)
  end
if @exts!=nil
          for i in 0..fls.size-1
          if File.file?(@path+fls[i])
          s=false
                    for e in @exts
     s=true if File.extname(@path+fls[i]).downcase==e.downcase
     end
  fls[i]=nil if s==false
  end
     end
  fls.delete(nil)
end
dirs=[]
for i in 0..fls.size-1
    if File.directory?(@path+fls[i])
      dirs.push(fls[i])
      fls[i]=nil
      end
  end
  fls.delete(nil)
  fls=dirs+fls
  ind=0
  ind=@sel.index if @sel!=nil
ind-=1 if ind>fls.size-1
ind=fls.find_index(@file,ind)
h=""
h=@header if init==true
@sel=Select.new(fls,true,ind,h,true)
@sel.silent=true if @specialvoices
@sel.focus if @refresh != true
@files=fls
@refresh=false
end
end
@sel.update
@file=@files[@sel.index]
@file="" if @sel.commandoptions.size==0
if cfile!=nil
if @file!=@lastfile and @specialvoices
  @lastfile=@file
          if filetype==0
            play("file_dir")
            elsif filetype==1
  play("file_audio")
elsif filetype==2
  play("file_text")
elsif filetype==3
  play("file_archive")
elsif filetype==4
  play("file_document")
  end
end
  end
  if $key[0x10]==false
if (arrow_right or @go == true) and File.directory?(cfile(true))
  @lastfile=nil
  @go = false
    s=true
        begin
    Dir.entries(cfile(true)) if s == true
  rescue Exception
    s=false
    retry
      end
  if s == true
        if @path!=""
    @path=cfile(true)+"\\"
          else
      @path=cfile(true)+"\\"
            end
  @file=""
        @sel=nil
  end
    end
if arrow_left and @path.size>0
  t=@path.split("\\")
  @file=t.last
  t[t.size-1]=""
@path=t.join("\\")
@sel=nil
end
end
$filestrees[@id]=[@path,@file]
end

def filetype
  return 0 if File.directory?(cfile(true))
  ext=File.extname(selected).downcase
  if ext==".mp3" or ext==".ogg" or ext==".wav" or ext==".mid" or ext==".wma" or ext==".flac" or ext==".aac" or ext==".opus" or ext==".m4a" or ext==".mov" or ext==".mp4" or ext==".avi" or ext==".mts" or ext==".aiff"
    return 1
  elsif ext==".txt"
    return 2
  elsif ext==".rar" or ext==".zip" or ext==".7z"
    return 3
  elsif ext==".doc" or ext==".rtf" or ext==".htm" or ext==".html" or ext==".docx" or ext==".pdf" or ext==".epub"
    return 4
  elsif ext==".eapi"
    return 5
      else
    return -1
    end
  end

# An opened path
# @return [String] an opened path
      def path(c=false)
        return @path if c==false
        return @path
      end
      
      # Opens a specified path
      #
      # @param pt [String] a path to open
      def path=(pt)
        @path=pt
        @sel=nil
      end
      
      # Opens the focused path
        def go
          @go = true
          update
        end
        
        # Gets the current file
        # @return [String] current file
        def cfile(fulllocation=false)
          return "" if @file==nil
                    tmp=@path+@file
tmp.gsub!("/","\\")
if fulllocation==false
return tmp.split("\\").last
else
  return tmp
end
end
        
          # Refreshes the tree
          def refresh
          @refresh=true
        end
        
        # Returns the path to the selected file or directory
        #
        # @param c [Boolean] use diacretics shortening
        # @return [String] the absolute path to a focused file or directory
          def selected(c=false)
            return "" if @file==nil
          r=""
          if c == false
            r = @path + @file
          else
            if cfile!=nil
            r = @path + cfile
          else
            return ""
            end
          end
          return r
          end
          
          def focus
          if @sel == nil        
          loop_update
            update(true)
          else
                    hin=""
          hin=@header+": \r\n" if @header!=""
                  hin += @file
        speech(hin)
        NVDA.braille(hin) if NVDA.check
        end
        end
      end
      
      class Static < FormChild
        attr_accessor :label
        def initialize(label="")
          @label=label
        end
        def update
        end
        def focus
          speech(@label)
          NVDA.braille(@label) if NVDA.check
        end
        end
      
     class Tree < FormChild
       attr_reader :sel
       attr_accessor :options
       attr_accessor :index
       attr_accessor :commandoptions
       attr_reader :opfocused
       def initialize(options,data=0,header="",quiet=false,lr=false,silent=false)
                index=0
         @options=options
         @header=header
         @silent=silent
         @lr=lr
         @way=[]
@sel=createselect([],0,true)
focus
end
def update
  @opfocused=false
        if @sel.selected? or @sel.expanded?
    o=@options.deep_dup
    for l in @way
      o=o[l][1..o[l].size-1]
    end
        if o[@sel.index].is_a?(Array)
            @way.push(@sel.index)
            @sel=createselect(@way)
            return
                  elsif enter
          @opfocused=true
          end
    end
              if @way.size>0 and (@lr!=2 and @sel.collapsed?) or (arrow_up and sel.index==0)
      ind=@way.last
      @way.delete_at(@way.size-1)
      @sel=createselect(@way,ind)
      return
    end
    @sel.update
  @index=getwayindex(@way+[@sel.index])-1
    end
       def createselect(way=[],selindex=0,quiet=false)
         opt=getelements(way)
         lr=@lr
         if lr==2
           if way.size==0
             lr=true
           else
             lr=false
             end
           end
         s=Select.new(opt,true,selindex,@header,true,false,lr,@silent)
         speech(s.commandoptions[s.index]) if quiet!=true
                  return s
         end
         def searchway(way=[],tway=[],index=0)
                                 return [index,tway] if way==tway
           t=@options.deep_dup
                      for l in tway
             t=(t[l]==nil)?nil:(t[l][1..t[l].size-1])
           end
           return [index,tway] if t.is_a?(Array)==false
                                 for i in 0..t.size-1
                          x=searchway(way,tway+[i],index+1)
               if x[1]==way
                                 return x
                                 break
               else
                 index=x[0]
                 end
                                         end
           return [index,tway]
         end
         def getwayindex(index)
                      return searchway(index)[0]
                                 end
         def getelements(way=[])
sou=@options.deep_dup
         for l in way
           sou=sou[l][1..sou[l].size-1]
                end
              ret=sou
for i in 0..ret.size-1
  while ret[i].is_a?(Array)
    ret[i]=ret[i][0]
    end
  end
return ret
         end
         def focus
@sel.focus         
         end
       end
      
      
# Creates a dialog with a listbox and returns the option selected by user
#
# @param options [Array] an array of option
# @param header [String] a window caption
# @param index [Numeric] an initial index
# @param escapeindex [Numeric] a value to return when pressed the escape key, if nil, the escape is not supported
# @param type [Numeric] if 1, the listbox is horizontal
# @return [Numeric] the index of a selected option
      def selector(options,header="",index=0,escapeindex=nil,type=0,border=true,cancelkey=nil)
        dis=[]
        for i in 0..options.size-1
          if options[i]==nil
            dis.push(i)
            options[i]=""
            end
          end
lsel=""
        if type == 0
        lsel = Select.new(options,border,index,header)
      else
        lsel = menulr(options,border,index,header)
      end
      for d in dis
        lsel.disable_item(d)
        end
        loop do
          loop_update
          lsel.update
          if enter
            return lsel.index
            break
          end
          if (escape or (cancelkey!=nil and $key[cancelkey])) and escapeindex!=nil
            loop_update
            return escapeindex
            break
            end
          end
        end
        
        def menuselector(options)
        dis=[]
        for i in 0..options.size-1
          if options[i]==nil
            dis.push(i)
            options[i]=""
            end
          end
lsel=""
        play("menu_open")
        play("menu_background")
lsel = menulr(options,true,0,"",true)
                    for d in dis
        lsel.disable_item(d)
      end
      lsel.update
      lsel.focus
        ret=-1
        loop do
          loop_update
          lsel.update
          if enter
            ret=lsel.index
            break
          end
          if alt or escape
            ret=-1
            break
            end
          end
        Audio.bgs_fade(100)
        play("menu_close")
        loop_update
        return ret  
        end
        
        # An alias to Select.new with lr set to 1
     def menulr(options,border=true,index=0,header="",quiet=false)
       return Select.new(options,border,index,header,quiet,false,true)
     end
     
     # Opens a file selection window and returns a path to file selected by user
     #
     # @param header [String] a window caption
     # @param path [String] an initial path
     # @param save [Boolean] hides a files, presents only directories
     # @param file [String] a file to focus
     # @return [String] an absolute path to a selected file or directory
     def getfile(header="",path="",save=false,file=nil,exts=nil)
              dialog_open
       loop_update
       ft=FilesTree.new(header,path,save,true,nil,exts)
       ft.file=file if file!=nil
                     ft.focus
       loop do
         loop_update
         ft.update
         if escape
           dialog_close
           return nil
           break
         end
         if enter
           dialog_close
           f=ft.path+ft.file
           f.chop! if f[f.size-1]=="\\"
           if save == false and File.file?(ft.selected(true))
             return f
           break
         end
         if save == true
           if File.directory?(f)
                          return f
             break
           else
             d=f.split("\\")
             d[d.size-1]=""
             f=d.join("\\")
             return f
             break
             end
           end
         end
         if space
           pt=ft.path
           ftp=input_text(_("EAPI_Form:type_location"),"ACCEPTESCAPE",ft.path)
           ft.path=ftp if ftp!="\004ESCAPE\004" and File.directory?(ftp)
           end
         end
       end  
       
       class TableSelect < FormChild
         attr_accessor :columns, :rows
         attr_reader :sel
         attr_accessor :header
         attr_reader :column
                  def initialize(columns=[], rows=[], index=0, header="", quiet=false)
           @columns, @rows = columns, rows
           @column=0
           @sel = Select.new(format_rows(@column), true, index, header, quiet)
         end
         def commandoptions
           @sel.commandoptions
           end
         def format_rows(col=0)
           opts=[]
           for r in @rows
             if r==nil or r.count(nil)==r.size
               o=nil
                              else
             o=""
                          o=r[col].to_s if r[col]!=nil
             for c in 0...@columns.size
               if c!=col&&r[c]!=nil
               o+=((c==0)?":":((o[-1..-1]!=":"&&o[-1..-1]!=".")?",":""))+" "
               o+=(@columns[c]||"")+": "+r[c].to_s
               end
             end
             end
             opts.push(o)
           end
                      return opts
         end
         def index
           return @sel.index
         end
         def index=(ind)
           @sel.index=(ind)
         end
         def column=(c)
           setcolumn(c)
         end
         def setcolumn(c)
@sel.commandoptions=format_rows(c)
           @column=c
           end
         def update
           if $keyr[0x10]&&@rows.size>0
             if arrow_right
               c=@column
               setcolumn((@column+1)%(@columns.size))
                              setcolumn((@column+1)%(@columns.size)) while (@rows[index][@column]==nil||@rows[index][@column]=="") and c!=@column
               speech (@rows[@sel.index][@column]||"")+" ("+(@columns[@column]||"")+")"
             elsif arrow_left
               c=@column
                           setcolumn((@column-1)%(@columns.size))
                           setcolumn((@column-1)%(@columns.size)) while (@rows[index][@column]==nil||@rows[index][@column]=="") and c!=@column
             speech (@rows[@sel.index][@column]||"")+" ("+(@columns[@column]||"")+")"
                 end
             end
           @sel.update
         end
         def focus
           @sel.focus
           end
         end
         
         class Player < FormChild
           attr_reader :sound
           attr_reader :pause
           attr_accessor :label
                        def initialize(file,label="", autoplay=true, quiet=false)
                          @label=label
                                                      speech(label) if label!="" and quiet==false
                                                      if file.is_a?(String)
setsound(file)
else
  @sound=file
  @file=@sound.file
  end
    @pause=false    
            @ppos=0
    if autoplay==true and @sound!=nil
      @sound.play
    else
      @pause=true
    end
    end
def setsound(file)
@sound = Bass::Sound.new(file,1)
@basefrequency=@sound.frequency
@file=file
@sound.volume=0.8
rescue Exception
  @sound=nil
  @file=nil
  alert(_("EAPI_Common:error_playing"))
end   

def update
  return if @sound==nil
      if space
                if @pause!=true
        @ppos=@sound.position
          @sound.pause
        @pause=true
              else
                        @sound.play
                                                                        @sound.position=@ppos if @sound.position<@ppos
        @pos=0
        @pause=false
                end
        end
  if $key[80]
    d=@sound.position.to_i
h=d/3600
        m=(d-d/3600*3600)/60
  s=d-d/60*60
  speech(sprintf("%0#{(h.to_s.size<=2)?2:d.to_s.size}d:%02d:%02d",h,m,s))
        end
  if $key[68]
    d=@sound.length.to_i
    h=d/3600
        m=(d-d/3600*3600)/60
  s=d-d/60*60
  speech(sprintf("%0#{(h.to_s.size<=2)?2:d.to_s.size}d:%02d:%02d",h,m,s))
    end
    if $key[74]
      @ppos=@sound.position.to_i
            @sound.pause
      dpos=input_text(_("EAPI_Common:type_movetosec"),"ACCEPTESCAPE",@ppos.to_s)
      dpos=@ppos if dpos=="\004ESCAPE\004"
      dpos=dpos.to_i
      dpos=@sound.length if dpos>@sound.length
      @sound.position=dpos
      @sound.play
      for i in 1..20
        @sound.position=dpos
      end
      loop_update
      end
    if ($key[0x53] or ($keyr[0x10] and enter)) and @file.include?("http")
    tf=@file.gsub("\\","/")
    fs=tf.split("/")
    nm=fs.last.split("?")[0]
    if File.extname(nm)==""
      l=@label.downcase
      if l.include?("mp3")
        nm+=".mp3"
      elsif l.include?(".wav")
        nm+=".wav"
      elsif l.include?(".ogg")
        nm+=".ogg"
      else
        nm+=".mp3"
        end
      end
    loc=getfile(_("EAPI_Common:head_savelocation"),getdirectory(40)+"\\",true,"Music")
    if loc!=nil
            speak(_("EAPI_Common:wait_downloading"))
                        waiting
                        executeprocess("bin\\ffmpeg -y -i \"#{@file}\" \"#{loc}\\#{nm}\"",true)
                        waiting_end
                                    alert(_("General:info_saved"))
      end
    end
    if $keyr[0x10]              ==false
    if arrow_right
                                            @ppos=@sound.position + 5
                                            10.times {
                @sound.position=@ppos
                break if ((@sound.position*10).to_i-(@ppos*10).to_i)==0
                }
              end
      if arrow_left
                @ppos=@sound.position - 5
                10.times {
                @sound.position=@ppos
                break if ((@sound.position*10).to_i-(@ppos*10).to_i)==0
                }
      end
            if arrow_up(true)
                      @sound.volume += 0.01
@sound.volume = 0.95 if @sound.volume > 0.95
      end
      if arrow_down(true)
        @sound.volume -= 0.01
@sound.volume = 0.05 if @sound.volume < 0.05
end
else
  if arrow_right(true)
        @sound.pan += 0.02
        @sound.pan = 1 if @sound.pan > 1
      end
      if arrow_left(true)
        @sound.pan -= 0.02
        @sound.pan = -1 if @sound.pan < -1
      end
            if arrow_up(true)
        @sound.frequency += @basefrequency.to_f/500.0*2.0
      @sound.frequency=@basefrequency*2 if @sound.frequency>@basefrequency*2
        end
      if arrow_down(true)
        @sound.frequency -= @basefrequency.to_f/500.0*2.0
      @sound.frequency=@basefrequency/2 if @sound.frequency<@basefrequency/2
end
end
if $key[0x08] == true
  reset=10
  @sound.volume=0.8
  @sound.pan=0
  @sound.frequency=@basefrequency
  end
  @pos=@sound.position
end

def fade
  return if @sound==nil
  for i in 1..100
    loop_update
    @sound.volume-=0.02
    if @sound.volume<=0.05
    @sound.volume=0
    loop_update
    break
    end
    end
  end

def close
  @sound.close if @sound!=nil
  @sound=nil
  end
           end
         
     end
     end
#Copyright (C) 2014-2019 Dawid Pieper