#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module Controls
    private
# Controls and forms related class
    
    def keyevents
      k=[]
      ks = {
65=>"a", 66=>"b", 67=>"c", 68=>"d", 69=>"e", 70=>"f", 71=>"g", 72=>"h", 73=>"i", 74=>"j",
75=>"k", 76=>"l", 77=>"m", 78=>"n", 79=>"o", 80=>"p", 81=>"q", 82=>"r", 83=>"s", 84=>"t",
85=>"u", 86=>"v", 87=>"w", 88=>"x", 89=>"y", 90=>"z",
48=>"0", 49=>"1", 50=>"2", 51=>"3", 52=>"4", 53=>"5", 54=>"6", 55=>"7", 56=>"8", 57=>"9",
32=>"space",
8=>"backspace", 9=>"tab", 13=>"enter",
0x10=>"shift", 0x11=>"control", 0x12=>"alt", 0x1B=>"escape",
0x21=>"pageup", 0x22=>"pagedown", 0x23=>"end", 0x24=>"home", 0x2D=>"insert", 0x2E=>"delete",
0xBC=>"comma", 0xBD=>"minus", 0xBE=>"period",
0x25=>"left", 0x26=>"up", 0x27=>"right", 0x28=>"down"
}
     for e in ks.keys
       k.push([("key_"+ks[e]).to_sym, ks[e].to_sym]) if $key[e]
       k.push([("keyr_"+ks[e]).to_sym, ks[e].to_sym]) if $keyr[e]
       k.push([("keyup_"+ks[e]).to_sym, ks[e].to_sym]) if $keyu[e]
       end
      return k
      end
    
      class FormBase
        attr_accessor :header
        def params
          @params||={}
          @params
          end
        def on(event, time=0, getparams=false, &block)
      @events||=[]
      @events.push([event,time,0,getparams,block])
    end
    def trigger(event, *params)
      return if @events==nil
      @events.each {|e|
if e[0]==event and e[2]<=Time.now.to_f-e[1]
e[2]=Time.now.to_f
a=*params
a||=[]
a.insert(0, params) if e[3]==true
e[4].call(a)
end
}
    end
    def wait
      focus
      @wait=true
      while @wait==true
        loop_update
        self.update
        end
    end
    def resume
      @wait=false
      loop_update
    end
    def disable_menu
      @disable_menu=true
    end
        def enable_menu
      @disable_menu=false
    end
    def menu_enabled?
      @disable_menu!=true
    end
    def disable_contextinglobal
      @disable_contextinglobal=true
    end
        def enable_contextinglobal
      @disable_contextinglobal=false
    end
    def contextinglobal_enabled?
      @disable_contextinglobal!=true
      end
                 def bind_context(h="", &b)
                                  @contexts||=[]
               @contexts.push([b, h])
             end
             def hascontext
               return false if @contexts==nil
               return @contexts.size>0
               end
    def context(menu, submenu=true)
      return if submenu && @disable_contextinglobal==true
      @contexts||=[]
      @contexts.each{|c|
      s=c[1]
      s=@header if s=="" and @header.is_a?(String)
      if s==""
        s=_("Context menu")
      else
        s+=" ("+_("Context menu")+")"
        end
      if submenu
      menu.submenu(s) {|m|
      c[0].call(m)
      }
    else
      c[0].call(menu)
      end
      }
      end
        def update(*arg)
      keyevents.each {|a| trigger(a[0]) if !key_processed(a[1])}
      $activecontrols.push(self) if $activecontrols.is_a?(Array)
    end
    def focus(index=nil,count=nil)
    end
    def blur
    end
    def key_processed(k)
      return false
      end
    end
    
    # A form  
    class Form < FormBase
      # @return   [Numeric] a form index
      attr_reader :index
      # @return [Array] an array of form fields
        attr_accessor :fields
        attr_accessor :cancel_button, :accept_button
        # Creates a form
        #
        # @param fields [Array] an array of form fields
        # @param index [Numeric] the initial index
        def initialize(fields=[],index=0,silent=false,quiet=false)
          @fields = fields
          @index = index
          @silent=silent
          @hidden=[]
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
              @fields[@index] = EditBox.new(@fields[@index][1],@fields[@index][2],@fields[@index][3],false,@fields[@index][4])
            end
            end
          if @fields[@index]!=nil && quiet==false
            @fields[@index].trigger(:before_focus)
            @fields[@index].focus(@index, @fields.size)
            @fields[@index].trigger(:focus)
            end
          play("form_marker") if @silent==false
          loop_update
        end
        
        # Updates a form
        def update
          super
          if $focus==true
            focus
            $focus=false
            end
          @index-=1 while (@fields[@index]==nil or @hidden[@index]==true) and @index>0
      @index+=1 while (@fields[@index]==nil or @hidden[@index]==true) and @index<@fields.size-1
                oldindex=@index                                
      if $key[0x09] == true
                                        speech_stop
            if $key[0x10] == false and @fields[@index].subindex==@fields[@index].maxsubindex
              ind=@index
              @index += 1
              while (@fields[@index] == nil or @hidden[@index]==true) and @index<@fields.size
                @index+=1
              end
              if @index >= @fields.size
                @index=ind
                trigger(:border)
                play("border", 100, 100, @index.to_f/(@fields.size-1).to_f*100.0)
            end
          elsif $key[0x10] and @fields[@index].subindex==0
ind=@index
            @index-=1
            while @fields[@index]==nil or @hidden[@index]==true
              @index-=1
              end
            if @index < 0
              @index = ind
              trigger(:border)
                          play("border", 100, 100, @index.to_f/(@fields.size-1).to_f*100.0)
                                      end
          end
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
@fields[@index] = EditBox.new(@fields[@index][1],@fields[@index][2],@fields[@index][3],false,@fields[@index][4])
            end
          end
          @fields[oldindex].trigger(:blur)
          @fields[oldindex].blur
          @fields[@index].trigger(:before_focus)
            @fields[@index].focus(@index, @fields.size)
            @fields[@index].trigger(:focus)
        else
                    @fields[@index].update
                  end
                  if escape && @cancel_button.is_a?(Button)
                    @cancel_button.press
                  end
if @fields[@index]!=nil && @accept_button!=nil && !@fields[@index].is_a?(Button)
  f=@fields[@index]
  if enter and (!f.key_processed(:enter) || $keyr[0x10])
    @accept_button.press
    end
  end
                end
                def append(field)
                  @fields.push(field)
                end
                
                def insert(index, field)
                  @fields.insert(index, field)
                end
                
                def insert_before(sfield, field)
                  f=@fields.index(sfield)||-1
                  @fields.insert(f, field)
                end
                
                def insert_after(sfield, field)
                  f=@fields.index(sfield)||-2
                  @fields.insert(f+1, field)
                  end
                
                def index=(ind)
                  ind=@fields.find_index(ind) if ind.is_a?(FormBase)
                  return if !ind.is_a?(Integer)
                  if @fields[@index].is_a?(FormBase)
                  @fields[@index].blur
                  @fields[@index].trigger(:blur)
                end
                @index=ind
                if @fields[@index].is_a?(FormBase)
                  @fields[@index].blur
                  @fields[@index].trigger(:blur)
                end
                  end
                def show_all
                  @hidden=[]
                  end
                def hide(index)
                  index=@fields.find_index(index) if index.is_a?(FormBase)
                  return if !index.is_a?(Integer)
                  @hidden[index]=true
                end
                def show(index)
                  index=@fields.find_index(index) if index.is_a?(FormBase)
                  return if !index.is_a?(Integer)
                  @hidden[index]=false
                  end
                def focus(index=nil,count=nil)
                  @fields[@index].focus(@index, @fields.size) if @fields[@index]!=nil
                end
                def key_processed(k)
                  if k==:tab
                    return true
                  elsif @fields[@index]!=nil
                    return @fields[@index].key_processed(k)
                  else
                    return false
                    end
                  end
                  end
                
                # Reads a text from user and returns it
                #
                # @param header [String] a window caption
                # @param type [String] the window type
                #  @see Edit
                # @param text [String] an initial text
  def input_text(header="", flags=0, text="", escapable=false)
    if flags.is_a?(String)
      Log.warning("String flags are no longer supported: "+Kernel.caller.join(" "))
      flags=0
      end
  ro = (flags & EditBox::Flags::ReadOnly)>0
  ro = (flags & EditBox::Flags::ReadOnly)>0
  ml = (flags & EditBox::Flags::MultiLine)>0
  ae = escapable
  dialog_open
  inp = EditBox.new(header,flags,text)
  inp.focus
  loop do
loop_update
    inp.update
    rtmp = false
    rtmp = true if ml == false or $key[0x11] == true
    break if enter and rtmp == true
    if (ro == true or (type.is_a?(Numeric) and (type&EditBox::Flags::ReadOnly)>0)) and (escape or alt or enter)
      r = ""
  r = nil if alt
    r=nil if $key[0x09] == true and $key[0x10] == false
    r=nil if $key[0x09] == true and $key[0x10] == true
    r=nil if escape
    Audio.bgs_stop
    dialog_close  
    return r
      break
      end
    if escape and ae == true
      Audio.bgs_stop
      dialog_close
      return nil
      break
      end
    end
    Audio.bgs_stop
    r=inp.text
  dialog_close
  loop_update
    return r
  end
  
  def input_user(header="", escapable=true)
    edt = EditBox.new(header, 0, "", true)
    edt.bind_context {|menu|
    menu.option(p_("EAPI_Form", "Select contact")) {
    s=selectcontact
    edt.settext(s) if s!=nil && s!=""
    edt.focus
    }
    }
    edt.focus
    loop do
      loop_update
      edt.update
      return nil if escape and escapable
      if arrow_up || arrow_down
s=selectcontact
    edt.settext(s) if s!=nil && s!=""
    edt.focus        
        end
      if enter
        usr=edt.text
        usr = finduser(usr) if usr.downcase == finduser(usr).downcase
        if user_exists(usr)
          return usr
        else
          alert(p_("EAPI_Form", "User does not exist"))
          end
        end
      end
    end
  
 
  class FormField < FormBase
    def focus(index=nil,count=nil)
      end
    def subindex
      return 0
    end
    def maxsubindex
      return 0
    end
    def update(*arg)
      super
            if $focus==true
        $focus=false
        focus
      end
        end
      end
  
  class EditBox < FormField
    @@customactions=[]
    @@lastedits=[]
    attr_accessor :index
        attr_accessor :flags
    attr_reader :origtext
    attr_accessor :silent    
    attr_accessor :audiotext
    attr_accessor :check
    attr_accessor :max_length
    attr_accessor :header
    def initialize(header="",type=0,text="",quiet=true,init=false,silent=false, max_length=-1)
      if type.is_a?(String)
        Log.warning("Text flags are no longer supported: "+Kernel.caller.join(" "))
        end
            @header=header
@flags=0
@flags=type if type.is_a?(Integer)
@silent=silent
@max_length=max_length
        settext(text)
                @origtext=text
      @index=@check=0
