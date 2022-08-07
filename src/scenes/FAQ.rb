class Scene_FAQ
  def main
    load_faq
    @v = 0
    show_cats
  end

  def show_cats
    @catslist = ListBox.new(@cats, p_("FAQ", "Frequently asked questions"))
    @catslist.focus
    loop do
      loop_update
      @catslist.update
      if escape
        $scene = Scene_Main.new
        return
      end
      if @catslist.expanded? || @catslist.selected?
        show_questions(@catslist.index)
        @catslist.sayoption
      end
    end
  end

  def show_questions(index)
    qs = @ans[index].map { |a| a[0..a.index("\n")].strip }
    @qslist = ListBox.new(qs, "")
    @qslist.focus
    loop do
      loop_update
      @qslist.update
      break if escape || @qslist.collapsed?
      if @qslist.expanded? || @qslist.selected?
        ans = @ans[index][@qslist.index]
        a = ans[(ans.index("\n")) + 1..-1]
        input_text(qs[@qslist.index], EditBox::Flags::MarkDown | EditBox::Flags::ReadOnly || EditBox::Flags::MultiLine, a, true)
        @qslist.sayoption
      end
    end
  end

  def load_faq
    @faqdoc = _doc("faq")
    @faq = @faqdoc.split(/^\# /).map { |f|
      a = f.strip.split(/^\#\# /).map { |q| q.strip }
      a.delete("")
      a
    }
    @faq.delete([])
    @cats = @faq.map { |f| f[0] }
    @ans = @faq.map { |f| f[1..-1] }
    @faq
  end
end
