class Scene_Auctions
  def main
    if Configuration.language != "pl-PL"
      alert("Sorry, this event is available for polish users only.")
      $scene = Scene_Main.new
      return
    end
    @sel = TableBox.new([nil, "Właściciel", "Obecna cena", "Użytkownik licytujący", "Zakończenie licytacji"], [], 0, "Aukcje")
    @sel.bind_context { |menu| context(menu) }
    refresh
    @sel.focus
    loop do
      loop_update
      @sel.update
      dlg if enter
      break if escape
    end
    $scene = Scene_Main.new
  end

  def refresh
    @auctions = []
    @enrolled = false
    au = srvproc("auctions", { "ac" => "list" })
    if au[0].to_i < 0
      alert(_("Error"))
      return
    end
    @enrolled = false
    @enrolled = true if au[1].to_i == 1
    l = 0
    a = nil
    for i in 3...au.size
      t = au[i]
      case l
      when 0
        a = Struct_Auctions_Auction.new
        a.id = t.to_i
        l += 1
      when 1
        a.name = t.delete("\r\n")
        l += 1
      when 2
        if t.delete("\r\n") != "\004END\004"
          if a.description == nil
            a.description = ""
          else
            a.description += "\n"
          end
          a.description += t.delete("\r\n")
        else
          l += 1
        end
      when 3
        a.price = t.to_i
        l += 1
      when 4
        a.user = t.delete("\r\n")
        l += 1
      when 5
        a.creator = t.delete("\r\n")
        l += 1
      when 6
        a.totime = t.to_i
        @auctions.push(a)
        l = 0
      end
    end
    @sel.rows = @auctions.map { |a|
      f = ""
      begin
        f = format_date(Time.at(a.totime))
      rescue Exception
      end
      [a.name, a.creator, a.price.to_s + " zł", a.user, f]
    }
    @sel.reload
  end

  def context(menu)
    auction = @auctions[@sel.index]
    if auction != nil
      menu.option("Pokaż") { dlg }
      if auction.user != Session.name
        menu.option("Licytuj", nil, "l") { bit; @sel.focus }
      end
    end
    menu.option("Odśwież", nil, "r") { refresh; @sel.focus }
  end

  def dlg
    auction = @auctions[@sel.index]
    return if auction == nil
    dialog_open
    form = Form.new([
      txt_description = EditBox.new(auction.name, EditBox::Flags::ReadOnly | EditBox::Flags::MultiLine, auction.description),
      btn_bit = Button.new("Licytuj"),
      btn_close = Button.new("Zamknij")
    ], 0, false, true)
    form.hide(btn_bit) if auction.user == Session.name
    btn_close.on(:press) { form.resume }
    btn_bit.on(:press) { bit }
    form.cancel_button = btn_close
    form.wait
    dialog_close
    @sel.focus
  end

  def bit
    auction = @auctions[@sel.index]
    return if auction == nil
    prices = (auction.price + 1..auction.price + 100).to_a
    pr = selector(prices.map { |r| r.to_s + " zł" }, "Twoja oferta", 0, -1)
    return if pr == -1
    price = prices[pr]
    prm = {}
    prm["ac"] = "bit"
    prm["auction"] = auction.id
    prm["price"] = price
    if @enrolled == false
      if acceptrules
        prm["enroll"] = 1
      else
        return
      end
    end
    confirm("Czy chcesz zaoferować #{price.to_s} zł w licytacji na aukcji \"#{auction.name}\"?") {
      if srvproc("auctions", prm)[0].to_i < 0
        alert("Coś poszło nie tak. Aukcja mogła się już skończyć lub ktoś inny zdążył przedstawić wyższą ofertę.")
      else
        alert("Licytujesz tę aukcję")
      end
      refresh
    }
  end

  def acceptrules
    rl = srvproc("auctions", { "ac" => "rules" })
    if rl[0].to_i < 0
      alert("Błąd")
      return false
    end
    rules = rl[1..-1].map { |r| r.delete("\r\n") }.join("\n")
    form = Form.new([
      txt_rules = EditBox.new("Regulamin", EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, rules, true),
      btn_accept = Button.new("Akceptuj"),
      btn_reject = Button.new("Odrzuć")
    ], 0, false, true)
    form.cancel_button = btn_reject
    btn_reject.on(:press) {
      form.resume
      return false
    }
    btn_accept.on(:press) {
      form.resume
      return true
    }
    form.wait
  end
end

class Struct_Auctions_Auction
  attr_accessor :id, :name, :description, :price, :user, :creator, :totime
end