@redo=[]
@undo=[]
@formats=[]
@@lastedits.push(self) if (@flags&Flags::MultiLine)>0 && (@flags&Flags::ReadOnly)==0
@@lastedits.delete_at(0) while @@lastedits.size>20
focus if quiet==false
    end
    def update
super
focus if @audioplayer==nil and @audiotext!="" and @audiotext!=nil
      oldindex=@index
      oldtext=@text
      if $speechindexedthr!=nil and $speechid==@speechindexed and @speechindexed!=nil and $speechindex!=@index and ($speechindex||0)>0
        @index=$speechindex
      end
      if @audioplayer!=nil and escape
        blur
      elsif @audioplayer!=nil and @audioplayed==false
      if Configuration.voice==-1 or !speech_actived
        Programs.emit_event(:player_play)
      @audioplayer.play
      @audioplayed=true
    end
        end
      if @audioplayer!=nil && ((@audioplayer.pause==false && @audioplayer.completed == false) || ($key[0x20]))
          @audioplayer.update
                    return
                  end
navupdate
      editupdate
      ctrlupdate
      if oldindex!=@index or oldtext!=@text
          NVDA.braille(@text, @index, false, 0, nil, @index) if NVDA.check
        end
            esay
        end
def editupdate
  return readupdate if (@flags&Flags::ReadOnly)!=0
      if (c=getkeychar)!="" and (c.to_i.to_s==c or (@flags&Flags::Numbers)==0) and (@flags&Flags::ReadOnly)==0
                speech_stop if Configuration.typingecho>0 and !(Configuration.voice==-1 and NVDA.check)
        einsert(c)
                               if ((wordendings=" ,./;'\\\[\]-=<>?:\"|\{\}_+`!@\#$%^&*()_+").include?(c)) and ((Configuration.typingecho == 1 or Configuration.typingecho == 2))
                 s=@text[(@index>50?@index-50:0)...@index]
                                  w=(s[(0 ... s.length).find_all { |i| wordendings.include?(s[i..i]) or s[i..i]=="\n"}.sort[-2]||0..(s.size-1)])
if (w=~/([a-zA-Z0-9ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]+)/)!=nil
  espeech(w)
  play("edit_space") if c==" "
else
  espeech(c) if @interface_typingecho!=1
  end
elsif Configuration.typingecho==0 or Configuration.typingecho==2
         espeech(c)
      end
    elsif c!=""
            play("border") if c!=" "
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
if $keyr[0x11] && @index==@check && @index>0
  from=@index-1
  to=@index
  from-=1 while from>0 && (@text[from..from]=="\n" || @text[from..from]==" ")
  from-=1 while @text[from-1..from-1]!=" " && @text[from-1..from-1]!="\n" && from>0
  if from<to
  espeech(@text[from..to])
  edelete(from, to)
  play("edit_delete")
  end
  else
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
                    end
def readupdate
            if enter 
url=nil
@elements.each {|e| url=e.param[1] if (e.from<=@index and e.to>=@index) and e.type==Element::Link}
@elements.each {|e| url=e.param[1] if (e.from>=linebeginning and e.to<=lineending) and e.type==Element::Link} if url==nil
              if url!=nil
                                      speak(p_("EAPI_Form", "Opening a link..."))
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
    @index=e.from
    espeech(@text[e.from..e.to])
    elsif getkeychar!=""
    play("border")
    end
  end
                    def navupdate
            @vindex=$key[0x10]?@check:@index
            last=@vindex
            @ch=false
          if arrow_right
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
                                              elsif arrow_left
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
            @tosay+="\r\n(#{p_("EAPI_Common", "Checked: %{check}")%{'check'=>getcheck}})"
            play("edit_checked")
          else
            Audio.bgs_stop
            end
          end
          if last!=@vindex
          for e in @elements
            if last<e.from || last>e.to
              if @vindex>=e.from && @vindex<=e.to
                d=e.description
                @tosay=d+": "+@tosay
                end
              end
            end
            end
          Audio.bgs_stop if escape or (enter and $key[0x11]) or $key[0x9]
            esay
          end
          def ctrlupdate
       
  readtext(@index) if @index<@text.size and (($key[115] or ($keyr[0x2d] and arrow_down))) and (@audiotext==nil or @index>0)
  espeech(@text[linebeginning..lineending]) if $keyr[0x2d] and arrow_up
  esay
end
def setformatting(type, params=nil)
  c=[@index,@check].sort
                                                                  from=charborders(c[0])[0]
                              to=charborders(c[1])[1]
                              if to>from
                                s=false
                                for e in @elements
                                  next if e.type!=type
                                  s=true if e.from>=from && e.from<=to
                                  s=true if e.to>=from && e.to<=to
                                  s=true if e.from<from && e.to>to
                                end
                                if s==true
                                  del=[]
                                  ins=[]
                                  for e in @elements
                                    next if e.type!=type
                                    if e.from>=from && e.to<=to
                                      del.push(e)
                                    elsif e.from<from && e.to>from
                                      if e.to<to
                                        e.to=from-1
                                      else
                                        el=Element.new(to+1, e.to, type)
                                        del.push(e)
                                        ins.push(el)
                                                                                e.to=from-1
                                        end
                                        elsif e.from<to && e.to>to
                                      if e.from>from
                                        e.from=to+1
                                      else
                                        el=Element.new(e.from, from-1, type)
                                        ins.push(el)
                                                                                                                        e.from=to+1
                                      end
                                    end
                                  end
                                  del.each{|e| @elements.delete(e)}
                                  ins.each{|el| @elements.push(el)}
                                  play("edit_delete")
                                  else
                                    el=Element.new(from, to, type)
                                    @elements.push(el)
                                    play("edit_bigletter")
                                  end
                                                                  else
  if @formats.include?(type)
    @formats.delete(type)
    play("edit_delete")
  else
    @formats.push(type)
    espeech(Element.description(type))
  end
  end
  end
def context(menu, submenu=false)
  c=Proc.new {|menu|
  if (@flags&Flags::Formattable)>0
    menu.submenu(p_("EAPI_Form", "Format")) {|m|
    m.option(p_("EAPI_Form", "Bold"), nil, "b") {
    setformatting(Element::Bold)
    }
    m.option(p_("EAPI_Form", "Italic"), nil, "i") {
    setformatting(Element::Italic)
    }
    m.option(p_("EAPI_Form", "Underline"), nil, "u") {
    setformatting(Element::Underline)
    }
    m.submenu(p_("EAPI_Form", "Heading")) {|n|
    for i in 1..6
      n.option(p_("EAPI_Form", "Heading level %{level}")%{'level'=>i}, i, i.to_s) {|level|
      a=linebeginning
      b=lineending
      del=[]
      s=false
      for e in @elements
        if e.type==Element::Header && ((e.from>=a && e.from<=b) || (e.to>=a && e.to<=b))
          s=true if e.param==level
          del.push(e)
          end
      end
      del.each{|e| @elements.delete(e)}
      if s==false
      el=Element.new(a, b, Element::Header, level)
      @elements.push(el)
      play("edit_bigletter")
    elsif s==true
      play("edit_delete")
      end
      }
      end
    }
    }
    menu.submenu(p_("EAPI_Form", "Insert")) {|m|
    m.option(p_("EAPI_Form", "Link")) {
    form=Form.new([
    EditBox.new(p_("EAPI_Form", "URL"), 0, "", true),
    EditBox.new(p_("EAPI_Form", "Label"), 0, "", true),
    Button.new(p_("EAPI_Form", "Add")),
    Button.new(_("Cancel"))
    ])
    loop do
      loop_update
      form.update
      break if escape or form.fields[3].pressed?
      if form.fields[2].pressed?
        url=form.fields[0].text
        label=form.fields[1].text
        ind=@index
        einsert(label)
                el=Element.new(ind, ind+label.size-1, Element::Link, url)
        @elements.push(el)
        break
        end
    end
    loop_update
    speak(@text[linebeginning..lineending])
    }
    }
  end
  menu.option(p_("EAPI_Form", "Copy"), nil, "c") {
copy
  }
  if (@flags&Flags::ReadOnly)==0
    menu.option(p_("EAPI_Form", "Cut"), nil, "x") {
cut
  }
  menu.option(p_("EAPI_Form", "Paste"), nil, "v") {
paste
  }
  menu.option(p_("EAPI_Form", "Undo"), nil, "z") {
eundo
  }
  menu.option(p_("EAPI_Form", "Redo"), nil, "y") {
eredo
  }
  menu.submenu(p_("EAPI_Form", "Load last text")) {|m|
  for e in @@lastedits
    next if e==self
    t=(e.header+": "+e.text)[0...200]
    m.option(t, e) {|e|
    @@lastedits.push(self.deep_dup) if @text!=""
    settext(e.text)
    }
    end
  }
  end
  menu.option(p_("EAPI_Form", "Find"), nil, "f") {
search
  }
  menu.option(p_("EAPI_Form", "Quick translation"), nil, "t") {
  espeech(translatetext(0,Configuration.language,getcheck))
  }
  menu.option(p_("EAPI_Form", "Translate"), nil, "T") {
  translator(getcheck)
  }
  for a in @@customactions
      menu.option(a[0]) {
    a[1].call(self)
  }
    end
  }
    s=@header+" ("+_("Context menu")+")"
  s=p_("EAPI_Form", "Edit") if submenu==false
    menu.submenu(s) {|m|c.call(m)}
  super(menu, submenu)
end
def copy
      Clipboard.text = getcheck.gsub("\n","\r\n")
    alert(p_("EAPI_Form", "copied"), false)
  end
  def cut
        Clipboard.text=getcheck.gsub("\n","\r\n")
    c=[@index,@check].sort
    edelete(c[0],c[1])
    alert(p_("EAPI_Form", "Cut out"), false)

  end
  def paste
        einsert(Clipboard.text.delete("\r"))
    alert(p_("EAPI_Form", "pasted"), false)
  end
  def eundo
    return if @undo.size==0
          u=@undo.last
        @undo.delete_at(@undo.size-1)
u[0]==1?edelete(u[1],u[1]+u[2].size,false):einsert(u[2],u[1],false)
                    @redo.push(u)
          alert(p_("EAPI_Form", "undone"), false)
        end
        def eredo
          return if @redo.size==0
                r=@redo.last
        @redo.delete_at(@redo.size-1)
                r[0]==2?edelete(r[1],r[1]+r[2].size,false):einsert(r[2],r[1],false)
                    @undo.push(r)          
          alert(p_("EAPI_Form", "Repeated"), false)
        end
        def search
                search=input_text(p_("EAPI_Form", "Enter a phrase to look for"),0,@lastsearch||"",true)
      if search!=nil
        @lastsearch=search
            ind=@index<@text.size-1?@text[@index+1..@text.size-1].downcase.index(search.downcase):0
      ind+=@index+1 if ind!=nil
  ind=@text[0..@index].downcase.index(search.downcase) if ind==nil
    if ind==nil
  alert(p_("EAPI_Form", "No match found."), false)
