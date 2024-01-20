# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Polls
  def initialize(lastpoll = 0)
    @lastpoll = lastpoll
  end

  def main
    @sel = TableBox.new([nil, p_("Polls", "Author"), p_("Polls", "Votes"), nil], [], 0, p_("Polls", "Polls"))
    @sel.bind_context { |menu| context(menu) }
    @allpolls = []
    refresh
    @polls = []
    polls_filter
    @sel.focus
    loop do
      loop_update
      @sel.update
      $scene = Scene_Main.new if escape
      if enter and @sel.options.size > 0
        selt = [p_("Polls", "Vote"), p_("Polls", "Show results"), p_("Polls", "Show report")]
        if Session.name != "guest"
          v = srvproc("polls", { "voted" => "1", "poll" => @polls[@sel.index].id })
          if v[0].to_i < 0
            alert(_("Error"))
            $scene = Scene_Main.new
            return
          end
          if v[1].to_i == 1
            selt[0] = nil
          end
        end
        if Session.name == "guest" || @banned
          selt[0] = ""
        end
        case menuselector(selt)
        when 0
          $scene = Scene_Polls_Answer.new(@polls[@sel.index].id)
        when 1
          $scene = Scene_Polls_Results.new(@polls[@sel.index].id)
        when 2
          $scene = Scene_Polls_Report.new(@polls[@sel.index].id)
        end
      end
      break if $scene != self
    end
  end

  def refresh
    @banned = false
    @banned = isbanned(Session.name) if Session.name != "guest"
    polls = srvproc("polls", { "list" => 1, "details" => 2 })
    if polls[0].to_i < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    t = 0
    @allpolls = []
    id = 0
    pl = 0
    for i in 2..polls.size - 1
      case t
      when 0
        id = polls[i].to_i
        @allpolls[pl] = Struct_Polls_Poll.new(id)
        t += 1
      when 1
        @allpolls[pl].name = polls[i].delete("\r\n")
        t += 1
      when 2
        @allpolls[pl].author = polls[i].delete("\r\n")
        t += 1
      when 3
        @allpolls[pl].created = polls[i].to_i
        t += 1
      when 4
        @allpolls[pl].language = polls[i].delete("\r\n")
        t += 1
      when 5
        @allpolls[pl].voted = true if polls[i].to_i > 0
        t += 1
      when 6
        @allpolls[pl].votes = polls[i].to_i
        t += 1
      when 7
        if polls[i].delete("\r\n") != "\004END\004"
          @allpolls[pl].description += polls[i]
        else
          t = 0
          pl += 1
        end
      end
    end
  end

  def polls_filter
    @lastpoll = @polls[@sel.index].id if @polls.is_a?(Array) and @polls.size > 0
    @polls = []
    knownlanguages = Session.languages.split(",").map { |lg| lg.upcase }
    for pl in @allpolls
      @polls.push(pl) if LocalConfig["PollsShowUnknownLanguages"] == 1 || knownlanguages.size == 0 || knownlanguages.include?(pl.language[0..1].upcase)
    end
    selt = []
    index = 0
    for poll in @polls
      if poll != nil
        selt.push([poll.name, poll.author, poll.votes.to_s, poll.description])
        index = selt.size - 1 if poll.id == @lastpoll
      end
    end
    @sel.rows = selt
    @sel.reload
    @sel.index = index
  end

  def context(menu)
    if @sel.options.size > 0
      if Session.name != "guest" && !@banned
        if !@polls[@sel.index].voted
          menu.option(p_("Polls", "Vote"), nil, "v") {
            $scene = Scene_Polls_Answer.new(@polls[@sel.index].id)
          }
        end
      end
      menu.option(p_("Polls", "Show results"), nil, "t") {
        $scene = Scene_Polls_Results.new(@polls[@sel.index].id)
      }
      menu.option(p_("Polls", "Show report"), nil, "p") {
        $scene = Scene_Polls_Report.new(@polls[@sel.index].id)
      }
      if Session.moderator == 1 or @polls[@sel.index].author == Session.name
        menu.option(_("Delete"), nil, :del) {
          if confirm(p_("Polls", "Do you really want to delete %{name}?") % { "name" => @polls[@sel.index].name }) == 1
            pl = srvproc("polls", { "del" => "1", "id" => @polls[@sel.index].id })
            if pl[0].to_i < 0
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
    if Session.languages.size > 0
      s = p_("Polls", "Show polls in unknown languages")
      s = p_("Polls", "Hide polls in unknown languages") if LocalConfig["PollsShowUnknownLanguages"] == 1
      menu.option(s) {
        l = 1
        l = 0 if LocalConfig["PollsShowUnknownLanguages"] == 1
        LocalConfig["PollsShowUnknownLanguages"] = l
        polls_filter
        @sel.focus
      }
    end
    if Session.name != "guest" && !@banned
      menu.option(p_("Polls", "New poll"), nil, "n") {
        $scene = Scene_Polls_Create.new
      }
    end
    menu.option(_("Refresh"), nil, "r") {
      $scene = Scene_Polls.new
    }
  end
end

class Scene_Polls_Create
  def main
    @ln = []
    ls = []
    lnindex = 0
    for lk in Lists.langs.keys
      l = Lists.langs[lk]
      ls.push(l["name"] + " (" + l["nativeName"] + ")")
      @ln.push(lk)
      lnindex = @ln.size - 1 if Configuration.language.downcase[0..1] == lk.downcase[0..1]
    end
    @fields = [EditBox.new(p_("Polls", "Poll name"), "", "", true), EditBox.new(p_("Polls", "Description"), EditBox::Flags::MultiLine, "", true), ListBox.new(ls, p_("Polls", "Poll language"), lnindex), ListBox.new([], p_("Polls", "Questions")), CheckBox.new(p_("Polls", "Set the expiry date for this poll")), DateButton.new(p_("Polls", "Expiry date"), Time.now.year, Time.now.year + 3, true), CheckBox.new(p_("Polls", "Hide poll results before the expiry date")), CheckBox.new(p_("Polls", "Hide this poll")), Button.new(p_("Polls", "Create")), Button.new(_("Cancel"))]
    @fields[3].bind_context { |menu| questions_context(menu) }
    @form = Form.new(@fields)
    @fields[4].on(:change) {
      if @fields[4].checked == 0
        @form.hide(5)
        @form.hide(6)
      else
        @form.show(5)
        @form.show(6)
      end
    }
    @fields[4].trigger(:change)
    @questions = []
    loop do
      loop_update
      @form.update
      if @fields[8].pressed?
        sendpoll
        break if $scene != self
      end
      if @fields[9].pressed? or escape
        confirm(p_("Polls", "Are you sure you want to discard this poll?")) {
          $scene = Scene_Polls.new
          return
          break
        }
      end
    end
  end

  def questions_context(menu)
    menu.option(p_("Polls", "New question"), nil, "n") {
      editquestion(@questions.size)
    }
    if @questions.size > 0
      menu.option(p_("Polls", "Edit question"), nil, "e") {
        editquestion(@fields[3].index)
      }
      menu.option(p_("Polls", "Delete question"), nil, :del) {
        @questions.delete_at(@fields[3].index)
        @fields[3].options.delete_at(@fields[3].index)
        play("editbox_delete")
        @fields[3].say_option
      }
    end
  end

  def editquestion(q)
    qs = @questions[q]
    @question = @questions[q].deep_dup
    @question = ["", 0] if @question == nil
    @qfields = [
      edt_title = EditBox.new(p_("Polls", "Question"), "", @question[0], true),
      lst_type = ListBox.new([p_("Polls", "Single choice"), p_("Polls", "Multiple choice"), p_("Polls", "Edit box")], p_("Polls", "Question type"), @question[1]),
      chk_limit = CheckBox.new(p_("Polls", "Limit count of answers that can be checked")),
      edt_limit = EditBox.new(p_("Polls", "Count of answers that can be checked"), EditBox::Flags::Numbers, "2"),

      lst_answers = ListBox.new(@question[2..-1] || [], p_("Polls", "Answers")),
      btn_save = Button.new(_("Save")),
      btn_cancel = Button.new(_("Cancel"))
    ]
    chk_limit.on(:change) {
      if chk_limit.checked == 1
        @qform.show(edt_limit)
      else
        @qform.hide(edt_limit)
      end
    }
    lst_type.on(:move) {
      if lst_type.index < 2
        @qform.show(lst_answers)
      elsif lst_type.index == 2
        @qform.hide(lst_answers)
      end
      if lst_type.index == 1
        @qform.show(chk_limit)
        chk_limit.trigger(:change)
      else
        @qform.hide(chk_limit)
        @qform.hide(edt_limit)
      end
    }
    lst_answers.bind_context { |menu| answers_context(menu) }
    @qform = Form.new(@qfields)
    lst_type.trigger(:move)
    loop do
      loop_update
      @qform.update
      if btn_cancel.pressed? or escape
        loop_update
        break
      end
      if btn_save.pressed?
        loop_update
        if @question.size > 3 or lst_type.index == 2
          @question[0] = edt_title.text
          if lst_type.index == 1 && chk_limit.checked == 1
            @question[1] = -edt_limit.text.to_i
            if @question[1] == -1
              @question[1] = 0
            elsif @question[1] >= 0
              @question[1] = 1
            end
          else
            @question[1] = lst_type.index
          end
          @questions[q] = @question
          break
        elsif @question.size == 2
          alert(p_("Polls", "There are no answers to this question"))
        else
          alert(p_("Polls", "There is only one answer to this question."))
        end
      end
    end
    qu = []
    for q in @questions
      qu.push(q[0]) if q != nil
    end
    @fields[3].options = qu
    @fields[3].focus
  end

  def answers_context(menu)
    menu.option(p_("Polls", "New answer"), nil, "n") {
      editanswer(@question.size - 2)
    }
    if @qfields[4].options.size > 0
      menu.option(p_("Polls", "Edit answer"), nil, "e") {
        editanswer(@qfields[4].index)
      }
      menu.option(p_("Polls", "Delete answer"), nil, :del) {
        @question.delete_at(@qfields[4].index + 2)
        @qfields[4].options.delete_at(@qfields[4].index)
        play("editbox_delete")
        @qfields[4].say_option
      }
    end
  end

  def editanswer(a)
    old = @question[2 + a] || ""
    ans = input_text(p_("Polls", "Answer"), 0, old, true)
    if ans != nil
      @question[2 + a] = ans
    end
    @qfields[4].options = @question[2..-1] || []
    @qfields[4].focus
  end

  def sendpoll
    if @questions.size == 0 || (@fields[4].checked.to_i == 1 && @fields[5].year == 0)
      alert(p_("Polls", "Please complete the poll before sending"))
      return
    end
    qus = JSON.generate(@questions)
    pp = { "questions" => qus, "description" => @fields[1].text }
    prm = { "create" => "1", "pollname" => @fields[0].text, "lng" => @ln[@form.fields[2].index], "hidden" => @fields[7].checked.to_i }
    if @fields[4].checked.to_i == 1
      prm["expirydate"] = Time.local(@fields[5].year, @fields[5].month, @fields[5].day, @fields[5].hour, @fields[5].min, @fields[5].sec).to_i
      prm["hideresults"] = @fields[6].checked.to_i
    end
    pl = srvproc("polls", prm, 0, pp)
    if pl[0].to_i < 0
      alert(_("Error"))
    else
      alert(p_("Polls", "The poll has been created."))
      $scene = Scene_Polls.new
    end
  end
end

class Scene_Polls_Answer
  def initialize(id, toscene = nil)
    @id = id
    @toscene = toscene
  end

  def main
    @changed = false
    pl = srvproc("polls", { "get" => "1", "poll" => @id.to_s })
    if pl[0].to_i < 0
      alert(_("Error"))
      if @toscene == nil
        $scene = Scene_Polls.new
      else
        $scene = @toscene
      end
      return
    end
    @name = pl[2].to_s.delete("\r\n")
    @author = pl[3].to_s.delete("\r\n")
    @created = Time.at(pl[4].to_i)
    begin
      @questions = JSON.load(pl[5].to_s.delete("\r\n").delete(";"))
    rescue Exception
      if pl[0].to_i < 0
        alert(_("Error"))
        if @toscene == nil
          $scene = Scene_Polls.new
        else
          $scene = @toscene
        end
        return
      end
    end
    @description = ""
    for i in 6..pl.size - 1
      @description += pl[i]
    end
    txt = "#{@name}\r\n#{p_("Polls", "Author")}: #{@author}\r\n#{p_("Polls", "Created")}: #{format_date(@created)}\r\n\r\n#{@description}"
    qs = []
    for q in @questions
      if q[1] == 2
        qs.push(EditBox.new(q[0], "", "", true))
        qs.last.on(:change) { @changed = true }
      else
        comment = ""
        if q[1] == 0
          multi = false
          limit = 1
          comment = p_("Polls", "Single choice question")
        elsif q[1] == 1
          multi = true
          limit = -1
          comment = p_("Polls", "Multiple choice question")
        elsif q[1] <= -1
          multi = true
          limit = -q[1]
          comment = np_("Polls", "Up to %{limit}-choice question", "Up to %{limit}-choices question", limit) % { "limit" => limit }
        end
        flags = 0
        flags |= ListBox::Flags::MultiSelection if multi
        qs.push(ListBox.new(q[2..q.size - 1], q[0] + " (#{comment}): ", 0, flags))
        qs.last.limit = limit
        qs.last.on(:move) { @changed = true }
      end
    end

    @fields = [EditBox.new(p_("Polls", "Poll"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, txt, true)] + qs + [Button.new(p_("Polls", "Vote")), Button.new(_("Cancel"))]
    @form = Form.new(@fields)
    loop do
      loop_update
      @form.update
      if escape
        if @changed == false or confirm(p_("Polls", "Are you sure you want to discard your answers in this poll?")) == 1
          if @toscene == nil
            $scene = Scene_Polls.new(@id)
          else
            $scene = @toscene
          end
          return
          break
        end
      end
      if enter or space
        if @form.index == @form.fields.size - 2
          ans = ""
          for i in 1..@questions.size
            case @questions[i - 1][1]
            when 0
              ans += (i - 1).to_s + ":" + @form.fields[i].index.to_s + "\r\n"
            when 1
              for j in 0..@form.fields[i].options.size - 1
                ans += (i - 1).to_s + ":" + j.to_s + "\r\n" if @form.fields[i].selected[j] == true
              end
            when 2
              ans += (i - 1).to_s + ":" + @form.fields[i].text.gsub(";", " ").gsub(":", " ").delete("\r\n") + "\r\n" if @form.fields[i].text != ""
            else
              if @questions[i - 1][1] < 0
                for j in 0..@form.fields[i].options.size - 1
                  ans += (i - 1).to_s + ":" + j.to_s + "\r\n" if @form.fields[i].selected[j] == true
                end
              end
            end
          end
          ans.chop!
          pl = srvproc("polls", { "answer" => 1, "poll" => @id.to_s }, 0, { "answers" => ans })
          if pl[0].to_i < 0
            alert(_("Error"))
          else
            alert(p_("Polls", "Your vote has been saved."))
            if @toscene == nil
              $scene = Scene_Polls.new(@id)
            else
              $scene = @toscene
            end
            return
            break
          end
        elsif @form.index == @form.fields.size - 1
          if @toscene == nil
            $scene = Scene_Polls.new(@id)
          else
            $scene = @toscene
          end
          return
          break
        end
      end
    end
  end
end

class Scene_Polls_Report
  def initialize(id, toscene = nil)
    @id = id
    @toscene = toscene
  end

  def main
    pl = srvproc("polls", { "get" => "1", "poll" => @id.to_s })
    if pl[0].to_i < 0
      alert(_("Error"))
      $scene = Scene_Polls.new
      return
    end
    @name = pl[2].to_s.delete("\r\n")
    @author = pl[3].to_s.delete("\r\n")
    @created = Time.at(pl[4].to_i)
    begin
      @questions = JSON.load(pl[5].to_s.delete("\r\n").delete(";"))
    rescue Exception
      alert(_("Error"))
      $scene = Scene_Polls.new
      return
    end
    @description = ""
    for i in 6..pl.size - 1
      @description += pl[i]
    end
    txt = "#{@name}\r\n#{p_("Polls", "Author")}: #{@author}\r\n#{p_("Polls", "Created")}: #{format_date(@created)}\r\n\r\n#{@description}\r\n"
    pl = srvproc("polls", { "results" => "1", "details" => 1, "poll" => @id.to_s })
    if pl[0].to_i < 0
      alert(_("Error"))
      if @toscene == nil
        $scene = Scene_Polls.new
      else
        $scene = @toscene
      end
      return
    end
    txt += "#{p_("Polls", "The number of votes")}: #{pl[1]}\r\n"
    @votes = pl[1].to_i
    @answers = []
    for i in 2..pl.size - 1
      r, q, a = pl[i].delete("\r\n").split(":")
      a = "" if a == nil
      r = r.to_i
      q = q.to_i
      @answers[q] = [] if @answers[q] == nil
      a = a.to_i if @questions[q][1] < 2
      b = [r, a]
      @answers[q].push(b)
    end
    for q in 0..@questions.size - 1
      if @answers[q] != nil
        txt += @questions[q][0].to_s + "\r\n"
        if @questions[q][1] < 2
          for i in 2...@questions[q].size
            a = i - 2
            pr = (@answers[q].map { |x| x[1] }.count(a).to_f / @votes.to_f * 100.0).to_i
            txt += @questions[q][i] + ": " + pr.to_s + "%\r\n"
          end
        else
          for a in @answers[q]
            txt += ": " + a[1] + "\r\n"
          end
        end
      end
      txt += "\r\n\r\n"
    end
    input_text(p_("Polls", "Poll results: %{name}") % { "name" => @name }, EditBox::Flags::ReadOnly, txt)
    if @toscene == nil
      $scene = Scene_Polls.new(@id)
    else
      $scene = @toscene
    end
  end
end

class Scene_Polls_Results
  def initialize(id, toscene = nil)
    @id = id
    @toscene = toscene
  end

  def main
    pl = srvproc("polls", { "get" => "1", "poll" => @id.to_s })
    if pl[0].to_i < 0
      alert(_("Error"))
      $scene = @toscene
      $scene = Scene_Polls.new if @toscene == nil
      return
    end
    @poll = Struct_Polls_Poll.new
    @poll.id = @id
    @poll.name = pl[2].delete("\r\n")
    @poll.author = pl[3].delete("\r\n")
    @poll.created = Time.at(pl[4].to_i)
    @questions = []
    begin
      qs = JSON.load(pl[5].to_s.delete("\r\n").delete(";"))
    rescue Exception
      alert(_("Error"))
      $scene = Scene_Polls.new
      return
    end
    for qu in qs
      q = Struct_Polls_Question.new
      q.question = qu[0]
      q.type = qu[1].to_i
      q.answers = qu[2..-1]
      @questions.push(q)
    end
    @poll.description = ""
    for i in 6..pl.size - 1
      @poll.description += pl[i]
    end
    pl = srvproc("polls", { "results" => "1", "details" => 1, "poll" => @id.to_s })
    if pl[0].to_i < 0
      alert(_("Error"))
      $scene = @toscene
      $scene = Scene_Polls.new if @toscene == nil
      return
    end
    @poll.votes = pl[1].to_i
    @answers = []
    for i in 2...pl.size
      r, q, a = pl[i].delete("\r\n").split(":")
      a = "" if a == nil
      r = r.to_i
      q = q.to_i
      ans = Struct_Polls_Answer.new
      ans.question = q
      ans.type = @questions[q].type || 2
      a = a.to_i if ans.type < 2
      ans.answer = a
      ans.author = r
      @answers.push(ans)
    end
    @filters = []
    @curanswers = []
    @form = Form.new([
      @sel_questions = ListBox.new(@questions.map { |q| q.question }, p_("Polls", "Questions")),
      @sel_answers = TableBox.new([nil, nil], [], 0, p_("Polls", "Answers")),
      @sel_filters = ListBox.new([], p_("Polls", "Filters")),
      @btn_close = Button.new(_("Close"))
    ])
    @btn_close.on(:press) { @form.resume }
    @sel_questions.on(:move) {
      update_answers
    }
    @sel_questions.trigger(:move)
    @sel_answers.bind_context { |menu| answers_context(menu) }
    @sel_filters.bind_context { |menu| filters_context(menu) }
    @form.cancel_button = @btn_close
    @form.wait
    $scene = @toscene
    $scene = Scene_Polls.new(@id) if @toscene == nil
  end

  def answers_context(menu)
    return if @sel_answers.rows.size == 0
    suc = false
    for f in @filters
      suc = true if f == @sel_questions.index && f == @curanswers[@sel_answers.index]
    end
    if suc == false
      menu.option(p_("Polls", "Filter with this answer")) {
        @filters.push([@sel_questions.index, @curanswers[@sel_answers.index], true])
        update_filters
      }
      menu.option(p_("Polls", "Filter without this answer")) {
        @filters.push([@sel_questions.index, @curanswers[@sel_answers.index], false])
        update_filters
      }
    else
      menu.option(p_("Polls", "Delete this answer from filters")) {
        for f in @filters
          @filters.delete(f) if f[0] == @sel_questions.index and f[1] == @curanswers[@sel_answers.index]
        end
        update_filters
      }
    end
  end

  def filters_context(menu)
    return if @filters.size == 0
    menu.option(_("Delete"), nil, :del) {
      @filters.delete_at(@sel_filters.index)
      update_filters
      play("editbox_delete")
      @sel_filters.say_option
    }
  end

  def update_answers
    authors = @answers.map { |a| a.author }.uniq
    for f in @filters
      for author in authors.deep_dup
        if f[2] == true
          suc = false
          for a in @answers
            suc = true if a.author == author && a.question == f[0] && a.answer == f[1]
          end
          authors.delete(author) if suc == false
        else
          suc = true
          for a in @answers
            suc = false if a.author == author && a.question == f[0] && a.answer == f[1]
          end
          authors.delete(author) if suc == false
        end
      end
    end
    q = @questions[@sel_questions.index]
    @sel_answers.rows = []
    @curanswers = []
    if q.type < 2
      anses = []
      answersList = []
      for a in @answers
        next if !authors.include?(a.author)
        if a.question == @sel_questions.index
          anses.push(a.answer)
        end
      end
      for a in 0...q.answers.size
        if anses.size > 0
          prc = (anses.count(a).to_f / authors.size.to_f * 100.0).floor
        else
          prc = 0
        end
        answersList.push([q.answers[a], prc, a])
      end
      answersList = answersList.sort_by { |a| a[1] * -1 }
      answersList.each do |a|
        @sel_answers.rows.push([a[0], a[1].to_s + "%"])
        @curanswers.push(a[2])
      end
    else
      for a in @answers
        next if !authors.include?(a.author)
        if a.question == @sel_questions.index
          @sel_answers.rows.push([a.answer.to_s]) if a.answer.to_s != ""
          @curanswers.push(a.answer)
        end
      end
    end
    @sel_answers.reload
    @sel_answers.index = 0
  end

  def update_filters
    @sel_filters.options = []
    for f in @filters
      q = @questions[f[0]]
      ans = f[1]
      ans = q.answers[f[1]] if q.type < 2
      if f[2] == true
        k = p_("Polls", "Includes")
      else
        k = p_("Polls", "Excludes")
      end
      o = q.question + "\r\n" + k + ": " + ans
      @sel_filters.options.push(o)
    end
    update_answers
  end
end

class Struct_Polls_Poll
  attr_accessor :id
  attr_accessor :name
  attr_accessor :author
  attr_accessor :description
  attr_accessor :created
  attr_accessor :voted
  attr_accessor :language
  attr_accessor :votes

  def initialize(id = 0)
    @id = id
    @name = ""
    @author = ""
    @description = ""
    @created = 0
    @voted = false
    @language = ""
    @votes = 0
  end
end

class Struct_Polls_Question
  attr_accessor :question, :type, :answers

  def initialize
    @question = ""
    @type = 0
    @answers = []
  end
end

class Struct_Polls_Answer
  attr_accessor :author, :question, :answer, :type

  def initialize
    @author = ""
    @question = 0
    @answer = 0
    @type = 0
  end
end