else
  @index=ind
  readtext(@index)
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
    left,right=ind,ind
    right+=1 while right<@text.size-1 && (@text[right]||0)>=0xC0
      left-=1 while left>0 && (@text[left-1]||0)>=0xC0
    return [left, right]
    end
def getvlines(l,r)
    return [l,r+1] if r-l<120 or (@flags&Flags::MultiLine)==0 or (@flags&Flags::DisableLineWrapping)>0 or Configuration.linewrapping==0
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
    c=[@index,@check].sort
                                                                  from=charborders(c[0])[0]
                              to=charborders(c[1])[1]
                              edelete(from, to) if from<to && @text[from..to].chrsize>1
                              index-=1 while index>@text.size
    text.delete!("\n") if (@flags&Flags::ReadOnly)!=0
    if (@flags&EditBox::Flags::Numbers)>0
    text=text.to_i.to_s
    text="" if text!="0" and text.to_i==0
  end
          if @max_length>=0 and @text.chrsize+text.chrsize>@max_length
            play("border")
            return
            end
  @undo.push([1,index,text]) if toundo==true
@undo.delete_at(0) if @undo.size>100
@redo=[] if toundo==true
    applied=[]
        for e in @elements
      i=@formats.find_index(e.type)
      if e.from<=@index && e.to>=@index && (text!="\n" || i!=nil)
        play 'signal'
        e.to+=text.size
        applied[i]=true if i!=nil
      elsif i!=nil && applied[i]!=true && e.to==@index-1
        play 'right'
        e.to+=text.size
        applied[i]=true if i!=nil
      elsif e.from>@index
        e.from+=text.size
        e.to+=text.size
        end
      end
    for i in 0...@formats.size
      if applied[i]!=true
        e=Element.new(@index, @index, @formats[i])
        @elements.push(e)
        end
      end
          @text.insert(index,text)
      @index+=text.size
      NVDA.braille(text, @index, true, 1, index, @index)
  @check=@index
  trigger(:insert, index, text)
  trigger(:change)
end
def edelete(from,to,toundo=true)
@check=@index=from if @index>from
@undo.push([2,from,@text[from..to]]) if toundo==true
@redo=[] if toundo==true
@undo.delete_at(0) if @undo.size>100
del=[]
for e in @elements
  if e.from<=from && e.to>to
    e.to-=(to-from+1)
  elsif e.from>=from && e.to>to
    e.from+=(to-from+1)
  elsif e.from>=from && e.to<=to
    del.push(e)
    end
  end
  del.each{|e| @elements.delete(e)}
c=@text[from..to].chrsize
if c<20
c.times {
NVDA.braille("", @index, true, -1, from, @index)
}
end
@text[from..to]=""
Audio.bgs_stop
trigger(:delete, from, to)
trigger(:change)
@check=@index
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
    elsif (@flags&Flags::HTML)!=0
      html_proceed
    else
          @text.indices(/http(s?)\:\/\/([^\"\<\>\: \n]+)/).each {|ind| @elements.push(Element.new(ind,ind+(@text[ind..-1].index(/[ \n]/)||@text.size)-1,Element::Link,[0,@text[ind...ind+(@text[ind..-1].index(/[ \n]/)||@text.size-ind)]]))} if (@flags&Flags::ReadOnly)>0
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
                  def html_proceed
                    @markups=[]
                    suc=true
                    index=0
                    while suc
                      suc=false
                    @text.sub!(/(\<[^\>]+\>)/) {
                    phrase=$1
                    d=@text.index(phrase)
                    index=@text.index(phrase)
                    opening=(phrase[1..1]!="/")
                    sp=phrase.index(" ")||-1
                    b=1
                    b=2 if !opening
                    tag=phrase[b...sp]
                    attributes={}
                    if opening==true
                    if sp!=-1
                      t=phrase[sp..-2]
                      s=false
                      q=""
                      k=v=nil
                      for c in t.split("")
                        if q!="" && q==c
                          q=""
                          next
                          elsif q==""
                        if c=="\"" || c=="\'"
                          q=c
                          next
                      elsif s==false && c=="="
                        s=true
                        next
                      elsif c==" "
                        attributes[k]=v
                        next
                        end
                      end
                        if s==false
                          k+=c
                        else
                          v+=c
                          end
                        end
                        if k.is_a?(String) && v.is_a?(String) && k.size>0 && v.size>0
                          attributes[k]=v
                          end
                        end
                      @markups.push([index, tag, attributes]) if tag!="br"
                    else
                      mk=nil
                      for m in @markups.reverse
                        if m[1]==tag
                        mk=m
                        break
                        end
                      end
                      if mk!=nil
                        @markups.delete(mk)
                        @elements.push(Element.new(mk[0],index-1,Element::HTML,[tag,mk[2]]))
                        end
                      end
                    suc=true
                    if opening && (tag=="br" || tag=="p")
                      "\n"
                      else
                    ""
                    end
                    }
                  end
                  for k in HTML_PreCodes.keys
                    while @text.include?(k)
                      index=@text.index(k)
                      v=HTML_PreCodes[k]
@text.sub!(k, v)
                      r=k.size-v.size
                      for e in @elements
                        e.from-=r if e.from>index
                        e.to-=r if e.to>index
                        end                      
                      end
                    end
                  while (/(\&\#(\d+)\;)/=~@text) !=nil
                    k=$1
                      index=@text.index(k)
                      v=code_to_char($2.to_i)
                      @text.sub!(k, v)
                      r=k.size-v.size
                      for e in @elements
                        e.from-=r if e.from>index
                        e.to-=r if e.to>index
                        end
                    end
                    end
                def find_element(type=0,flags=nil,revdir=false,index=@index)
                  e=Element.new(@text.size,-1,0)
                  for el in @elements
                    e=el if (el.type==type and (flags==nil or el.param==flags)) and (((revdir==false and el.from>index and el.from<e.from) or (revdir==true and el.to<index and el.to>e.to)))
                  end
                  return nil if e.type==0
                  return e
                  end
def finalize
  text_str
  end
  def text_str
    Log.warning("Method EditBox::text_str is deprecated and will be removed soon. Use EditBox::text or EditBox::text_html instead. Callback: "+Kernel.caller.join("   "))
  return @text.gsub("\n","\004LINE\004")
end
def text
  @text.gsub("\n","\r\n")
end
def text_html
  r=""
objs={}
  for e in @elements
   objs[e.from]||=[]
   objs[e.from].push(e.html_open)
   t=e.to
   t+=1 if @text[t..t]!="\n"
   objs[t]||=[]
   objs[t].insert(0, e.html_close)
    end
  l=0
    for k in objs.keys.sort
      o=objs[k]
    r+=html_encode(@text[l...k])
    for b in o
      r+=b
    end
    l=k
  end
  r+=html_encode(@text[l..-1]||"")
  return r
  end
def value
  text
  end
  def focus(index=nil,count=nil,spk=true)
    pos=50
    pos=index.to_f/(count-1).to_f*100.0 if index!=nil and count!=nil && count!=0
      play("edit_marker", 100, 100, pos) if spk && Configuration.controlspresentation!=2
      tp=p_("EAPI_Form", "Edit box")
      tp=p_("EAPI_Form", "Text") if (@flags&Flags::ReadOnly)>0
      tp=p_("EAPI_Form", "Media") if @audiotext!=nil
      tph=tp+": "
      tph="" if Configuration.controlspresentation==1
      head=@header.to_s + "... " + tph
                              NVDA.braille(@header.to_s+"  "+@text, @header.to_s.size+2+@index-1,false,0,nil,@header.to_s.size+2+@index-1) if NVDA.check
                              if @audiotext!=nil
                                @audioplayer = Player.new(@audiotext, @header, false, true)
                                @audioplayed=false
                              end
                              if @audioplayer!=nil
                                speak(head)
                                return
                                end
                  return speak(head + ((@audiotext!=nil)?"\004AUDIO\004#{@audiotext}\004AUDIO\004":"") + text.gsub("\n"," "),1,false) if @audiotext!=nil and @audiotext!="" and spk
                        readtext(0,head) if spk
                      end
                      def blur
Audio.bgs_stop
                                                if @audioplayer!=nil
                        @audioplayer.close
                        @audioplayer=nil
                        end
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
  HTML=64
  Formattable=128
end
    class Element
    attr_accessor :from, :to, :type, :param
    Header=1
    Link=2
    List=3
        ListItem=4
    Quote=5
    Bold=11
    Italic=12
        Underline=13
    HTML=99
    def initialize(from=0,to=0,type=0,param=nil)
      @from,@to,@type,@param=from,to,type,param
            try_html if @type==HTML
    end
    def try_html
      return if !@param.is_a?(Array) || @param.size<2
      tag=@param[0]
      if tag.size==2&&tag[0..0]=="h"&&tag[1..1].to_i>0
        @type=Header
        @param=tag[1..1].to_i
        return
        end
      case tag
      when "b"
        @type=Bold
        @param=""
        when "i"
        @type=Italic
        @param=""
        when "u"
        @type=Underline
        @param=""
        when "a"
          @type=Link
          @param=@param[1]['href']
          when "ul"
            @type=List
            @param=0
            when "ol"
              @type=Link
              @param=1
              when "li"
                @type=ListItem
      end
    end
    def description
      self.class.description(@type, @param)
    end
    def html_open
      case @type
      when Bold
        return "<b>"
        when Italic
          return "<i>"
          when Underline
            return "<u>"
            when Header
              return "<h#{@param}>"
              when Link
                return "<a href=\"#{@param}\">"
                when List
                  return (@param==0)?("<ul>"):("<ol>")
                  when ListItem
                    return "<li>"
            when HTML
              s="<#{@param[0]}"
              if @param[1].size>0
                for k in @param[1].keys
                  s+=" "+k+"\""+@param[1][k]+"\""
                  end
                end
              s+=">"
              return s
          else
            return ""
      end
    end
    def html_close
      case @type
      when Bold
        return "</b>"
        when Italic
          return "</i>"
          when Underline
            return "</u>"
            when Header
              return "</h#{@param}>"
              when Link
                return "</a>"
                when List
                  return (@param==0)?("</ul>"):("</ol>")
                  when ListItem
                    return "</li>"
            when HTML
              return "</#{@param[0]}>"
    else
      return ""
      end
      end
    def self.description(t, param=nil)
      case t
      when Bold
        return p_("EAPI_Form", "Bold")
        when Italic
          return p_("EAPI_Form", "Italic")
          when Underline
            return p_("EAPI_Form", "Underline")
            when Header
              return p_("EAPI_Form", "Heading level %{level}")%{'level'=>param}
              when Link
                return p_("EAPI_Form", "Link")
                when List
                  return p_("EAPI_Form", "List")
                  when ListItem
                    return p_("EAPI_Form", "List item")
    else
      return ""
      end
      end
    end
    def key_processed(k)
     return true
   end
   def self.add_customaction(name, cls, &b)
     @@customactions.push([name, b, cls]) if b!=nil
   end
   def self.unregister_class(cls)
     for a in @@customactions.dup
       @@customactions.delete(a) if a[2]==cls
       end
     end
     def hascontext
       return true
       end
end

# A listbox class
    class ListBox < FormField
      # @return [Numeric] a listbox index
attr_accessor :index
# @return [Array] listbox options
attr_reader :options    
attr_reader :grayed
attr_reader :selected
attr_accessor :silent
attr_accessor :header
attr_accessor :prevent_indexspeaking
# Creates a listbox
#
class Flags
  MultiSelection=1
  LeftRight=2
  Silent=4
  end
  #
# @param options [Array] an options list
# @param header [String] a listbox caption
# @param index [Numeric] an initial index
# @param flags [Int] combination of flags
# @param quiet [Boolean] don't read a caption at creation
def initialize(options,header="",index=0,flags=0,quiet=false)
    $lastkeychar=nil
  options=options.deep_dup
        index = 0 if index == nil
           index = 0 if index >= options.size
      index+=options.size if index<0
      self.index = index
self.options=(options)
                                                @selected = []
                                                            for i in 0..@options.size - 1
              @grayed[i] = false if @grayed[i]!=true
              @selected[i] = false
              end
            @border = true
            @border=false if Configuration.listtype == 1
                                    @lr=((flags & Flags::LeftRight)>0)
            @multi=((flags & Flags::MultiSelection)>0)
@silent=((flags & Flags::Silent)>0)
            header="" if header==nil
                                    @header = header
                                                  focus if quiet == false
                                        end
            
            def options=(opts)
              @options=[]
              @grayed||=[]
              @hotkeys||={}
                                      hk=false
                                                ands=0
                        opts.each {|o| ands+=1 if o!=nil&&o.include?("\&")}
                                                hk=true if ands>opts.size/3
                                                                        for i in 0..opts.size - 1
                                                                          gray=false
              if opts[i]!=nil
if @lr or hk
                for j in 0..opts[i].size-1
  @hotkeys[opts[i][j+1..j+1].upcase[0]] = i if opts[i][j..j] == "&"
end
end
opt=opts[i]
opt.delete!("&") if @lr or hk
else
  opt=""
  gray=true
end
@options.push(opt)
@grayed[@options.size-1]=true if ((opt==nil)&&!lr)||gray
end            
end

def value
  self.index
  end
            
            # Update the listbox
    def update
super
  speak((@index+1).to_s+" / "+@options.size.to_s) if $key[115] and !$keyr[0x10] and @prevent_indexspeaking!=true
    oldindex = self.index
      options = @options
if ((@lr and arrow_left) or (!@lr and arrow_up)) and !$keyr[0x10] and !$keyr[0x2D] and !$keyr[0x11]
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
  elsif ((@lr and arrow_right) or (!@lr and arrow_down)) and !$keyr[0x10]  and !$keyr[0x2D] and !$keyr[0x11]
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
lspeak(@options[@index]) if $keyr[0x2D] and arrow_up
  if $keyr[0x10] and (arrow_up or arrow_down) and (tgs=tags).size>0
  ind=(tgs.index(@tag)||-1)+1
        if arrow_up
      ind-=1
    elsif arrow_down
      ind+=1
    end
            ind=ind%(tgs.size+1)
              if ind==0
    @tag=nil
    speak(p_("EAPI_Form", "All tags"))
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
                  while ishidden(self.index) == true and self.index<@options.size-i
    self.index += 1
  end              
              end
          else
            self.index = options.size-1
            end
            @run = true
  while ishidden(self.index) == true and self.index<@options.size
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
          if @hotkeys[i]==nil and @hotkeys.size<=@options.size/2
                  @run = true
                  j=self.index
                  l=k.chrsize==1?1:0
                  m=false
j+=($keyr[0x10])?(-l):(l)
                  loop do
                    if j>=options.size||j<=-1
                      if !m
                        j=($keyr[0x10])?(options.size-1):(0)
                        m=true
                      else
                        break
                        end
                        end
          if options[j]!=nil and options[j][0...k.size].upcase==k.upcase and ishidden(j)!=true
                    self.index = j
                    break
  end
                    j+=($keyr[0x10])?(-1):(1)
  break if j==self.index
        end
          elsif @hotkeys[i]!=nil and !ishidden(@hotkeys[i])
      @index = @hotkeys[i]
      $enter = 2
      end
      end
        if enter
      play("list_select") if @silent == false
      trigger(:select, self.index)
    end
    if collapsed?
      trigger(:collapse, self.index)
    end
    if expanded?
      trigger(:expand, self.index)
      end
    self.index = 0 if self.index >= options.size
  if self.index == -1
        while ishidden(self.index) == true
    self.index += 1
  end
  end
if self.index >= @options.size
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
o += " ("+ASCII(ss)+")" if ss.is_a?(Integer)
o += "\r\n\r\n(#{p_("EAPI_Common", "Checked")})" if @selected[self.index] == true
o||=""
o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
o=("\004NEW\004"+" "+((Configuration.soundthemeactivation==1)?"":$1+" ")+o).gsub(/\004INFNEW\{([^\}]+)\}\004/,"")
}
o=o.gsub(/\[#{Regexp.escape(@tag)}\]/i, "") if @tag!=nil
  lspeak(o) if !ishidden(self.index) && self.index>=0
  play("list_checked", 100, 100, self.index.to_f/(options.size-1).to_f*100.0) if @selected[self.index] == true
  focus(nil, nil, @header, false)
end
k=k.to_s if k.is_a?(Integer)
    if oldindex != self.index
  self.index = 0 if options.size == 1 or options[self.index] == nil
  play("list_focus", 100, 100, self.index.to_f/(options.size-1).to_f*100.0) if @silent == false
  trigger(:move, self.index)
@run = false
elsif oldindex == self.index and @run == true and (k.chrsize<=1 or (@options[self.index][0...k.size].upcase!=k.upcase))
    play("border", 100, 100, self.index.to_f/(options.size-1).to_f*100.0) if @silent == false
    trigger(:border, self.index)
    @run = false
  end
  if space and @multi == true
    trigger(:multiselection_beforechanged)
    if @selected[@index] == false
            @selected[@index] = true
            trigger(:multiselection_selected)
            trigger(:multiselection_changed)
      play("list_checked", 100, 100, self.index.to_f/(options.size-1).to_f*100.0)
      alert(p_("EAPI_Form", "Checked") ,false)
    else
      @selected[@index] = false
      trigger(:multiselection_unselected)
      trigger(:multiselection_changed)
      play("list_unchecked", 100, 100, self.index.to_f/(options.size-1).to_f*100.0)
      alert(p_("EAPI_Form", "Unchecked"), false)
      end
    end
  end
  
  def sayoption
    lspeak @options[self.index] if @options[self.index].is_a?(String) && !ishidden(self.index)
  end
  
  def lpos
        pos=50
    pos=self.index.to_f/(self.options.size-1).to_f*100.0 if self.options.size>1
    return pos
    end
  def lspeak(text)
    speak(text,1,true,nil,true,lpos)
    end
  
def focus(index=nil, count=nil, header=@header, spk=true)
  pos=50
    pos=index.to_f/(count-1).to_f*100.0 if index!=nil and count!=nil && count!=0
  if spk && Configuration.controlspresentation!=2
    if @multi==false
  play("list_marker", 100, 100, pos)  if @silent == false
else
  play("list_multimarker", 100, 100, pos)
end
end
              while ishidden(self.index) == true
                            self.index += 1
            end
            if self.index > @options.size - 1
              while ishidden(self.index) == true
              self.index -= 1
              end
              end
            options=@options
            sp=""
            if @header!=nil and @header!=""                
            sp = header
            sp+=" (#{p_("EAPI_Form", "Multiselection list")})" if @multi==true and Configuration.controlspresentation!=1
                            sp+=": " if !" .:?!,".include?(sp[-1..-1])
              sp+=" " if sp[-1..-1]!=" "
              end
            if options.size>0
              o = options[self.index].delete("&")
              o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
o=("\004NEW\004"+" "+((Configuration.soundthemeactivation==1)?"":$1+" ")+o).gsub(/\004INFNEW\{([^\}]+)\}\004/,"")
}
sp += o if !ishidden(self.index) && self.index>=0
ss = false
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
  end
sp += " ("+ASCII(ss)+")" if ss.is_a?(Integer)
end            
sp += p_("EAPI_Form", "Empty list") if @options.size==0
lspeak(sp) if spk
NVDA.braille(sp) if NVDA.check
end

# Hides a specified item
#
# @param id [Numeric] the id of an item to hide
    def disable_item(id)
  @grayed[id] = true
  options = @options
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
  return false if id<0 || id>=@options.size
  r=@grayed[id]==true
  r=true if @tag!=nil and !@options[id].downcase.include?("["+@tag.downcase+"]")
  return r
end
def tags
  tgs=[]
  @options.each {|t|
tgs+=t.scan(/\[([^[\[\]]]+)\]/).map{|x| x[0].downcase}
  }
 tgs.delete(nil) 
  return tgs.uniq
end
def multiselections
  ar=[]
  for i in 0...@options.size
    ar.push(i) if @selected[i]
    end
  return ar
  end
def selected?
  return (enter && @options.size>0 && self.index>=0 && !ishidden(self.index))
end
def expanded?
  return !$keyr[0x10] && ((@lr && arrow_down) || (!@lr && arrow_right))
end
def collapsed?
  return !$keyr[0x10] && ((@lr && arrow_up) || (!@lr && arrow_left))
end
def key_processed(k)
  if (@lr==false and (k==:up || k==:down))
    return true
  elsif (@lr==true and (k==:left || k==:right))
    return true
  elsif k.to_s.size==1
    return true
  elsif k==:home || k==:end || k==:pageup || k==:pagedown
    return true
  elsif @multi==true and k==:space
    return true
  else
    return false
    end
  end
end

# A button class
        class Button < FormField
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
super
  speech(@label) if $keyr[0x2D] and arrow_up
  @pressed = (enter||space)
  trigger(:press) if @pressed
          end
        def focus(index=nil,count=nil)
          pos=50
    pos=index.to_f/(count-1).to_f*100.0 if index!=nil and count!=nil && count!=0
          play("button_marker", 100, 100, pos) if Configuration.controlspresentation!=2
          tph="... " + p_("EAPI_Form", "Button")
          tph="" if Configuration.controlspresentation==1
          speak(@label + tph)
          NVDA.braille(@label) if NVDA.check
        end
        def pressed?
          pr=@pressed
          @pressed=false
          return pr
        end
        def press
          @pressed=true
          trigger(:press)
        end
        def key_processed(k)
          if k==:space || k==:enter
            return true
          else
            return false
            end
          end
      end
      
      # A checkbox class
      class CheckBox < FormField
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
super
  focus(nil, nil, true,false) if $keyr[0x2D] and arrow_up
          if space
            if @checked == 1
              @checked = 0
              alert(p_("EAPI_Form", "unchecked"), false)
            else
              @checked = 1
              alert(p_("EAPI_Form", "Checked"), false)
            end
            focus(nil, nil, false)
            trigger(:change)
            end
          end
          
          def value
            return @checked.to_i
            end
        
                    def focus(index=nil,count=nil, spk=true, snd=true)
                      pos=50
    pos=index.to_f/(count-1).to_f*100.0 if index!=nil and count!=nil && count!=0
          play("checkbox_marker", 100, 100, pos) if spk and snd && Configuration.controlspresentation!=2
          text = @label + " ... "
          if @checked == 0
            text += p_("EAPI_Form", "unchecked")
          else
            text += p_("EAPI_Form", "Checked")
          end
          if Configuration.controlspresentation!=1
          text += " "
          text += p_("EAPI_Form", "Checkbox")
          end
          speech(text) if spk
          NVDA.braille(text)
        end
        
        def key_processed(k)
          if k==:space
            return true
          else
            return false
            end
          end        
          end
      
      # Creates a files tree
      class FilesTree < FormField
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
                            path+="\\" if path[-1..-1]!="\\" and path!=""
                                                @id=path+"/"+(file||"")+":"+(exts.join("")||"")+":::"+header
                @hidefiles=hidefiles
        @header=header
        @specialvoices=specialvoices
        @exts=exts
        @editmenus=[]
        @filemenus=[]
        @createmenus=[]
        @menus=[]
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
super
        if @sel == nil or @refresh == true
              if @path == ""
                              buf = "\0" * 1024
          len = Win32API.new("kernel32", "GetLogicalDriveStrings", ['L', 'P'], 'L').call(buf.length, buf)
          @disks=buf.split("\0")
          for i in 0..@disks.size-1
            @disks[i].chop! if @disks[i][-1..-1]=="\\"
            end
@adds=[p_("EAPI_Form", "Desktop"),p_("EAPI_Form", "Documents"),p_("EAPI_Form", "Music")]
@addfiles=[Dirs.desktop,Dirs.documents,Dirs.music]
ind=@disks.find_index(@file)      
ind=0 if ind==nil
                h=""
h=@header if init==true
@sel=ListBox.new(@disks+@adds,h,ind)
@sel.on(:move) {trigger(:move)}
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
@sel=ListBox.new(fls,h,ind,0,true)
@sel.on(:move) {trigger(:move)}
@sel.silent=true if @specialvoices
@sel.focus if @refresh != true
@files=fls
@refresh=false
end
end
@sel.update
@file=@files[@sel.index]
@file="" if @sel.options.size==0
if cfile!=nil
if @file!=@lastfile and @specialvoices
  @lastfile=@file
          if filetype==0
            play("file_dir", 100, 100, @sel.lpos)
            elsif filetype==1
  play("file_audio", 100, 100, @sel.lpos)
elsif filetype==2
  play("file_text", 100, 100, @sel.lpos)
elsif filetype==3
  play("file_archive", 100, 100, @sel.lpos)
elsif filetype==4
  play("file_document", 100, 100, @sel.lpos)
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

def bind_editmenu(&m)
    @editmenus.push(m)
end

def bind_filesmenu(&m)
  @filemenus.push(m)
end

def bind_createmenu(&m)
  @createmenus.push(m)
end

def bind_menu(&m)
  @menus.push(m)
end

def context(menu, submenu=false)
    filepr=Proc.new {|menu|
    @filemenus.each{|f| f.call(menu)}
    menu.option(p_("EAPI_Form", "Rename")) {
    rename
    }
    menu.option(_("Delete"), nil, :del) {
    fdelete
    }
            }
                editpr=Proc.new {|menu|
  menu.option(p_("EAPI_Form", "Copy"), nil, "c") {
copy
  }
  menu.option(p_("EAPI_Form", "Paste"), nil, "v") {
paste
  }
                  @editmenus.each{|f| f.call(menu)}
    }
    createpr=Proc.new {|menu|
    menu.option(p_("EAPI_Form", "New folder"), nil, "n") {
        name=""
while name==""
      name=input_text(p_("EAPI_Form", "Folder name"),0,"", true)
      end
    if name != nil
      Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode(self.path+name),nil)
      alert(p_("EAPI_Form", "The folder has been created."))
    end
    refresh
    }
    @createmenus.each{|f| f.call(menu)}
    }
  if submenu==false
  s=p_("EAPI_Form", "File")
      menu.submenu(s) {|m|filepr.call(m)}
        s=p_("EAPI_Form", "Edit")
    menu.submenu(s) {|m|editpr.call(m)}
    s=p_("EAPI_Form", "Create")
    menu.submenu(s) {|m|createpr.call(m)}
    else
  s=@header+" - "+p_("EAPI_Form", "Files Tree")+" ("+_("Context menu")+")"
  menu.submenu(s){|m|
  filepr.call(m)
  editpr.call(m)
  createpr.call(m)
    }
  end
  @menus.each{|m| m.call(menu)}
  super(menu, submenu)
end

def filetype
  return 0 if File.directory?(cfile(true))
  ext=File.extname(selected).downcase
  if ext==".mp3" or ext==".ogg" or ext==".wav" or ext==".mid" or ext==".wma" or ext==".flac" or ext==".aac" or ext==".opus" or ext==".m4a" or ext==".mov" or ext==".mp4" or ext==".avi" or ext==".mts" or ext==".aiff" or ext==".m4v" or ext==".mkv" or ext==".vob" or ext==".m2ts"
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
          
          def focus(index=nil,count=nil)
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
      
      def paste
        files = Clipboard.files
        return if files.size==0
                waiting
        for file in files
          src=file
          dst=@path+File.basename(file)
          if File.directory?(file)
            copydir(src, dst)
          else
            copyfile(src, dst)
            end
          end
          waiting_end
          alert(p_("EAPI_Form", "Pasted"), false)
          refresh
        end
        
        def copy
          Clipboard.files=[selected]
                    alert(p_("EAPI_Form", "Copied"), false)
        end
        
        def rename
                name=""
    while name==""
    name=input_text(p_("EAPI_Form", "New file name"),0, self.file, true)
    end
    if name != nil
    Win32API.new("kernel32","MoveFileW",'pp','i').call(unicode(self.selected),unicode(self.path+name))
    alert(p_("EAPI_Form", "The file name has been changed."))
  end
  refresh
        end
        
        def fdelete
          afile=self.selected
          confirm(p_("EAPI_Form", "Do you really want to delete %{filename}?")%{'filename'=>self.file}) {
    if File.directory?(afile)
      deldir(afile)
    else
      File.delete(afile)
    end
    refresh
    alert(p_("EAPI_Form", "Deleted"))
}
end
def key_processed(k)
  if @sel!=nil
  return @sel.key_processed(k)
else
  return false
  end
end
def hascontext
  return true
  end
end
      
      class Static < FormField
        attr_accessor :label
        def initialize(label="")
          @label=label
        end
                def focus(index=nil,count=nil)
          speak(@label)
          NVDA.braille(@label) if NVDA.check
        end
        end
      
     class Tree < FormField
       attr_reader :sel
       attr_accessor :options
       attr_accessor :index
       attr_accessor :options
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
super
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
           flags=0
           flags||=ListBox::Flags::LeftRight if lr
           flags||=ListBox::Flags::Silent if @silent
         s=ListBox.new(opt,@header,selindex,flags,true)
         speak(s.options[s.index], 1, true, nil, true, s.lpos) if quiet!=true
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
         def focus(index=nil,count=nil)
@sel.focus         (index, count)
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
          flags=0
          flags=ListBox::Flags::LeftRight if type==1
lsel=ListBox.new(options, header, index, flags, true)
      for d in dis
        lsel.disable_item(d)
      end
      lsel.focus
      @cancel=false
      if cancelkey!=nil
        begin
          s=("key_"+cancelkey.to_s).to_sym
          lsel.on(s) {@cancel=true}
          rescue Exception
          end
        end
        loop do
          loop_update
          lsel.update
          if enter
            return lsel.index
            break
          end
          if (escape or @cancel==true) and escapeindex!=nil
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
        play("menu_background") if Configuration.bgsounds==1
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
        
        # An alias to ListBox.new with lr set to 1
     def menulr(options,border=true,index=0,header="",quiet=false)
       flags = ListBox::Flags::LeftRight
       return ListBox.new(options,header,index,flags, quiet)
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
           ftp=input_text(p_("EAPI_Form", "Choose a path"),0,ft.path,true)
           ft.path=ftp if ftp!=nil and File.directory?(ftp)
           end
         end
         
         def key_processed(k)
           return @sel.key_processed(k)
         end  
         end
       
       class TableBox < FormField
         attr_accessor :columns, :rows
         attr_reader :sel
         attr_accessor :header
         attr_reader :column
                  def initialize(columns=[], rows=[], index=0, header="", quiet=false)
           @columns, @rows = columns, rows
           @column=0
           @header=header
           @sel = ListBox.new(format_rows(@column), header, index, 0, quiet)
           @sel.on(:move) {trigger(:move)}
         end
         def options
           @sel.options
         end
         def sayoption
           @sel.sayoption
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
@sel.options=format_rows(c)
           @column=c
         end
         def reload
           @sel.options=format_rows(@column)
           end
         def update
super
           if $keyr[0x10]&&@rows.size>0
             if arrow_right
               c=@column
               setcolumn((@column+1)%(@columns.size))
                              setcolumn((@column+1)%(@columns.size)) while (@rows[index][@column]==nil||@rows[index][@column]=="") and c!=@column
               speak((@rows[@sel.index][@column]||"")+" ("+(@columns[@column]||"")+")", 1, true, nil, true, @sel.lpos)
             elsif arrow_left
               c=@column
                           setcolumn((@column-1)%(@columns.size))
                           setcolumn((@column-1)%(@columns.size)) while (@rows[index][@column]==nil||@rows[index][@column]=="") and c!=@column
             speak((@rows[@sel.index][@column]||"")+" ("+(@columns[@column]||"")+")", 1, true, nil, true, @sel.lpos)
                 end
             end
           @sel.update
         end
         def focus(index=nil,count=nil)
           @sel.focus(index, count)
         end
         
         def lpos
           @sel.lpos
           end
         
         def key_processed(k)
           if $keyr[0x10] && (k==:left || k==:right)
             return true
           else
             return @sel.key_processed(k)
             end
           end
         end
         
         class Player < FormField
           attr_reader :sound
           attr_reader :pause
           attr_accessor :label
                        def initialize(file,label="", autoplay=true, quiet=false)
                          Programs.emit_event(:player_init)
                          file=$url+file[1..-1] if FileTest.exists?(file)==false && file[0..0]=="/"
                          @label=label
                                                      speak(label) if label!="" and quiet==false
                                                      if file.is_a?(String)
setsound(file)
else
  @sound=file
  @file=@sound.file
  end
    @pause=false    
    if autoplay==true and @sound!=nil
      play
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
  alert(p_("EAPI_Common", "This file cannot be played."))
end   

def update
super
  return if @sound==nil || @sound.closed
      if space
                if @pause!=true
                  Programs.emit_event(:player_pause)
          @sound.pause
        @pause=true
      else
        Programs.emit_event(:player_play)
                        @sound.play
        @pause=false
                end
        end
  if $key[80]
    d=@sound.position.to_i
h=d/3600
        m=(d-d/3600*3600)/60
  s=d-d/60*60
  speak(sprintf("%0#{(h.to_s.size<=2)?2:d.to_s.size}d:%02d:%02d",h,m,s))
        end
  if $key[68]
    d=@sound.length.to_i
    h=d/3600
        m=(d-d/3600*3600)/60
  s=d-d/60*60
  speak(sprintf("%0#{(h.to_s.size<=2)?2:d.to_s.size}d:%02d:%02d",h,m,s))
    end
    if $key[74] && !@file.include?("http")
            @sound.pause
      dpos=input_text(p_("EAPI_Common", "Type a second to which you want to move."),0,@sound.position.to_s,true)
      dpos=@sound.position if dpos==nil
      dpos=dpos.to_i
      dpos=@sound.length if dpos>@sound.length
            @sound.play
      @sound.position=dpos
      loop_update
      end
    if ($key[0x53] or ($keyr[0x10] and enter)) and @file.include?("http")
      savefile
          end
    if $keyr[0x10]              ==false && $keyr[0x11]==false
    if arrow_right
                @sound.position+=5
                              end
      if arrow_left
                @sound.position-=5
                      end
            if arrow_up(true)
                      @sound.volume += 0.01
@sound.volume = 0.95 if @sound.volume > 0.95
      end
      if arrow_down(true)
        @sound.volume -= 0.01
@sound.volume = 0.05 if @sound.volume < 0.05
end
elsif $keyr[0x11]==true and $keyr[0x10]==false
  if arrow_up(true)
                      @sound.tempo += 2
@sound.tempo = 100 if @sound.tempo > 100
      end
      if arrow_down(true)
        @sound.tempo -= 2
@sound.tempo = -50 if @sound.tempo < -50
end
elsif $keyr[0x10]==true and $keyr[0x11]==false
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
  @sound.tempo=0
  @sound.frequency=@basefrequency
  end
end

def savefile
 
    tf=@file.gsub("\\","/")
    fs=tf.split("/")
    nm=fs.last.split("?")[0]
    nm=@label.delete("\r\n\\/:!@\#*?<>\'\"|+=`") if @label!="" and @label!=nil
        nm+=".opus"
        encoders=[]
        for e in MediaEncoders.list
          encoders.push(e) if e::Type==:audio
          end
        formats=[]
        for e in encoders
          f=e::Name+" ("+e::Extension+")"
          if e::Extension.downcase==".opus" && is_opus?
            f+= " ("+p_("EAPI_Form", "Copy original stream")+")"
            end
          formats.push(f)
          end
            dialog_open
        form=Form.new([
        tr_path = FilesTree.new(p_("EAPI_Form", "Destination"),Dirs.user+"\\",true,true,"Music"),
        lst_format = ListBox.new(formats, p_("EAPI_Form", "File format"), 0, 0, true),
        edt_filename = EditBox.new(p_("EAPI_Form", "File name"),"",nm),
        btn_save = Button.new(_("Save")),
        btn_cancel = Button.new(_("Cancel"))
        ])
        form.cancel_button=btn_cancel
        lst_format.on(:move) {
        eext=encoders[lst_format.index]::Extension
        fl=edt_filename.text
        ext=File.extname(fl)
        fb=(fl.reverse.sub(ext.reverse,"")).reverse
        edt_filename.settext(fb+eext)
        }
        edt_filename.on(:change) {
        ext=File.extname(edt_filename.text)
        for i in 0...encoders.size
          if encoders[i]::Extension.downcase==ext.downcase
            lst_encoders.index=i
            break
            end
          end
        }
        btn_cancel.on(:press) {form.resume}
        btn_save.on(:press) {
        encoder = encoders[lst_format.index]
        pth=tr_path.selected+"\\"+edt_filename.text
        waiting
        if encoder::Extension.downcase==".opus" && is_opus?
          downloadfile(@file, pth)
          else
        encoder.encode_file(@file, pth)
        end
        waiting_end
        alert(_("Saved"))
        form.resume
        }
form.wait
          dialog_close
        end
        
        def is_opus?
          if @file.include?("https://elten-net.eu/srv/audio")
            return true
          elsif @file.include?("https://s.elten-net.eu/") && @file[-4..-4]!="."
            return true
          else
            return false
            end
          end

def play
  Programs.emit_event(:player_play)
  @sound.play if @sound!=nil
  @pause=false
end

def stop
  Programs.emit_event(:player_stop)
  @sound.stop if @sound!=nil
  @pause=true
end

def completed
  return true if @sound==nil
  @sound.position(true)>=@sound.length(true)-1024 and @sound.length(true)>0
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
  Programs.emit_event(:player_close)
  @sound.close if @sound!=nil
  @sound=nil
  end
end

class Menu
  attr_accessor :header
  def initialize(header="", type=:default, &block)
    @type=type
    @options=[]
    @header=header
    @closed=true
    @on_close=[]
    @on_open=[]
    @instance=0
    if block_given?
          @caller=$scene
        if block.arity<=0
          @instance=1
          instance_eval(&block)
        else
          block.call(self)
        end
        end
    end
  def option(opt, v=nil, key="", &block)
    @options.push([opt, block, v, key])
  end
  def scene(opt, scene)
    @options.push([opt, :scene, scene])
  end
  def quickaction(opt, action)
    @options.push([opt, :quickaction, action])
    end
  def customoption(opt, &block)
    @options.push([opt, :custom, block])
  end
  def useroption(user)
    @options.push([user, :user, user])
    end
    
  def submenu(opt, &block)
    @options.push(opt)
    if block_given?
        if block.arity<=0
          @instance=1
          instance_eval(&block)
        else
          block.call(self)
        end
        end
    @options.push(nil)
  end
  def size
    @options.size
    end
    def on_close(&block)
    @on_close.push(block)
  end
  def on_open(&block)
    @on_open.push(block)
    end
  def open
    @closed=false
    if @on_open.size==0
    if @type==(:menubar) || @type==(:menu)
    play "menu_open"
    play("menu_background") if Configuration.bgsounds==1
    end
        show(0)
              else
        @on_open.each {|c| c.call}
        end
  end
  def show(index=0)
    h=""
        h=@header if index==0 and @type!=:menubar or @first==nil
        @first=true
    opts=[]
    acs=[]
    s=0
    inds=[]
    depth=0
    for i in 0...index
      depth+=1 if @options[i].is_a?(String)
      depth-=1 if @options[i]==nil
      end
    for i in index...@options.size
      c=@options[i]
      if s==0
        break if c==nil
        inds.push(nil)
        o=c
        o=c[0] if c.is_a?(Array)
        if c.is_a?(Array) and c[3]!="" and c[3]!=nil
          k=(c[3].is_a?(Symbol))?(c[3].to_s):(char_dict(c[3]))
          k="SHIFT+"+k.to_s if k.to_s.downcase!=k
          o+=(c[3].is_a?(Symbol))?(" "+k):(" (CTRL+"+k.to_s+")")
          end
        opts.push(o)
                acs.push(c)
              end
        if c.is_a?(String)
          inds[-1]||=i
          s+=1
        elsif c==nil
          s-=1
        end
      end
      return if opts.size==0
      flags = ListBox::Flags::Silent
      flags|=ListBox::Flags::LeftRight if (@type==:menubar)&&index==0
    sel=ListBox.new(opts, h, 0, flags)
    sel.on(:border) {play("border", 100, 100, sel.lpos)}
    sel.on(:move) {
    opt=acs[sel.index]
    if opt[1]==:user or opt[1]==:custom or opt.is_a?(String)
      play("list_submenu", 100, 100, sel.lpos)
    else
      play("list_focus", 100, 100, sel.lpos)
      end
    }
    sel.on(:select) {
        opt=acs[sel.index]
    if opt[1]!=:user and opt[1]!=:custom and !opt.is_a?(String)
      play("list_select", 100, 100, sel.lpos)
      end
    }
    loop {
    loop_update
    return if depth==1 and @type==:menubar and sel.index==0 and arrow_up
    sel.update
        return -1 if arrow_left and @type==:menubar and depth==1
        return 1 if arrow_right and @type==:menubar and depth>0 and (acs[sel.index].is_a?(Array) and (acs[sel.index][1]!=:user and acs[sel.index][1]!=:custom))
    if ((escape and depth==0) or (alt and (@type==:menubar or @type==:menu)))
      if @on_close.size==0
        close
      else
        @on_close.each {|c| c.call}
        end
      end
    break if @closing
    return if ((escape or (sel.collapsed? and (depth>1 or (depth==1 and @type!=:menubar)))) and index>0) and depth>0
        if sel.expanded? or sel.selected?
      opt=acs[sel.index]
      if opt[1]==:user
        play("list_expand", 100, 100, sel.lpos)
                u=usermenu(opt[2], true, true)
        if u=="ALT"
          close
        else
          play("list_close", 100, 100, sel.lpos)
          sel.focus
        end
      elsif opt[1]==:custom
        play("list_expand", 100, 100, sel.lpos)
                u=opt[2].call
        if u==true
          close
        else
          play("list_collapse", 100, 100, sel.lpos)
          sel.trigger(:move, sel.index)
          sel.focus
          end
        elsif opt.is_a?(String)
          play("list_expand", 100, 100, sel.lpos)
      a=show(inds[sel.index]+1)
      if a==nil
      sel.header="" if @type==:menubar
      play("list_collapse", 100, 100, sel.lpos) if !@closing
      sel.focus if !@closing
      loop_update
    else
      return a if depth>0
      sel.index=(sel.index+a)%acs.size
      $enter=2 if acs[sel.index].is_a?(String)
      end
    elsif sel.selected?
      close if @type!=:returning and opt[1]!=:user
      loop_update
      if opt[1]==:scene
        insert_scene(opt[2].new, true)
      elsif opt[1]==:quickaction
        opt[2].call
        else
      if opt[2]!=nil or @instance==0
      opt[1].call(opt[2])
    else
      @caller.instance_eval(&opt[1])
      end
    end
    end
      end
    }
  end
  def close
    if @type==:menubar || @type==:menu
    play("menu_close")
    Audio.bgs_fade(100)
    end
    @closing=true
    @closed=true
  end
  def opened?
    !@closed
  end
  def scenes
    sc=[]
    @options.each{|o|
    sc.push([o[0].delete("&"),o[2]]) if o.is_a?(Array) && o[1]==:scene
    }
    return sc
    end
  def items
    it=[]
    @options.each{|o|
    if o.is_a?(Array) && o[1].is_a?(Proc)
    it.push(o)
    end
    }
    return it
    end
  end
  
  class Timer
    attr_accessor :offset, :repeat
    def initialize(offset, repeat=false, dstart=true, &block)
      @scene=$scene
      @offset, @repeat = offset, repeat
      @block=block
      start if dstart
    end
    def reset
      @used=false
      end
    def start
      return if @used==true and @repeat==true
      @stopped=false
      @h=Thread.new {
      loop {
      o=@offset
      o=rand*(o.end-o.begin)+o.begin if @offset.is_a?(Range)
      sleep(o)
      begin
      @block.call
    rescue Exception
      p $!
      p $@
      end
      if @repeat==false
      @used=true
      break
      end
      }
      }
    end
        def stop
      @stopped=true
      @h.kill if @h!=nil
      @h=nil
      end
    end
  
  class MapObject
    attr_accessor :x, :y
    attr_accessor :range, :sound, :sound_range, :move_type, :move_delay
    def initialize(x,y, scene=nil, &block)
      @scene=$scene if scene==nil
      @x, @y = x, y
      @move_type = :fixed
      @move_delay = 0.5
      @laststep=0
      @range=0
      @sound_range=5
          if block_given?
        if block.arity<=0
          instance_eval(&block)
        else
          block.call(self)
        end
        end
    end
        def on(event, time=0, &block)
      @events||=[]
      @events.push([event,time,0,block])
    end
def trigger(event, *params)
      return if @events==nil
      @events.each {|e|
if e[0]==event and e[2]<=Time.now.to_f-e[1]
e[2]=Time.now.to_f
e[3].call
end
}
    end
    def path(x,y,ox,oy,walls,width,height)
            return [[x,y]] if x==ox&&y==oy
            mat=[]
            for i in 0...width
              mat[i]=[]
              for j in 0...height
                s=true
                s=false if walls.include?([i,j])
                mat[i][j]=s
                end
              end
              b=bfs(mat,x,y,ox,oy)
              b=[[x,y]] if b==nil
              return b
            end
def play(sound,x=nil,y=nil)
  x,y=@px,@py if x==nil||y==nil
  return if x==nil||y==nil
  d=Math::sqrt((@x-x)**2+(@y-y)**2)
  dx=(@x-x)/@sound_range.to_f
         dy=(@y-y)/@sound_range.to_f
         s=Bass::Sound.new(sound)
        s.pan=dx
        #s.frequency=@sound_handle.basefrequency*(1.0-dy.abs*0.2)
        s.volume=(@sound_range-d.to_f)/@sound_range
        s.play
        Thread.new {
        sleep(s.length)
        s.close
        }
  end
    def update(x, y, walls, width, height)
                d=Math::sqrt((@x-x)**2+(@y-y)**2)
      @px,@py=x,y
            if @laststep+@move_delay<Time.now.to_f
        @laststep=Time.now.to_f
        mx,my=@x,@y
        case @move_type
        when :follow
          mx,my=path(@x,@y,x,y,walls,width,height)[0]
                    when :random
            5.times {
                        mx=rand(3)-1
            my=rand(3)-1
            walls.each {|w| break if w[0]!=mx&&w[1]!=my }
            }
          end
          suc=true
          walls.each {|w| suc=false if w[0]==mx&&w[1]==my}
          @x,@y=mx,my if suc
                  end
      if @sound!=nil
        if @sound_handle==nil
          @sound_handle=Bass::Sound.new(@sound, 0, true)
        end
       if d<=@sound_range
         dx=(@x-x)/@sound_range.to_f
         dy=(@y-y)/@sound_range.to_f
        @sound_handle.pan=dx
        @sound_handle.frequency=@sound_handle.basefrequency*(1.0-dy.abs*0.2)
        v=(@sound_range-d.to_f)/@sound_range/2.0
        v+=0.5 if dy>=0
        @sound_handle.volume=v
        @sound_handle.play
      else
        @sound_handle.pause
        end
      end
      if d<@range
          keyevents.each {|a| trigger(a[0])}
          trigger(:range)
        end
        trigger(:touch) if x==@x&&y==@y
      end
      def dispose
        @sound_handle.close if @sound_handle!=nil
        @sound_handle=nil
        end
    end
         
  class Map
    attr_reader :width, :height, :direction, :objects
    attr_accessor :x, :y
    attr_accessor :move_sound, :border_sound, :wall_sound, :move_delay, :direction_sound, :direction_delay
    def initialize(width, height, &block)
      @scene=$scene
            @width, @height = width, height
            @direction=[0,0]
      @actions=[]
      @objects=[]
      @walls=[]
      @move_sound="list_focus"
      @x=0
      @y=0
      @move_delay=0.2
      @direction_delay=false
      @timers=[]
      if block_given?
        if block.arity<=0
          instance_eval(&block)
        else
          block.call(self)
        end
        end
    end
def wall(x1, y1, x2=nil, y2=nil)
  x2, y2 = x1, y1 if x2==nil||y2==nil
  x1,x2=x2,x1 if x1>x2
  y1,y2=y2,y1 if y1>y2
  x,y=x1,y1
    loop do
        @walls.push([x,y])
        break if x>=x2 && y>=y2
    x+=1 if x2>x1
    y+=1 if y2>y1
    end
  end
  def action(x,y,&block)
    @actions.push([x,y,block])
  end
  def object(x,y,&block)
    @objects.push(MapObject.new(x,y,@scene,&block))
  end
  def delete_object(o)
    o.dispose
    @objects.delete(o)
    end
  def timer(offset, repeat=false, &block)
    t=Timer.new(offset,repeat, false, &block)
    @timers.push(t)
    t
  end
  def distance(x,y)
    return Math::sqrt((@x-x)**2+(@y-y)**2)
  end
  def random_position(d=0)
    x,y=nil,nil
    while x==nil||y==nil||distance(x,y)<d
      x,y=rand(@width),rand(@height)
    end
    return [x,y]
    end
  def empty?(x,y)
    return !@walls.include?([x,y])
    end
  def directs?(x,y)
    d=[0,0]
      d[0]=-1 if x<@x
      d[0]=1 if x>@x
      d[1]=-1 if y<@y
      d[1]=1 if y>@y
      return d==@direction || d==[0,0]
    end
  def go(x,y)
        if x<0||x>=@width||y<0||y>=@height
      trigger(:border)
      play(@border_sound) if @border_sound!=nil
    else
      ld=@direction
      d=[0,0]
      d[0]=-1 if x<@x
      d[0]=1 if x>@x
      d[1]=-1 if y<@y
      d[1]=1 if y>@y
      if @direction!=d
      @direction=d
      play(@direction_sound) if @direction_sound!=nil
      return if @direction_delay
      end
      for w in @walls
        if w[0]==x&&w[1]==y
          play(@wall_sound) if @wall_sound!=nil
          trigger(:wall)
          return
          end
      end
      play(@move_sound) if @move_sound!=nil
      @x,@y=x,y
      for ac in @actions
        ac[2].call if ac[0]==x and ac[1]==y
      end
            trigger(:move)
            end
          end
          def on(event, time=0, &block)
      @events||=[]
      @events.push([event,time,0,block])
    end
def trigger(event, *params)
      return if @events==nil
      @events.each {|e|
if e[0]==event and e[2]<=Time.now.to_f-e[1]
e[2]=Time.now.to_f
@scene.instance_eval(&e[3])
end
}
    end
  def show(x=nil, y=nil)
    @x=x if x!=nil
    @y=y if y!=nil
    @disposed=false
    @timers.each {|t| t.start}
        laststep=0
        loop do
      loop_update
      keyevents.each {|a| trigger(a[0])}
      if (laststep+@move_delay)<Time.now.to_f
      if arrow_down(true)
        laststep=Time.now.to_f
go(@x, @y-1)
end
if arrow_up(true)
  laststep=Time.now.to_f
go(@x, @y+1)
end
if arrow_left(true)
  laststep=Time.now.to_f
go(@x-1, @y)
end
if arrow_right(true)
  laststep=Time.now.to_f
go(@x+1, @y)
end
end
@objects.each {|o| o.update(@x,@y,@walls, @width, @height)} if !@disposed
      break if @disposed
      end
  end
  def dispose
    @objects.each {|o| o.dispose}
    @timers.each {|t| t.stop}
    @disposed=true
    end
  end
    
  class OpusRecordButton < Button
attr_accessor :label
attr_reader :file
  def initialize(label, filename, max_bitrate=320, bitrate=64)
super(label)
@file = nil
    @filename=filename
    @max_bitrate=max_bitrate
    @bitrate = bitrate
    @bitrate = @max_bitrate if @bitrate>@max_bitrate
    @framesize = 60
    @application = 2048
    @usevbr = 1
    @recorder=nil
    @status = 0
    @current_filename=@filename
    @form = Form.new([
    @btn_record = Button.new(p_("EAPI_Form", "record")),
    @btn_pause = Button.new(p_("EAPI_Form", "Pause recording")),
    @btn_stop = Button.new(p_("EAPI_Form", "Stop recording")),
    @btn_usefile = Button.new(p_("EAPI_Form", "Use existing file")),
    @btn_encoder = Button.new(p_("EAPI_Form", "Opus encoder settings")),
    @btn_play = Button.new(p_("EAPI_Form", "Play")),
    @btn_encodeplay = Button.new(p_("EAPI_Form", "Encode and play")),
    @btn_delete = Button.new(p_("EAPI_Form", "Delete recording")),
    @btn_select = Button.new(p_("EAPI_Form", "Ready"))
    ], 0, false, true)
    @form.hide(@btn_pause)
    @form.hide(@btn_stop)
    @form.hide(@btn_play)
    @form.hide(@btn_encodeplay)
    @form.hide(@btn_delete)
    @btn_record.on(:press) {
        if @status==0 or confirm(p_("EAPI_Form", "Are you sure you want to delete the previous recording and create a new one?"))==1
          @current_filename = @filename
    play("recording_start")
    @status = 1
    @recorder = OpusRecorder.start(@filename, @bitrate, @framesize, @application, @usevbr)
    @form.hide(@btn_record)
    @form.hide(@btn_usefile)
    @form.hide(@btn_play)
    @form.hide(@btn_encoder)
    @form.hide(@btn_encodeplay)
    @form.hide(@btn_delete)
    @form.show(@btn_pause)
    @form.show(@btn_stop)
    end
    }
    @btn_stop.on(:press) {
    @recorder.stop
    play("recording_stop")
    @recorder=nil
    @status = 2
    @form.show(@btn_record)
    @form.show(@btn_play)
    @form.hide(@btn_encodeplay)
    @form.hide(@btn_pause)
    @form.hide(@btn_stop)
    @form.show(@btn_encoder)
    @form.show(@btn_usefile)
    @form.show(@btn_delete)
    @btn_record.label = p_("EAPI_Form", "Record again")
    @btn_pause.label = p_("EAPI_Form", "Pause recording")
    @form.index=0
    @form.focus
    }
    @btn_usefile.on(:press) {
    if @status==0 or confirm(p_("EAPI_Form", "Are you sure you want to delete the previous recording and create a new one?"))==1
      file=getfile(p_("EAPI_Form", "Select audio file"),Dirs.documents+"\\",false,nil,[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma",".opus",".aac"])
      if file!=nil
set_source(file)
        alert(p_("EAPI_Form", "File selected"))
        end
      end
      loop_update
    }
    @btn_play.on(:press) {
    player(@current_filename, p_("EAPI_Form", "Recording preview"))
    @form.focus
    }
    @btn_encodeplay.on(:press) {
    get_file
    @form.index=@btn_play
    @btn_play.press
    }
    @btn_pause.on(:press) {
    if @recorder.paused
      @btn_pause.label = p_("EAPI_Form", "Pause recording")
      @recorder.resume
      play("recording_start")
    else
      @btn_pause.label = p_("EAPI_Form", "Resume recording")
      @recorder.pause
      play("recording_stop")
      end
    }
    @btn_encoder.on(:press) {
    if @status==0 or @current_filename!=@filename or confirm(p_("EAPI_Form", "The encoder settings will not apply to the current record. Are you sure you want to continue?"))==1
      show_encodersettings
      @form.focus
      end
    }
    @btn_delete.on(:press) {
delete_audio
@form.index=0
        @form.focus
    }
    @btn_select.on(:press) {
    @btn_stop.press if @recorder!=nil
    @form.resume
    }
        @form.cancel_button = @btn_select
      end
      def delete_audio(force=false)
        return true if @status==0
            if @filename!=@current_filename or force or confirm(p_("EAPI_Form", "Are you sure you want to delete recorded audio?"))==1
              @btn_stop.press if @recorder!=nil
        File.delete(@filename) if FileTest.exists?(@filename)
        @form.hide(@btn_delete)
        @form.hide(@btn_play)
        @status=0
                return true
      else
        return false
      end
        end
      def update
super
if @pressed
  show
  focus
  end
end
def show_encodersettings
  profiles = [
  [p_("EAPI_Form", "Low"), 24, 60, 0],
  [p_("EAPI_Form", "Lower"), 32, 60, 0],
  [p_("EAPI_Form", "Standard"), 48, 60, 0],
[p_("EAPI_Form", "Higher"), 64, 60, 0],
[p_("EAPI_Form", "High"), 96, 60, 0],
[p_("EAPI_Form", "Max"), @max_bitrate, 120, 0]
  ]
  for pr in profiles
    profiles.delete(pr) if pr[1]>@max_bitrate
    end
  appind=@application==2048?0:1
  form = Form.new([
  lst_profile = ListBox.new(profiles.map{|pr|pr[0]}+[p_("EAPI_Form", "Custom")], p_("EAPI_Form", "Quality")),
    lst_bitrate = ListBox.new(bitrates_available.map{|b|b.to_s+" kbps"}, p_("EAPI_Form", "Bitrate"), bitrates_available.find_index(@bitrate)||0, 0, true),
  lst_framesize = ListBox.new(framesizes_available.map{|f|f.to_s+" ms"}, p_("EAPI_Form", "Frame size"), framesizes_available.find_index(@framesize)||0, 0, true),
  lst_application = ListBox.new([p_("EAPI_Form", "Speech profile"), p_("EAPI_Form", "Music profile")], p_("EAPI_Form", "Encoder profile"), appind, 0, true),
  chk_usevbr = CheckBox.new(p_("EAPI_Form", "Use variable bitrate"), @usevbr),
  btn_save = Button.new(_("Save")),
  btn_cancel = Button.new(_("Cancel"))
  ], 0, false, true)
  lst_profile.on(:move) {
  if lst_profile.index<profiles.size
  pr=profiles[lst_profile.index]
  lst_bitrate.index = bitrates_available.find_index(pr[1])||0
  lst_framesize.index = framesizes_available.find_index(pr[2])||0
  lst_application.index=0
  chk_usevbr.checked=1
  form.hide(lst_bitrate)
  form.hide(lst_framesize)
  form.hide(lst_application)
  form.hide(chk_usevbr)
else
  form.show(lst_bitrate)
  form.show(lst_framesize)
  form.show(lst_application)
  form.show(chk_usevbr)
  end
  }
  suc=false
  for i in 0...profiles.size
    pr=profiles[i]
    bitrate = bitrates_available[lst_bitrate.index]
    framesize = framesizes_available[lst_framesize.index]
    if bitrate==pr[1] && framesize==pr[2] && lst_application.index==0 && chk_usevbr.checked==1
lst_profile.index=i
lst_profile.trigger(:move)
suc=true
      end
    end
    if suc==false
      lst_profile.index=profiles.size
      lst_profile.trigger(:move)
      end
  btn_cancel.on(:press) {form.resume}
  btn_save.on(:press) {
  @bitrate = bitrates_available[lst_bitrate.index]
  @framesize = framesizes_available[lst_framesize.index]
  @application = lst_application.index==0?2048:2049
  @usevbr = chk_usevbr.checked
  form.resume
  }
  form.cancel_button = btn_cancel
  form.accept_button = btn_save
  form.wait
end
def framesizes_available
  [2.5, 5, 10, 20, 40, 60, 80, 100, 120]
end
def bitrates_available
  all = [8, 16, 24, 32, 48, 64, 80, 96, 128, 160, 196, 256, 320]
  m=[]
  for b in all
    m.push(b) if b<=@max_bitrate
  end
  return m
  end
      def show
        @form.index=0
        @form.wait
      end
      def empty?
        @status==0
      end
      def set_source(file)
        @btn_stop.press if @recorder!=nil
                @status=2
        @current_filename = file
        @form.show(@btn_play)
        if file[0..4]=="http:" or file[0..5]=="https:"
        @form.hide(@btn_encodeplay)
      else
        @form.show(@btn_encodeplay)
        end
        @form.show(@btn_delete)
        end
      def get_file
        return nil if @status!=2
        return nil if @current_filename[0..4]=="http:" || @current_filename[0..5]=="https:" 
        if @filename!=@current_filename
          waiting
          OpusRecorder.encode_file(@current_filename, @filename, @bitrate, @framesize, @application, @usevbr)
          waiting_end
              @current_filename = @filename
    @form.hide(@btn_encodeplay)
          end
        return @filename
        end
end

class DateButton < Button
  attr_reader :year, :month, :day, :hour, :min, :sec
  def initialize(label, minyear=1900, maxyear=2100, includehour=false)
    @year, @month, @day, @hour, @min, @sec = 0, 0, 0, 0, 0, 0
    @dlabel=label
genlabel
super(@label)
    @minyear=minyear
    @maxyear=maxyear
    @includehour=includehour
    @years=(@minyear..@maxyear).to_a.map{|y|y.to_s}
    @months = [p_("EAPI_Form", "January"), p_("EAPI_Form", "February"), p_("EAPI_Form", "March"), p_("EAPI_Form", "April"), p_("EAPI_Form", "May"), p_("EAPI_Form", "June"), p_("EAPI_Form", "July"), p_("EAPI_Form", "August"), p_("EAPI_Form", "September"), p_("EAPI_Form", "October"), p_("EAPI_Form", "November"), p_("EAPI_Form", "December")]
    @days=(1..31).to_a.map{|d|d.to_s}
    @hours=(0..23).to_a.map{|h|sprintf("%02d",h)}
    @mins=(0..59).to_a.map{|m|sprintf("%02d",m)}
    @secs=(0..59).to_a.map{|s|sprintf("%02d",s)}
    @form = Form.new([
    @sel_year = ListBox.new([p_("EAPI_Form", "Not selected")]+@years, p_("EAPI_Form", "Year"), 0, 0, true),
    @sel_month = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Month"), 0, 0, true),
    @sel_day = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Day"), 0, 0, true),
@sel_hour = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Hour"), 0, 0, true),
@sel_min = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Minute"), 0, 0, true),
@sel_sec = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Second"), 0, 0, true),
    @btn_select = Button.new(p_("EAPI_Form", "Ready")),
    @btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    if @includehour==false
      @form.hide(@sel_hour)
      @form.hide(@sel_min)
      @form.hide(@sel_sec)
      end
    @form.cancel_button = @btn_cancel
    @form.accept_button = @btn_select
    @btn_cancel.on(:press) {@form.resume}
    @btn_select.on(:press) {
   if @sel_year.index==0
     @year=0
   else
     @year=@sel_year.index+@minyear-1
   end
   @month=@sel_month.index
   @day=@sel_day.index
   if @year==0 || @month==0 || @day==0
     @year=0
     @month=0
     @day=0
   end
   if @includehour==true
     @hour=@sel_hour.index-1
     @min=@sel_min.index-1
     @sec=@sel_sec.index-1
     if @hour==-1 || @min==-1 || @day==-1
       @year=0
     @month=0
     @day=0
     @hour=-1
     @min=-1
     @sec=-1
       end
     end
   @form.resume
    }
    @sel_year.on(:move) {
    if @sel_year.index==0
      @sel_month.options=[p_("EAPI_Form", "Not selected")]
    else
      @sel_month.options=[p_("EAPI_Form", "Not selected")]+@months
      end
        @sel_month.index-=1 while @sel_month.index>=@sel_month.options.size
        @sel_month.trigger(:move)
    }
    @sel_month.on(:move) {
    if @sel_month.index==0
      @sel_day.options=[p_("EAPI_Form", "Not selected")]
    else
      days=31
      days=30 if [4, 6, 9, 11].include?(@sel_month.index)
      if @sel_month.index==2
        if (@sel_year.index+@minyear-1)%4==0 && (((@minyear+@sel_year.index-1)%100)!=0 || ((@minyear+@sel_year.index-1)%400)==0)
          days=29
        else
          days=28
        end
        end
        @sel_day.options = [p_("EAPI_Form", "Not selected")]+@days[0...days]
      end
              @sel_day.index-=1 while @sel_day.index>=@sel_day.options.size
              @sel_day.trigger(:move)
    }
    @sel_day.on(:move) {
    if @sel_day.index==0
      @sel_hour.options=[p_("EAPI_Form", "Not selected")]
    else
      @sel_hour.options=[p_("EAPI_Form", "Not selected")]+@hours
    end
    @sel_hour.index-=1 while @sel_hour.index>=@sel_hour.options.size
              @sel_hour.trigger(:move)
    }
    @sel_hour.on(:move) {
    if @sel_hour.index==0
      @sel_min.options=[p_("EAPI_Form", "Not selected")]
    else
      @sel_min.options=[p_("EAPI_Form", "Not selected")]+@mins
    end
    @sel_min.index-=1 while @sel_min.index>=@sel_min.options.size
              @sel_min.trigger(:move)
    }
    @sel_min.on(:move) {
    if @sel_min.index==0
      @sel_sec.options=[p_("EAPI_Form", "Not selected")]
    else
      @sel_sec.options=[p_("EAPI_Form", "Not selected")]+@mins
    end
    @sel_sec.index-=1 while @sel_sec.index>=@sel_sec.options.size
              @sel_sec.trigger(:move)
    }
  end
  def genlabel
    @label=@dlabel+": "
    if @year==0
      @label+=p_("EAPI_Form", "Not selected")
    else
      if @includehour==false
      @label+=sprintf("%04d-%02d-%02d", @year, @month, @day)
    else
      @label+=sprintf("%04d-%02d-%02d, %02d:%02d:%02d", @year, @month, @day, @hour, @min, @sec)
      end
      end
    end
    def focus(*arg)
      genlabel
      super(*arg)
      end
  def update
    super
    if @pressed
      show
      focus
    end
  end
  def show
    @form.index=0
    @form.wait
    end
  end

  end
  include Controls
end