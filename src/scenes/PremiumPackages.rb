class Scene_PremiumPackages
  def main
    if Session.name == "guest"
      alert(_("This section is unavailable for guests"))
      $scene = Scene_Main.new
      return
    end
    @sel = TableBox.new([nil, p_("PremiumPackages", "status"), p_("PremiumPackages", "Yearly price"), p_("PremiumPackages", "Half-yearly price")], [], 0, p_("PremiumPackages", "Premium packages"), true)
    @sel.bind_context { |menu| context(menu) }
    refresh
    @sel.focus
    loop do
      loop_update
      @sel.update
      break if escape
      if enter and @packages.size > 0
        package = @packages[@sel.index]
        show(package)
        @sel.focus
      end
    end
    $scene = Scene_Main.new
  end

  def get_courier
    return Struct_PremiumPackages_PremiumPackage.new("courier", p_("PremiumPackages", "Courier"), [
             p_("PremiumPackages", "Following forums in not moderated groups"),
             p_("PremiumPackages", "Disabling signatures visibility"),
             p_("PremiumPackages", "Thread marking and bookmarks"),
             p_("PremiumPackages", "Private messages protection against erroneous removal"),
             p_("PremiumPackages", "History of mentions and replying to mentions"),
             p_("PremiumPackages", "Groups pinning"),
             p_("PremiumPackages", "Following blog posts"),
             p_("PremiumPackages", "Extended limit of attachment size in private messages to 32MB"),
             p_("PremiumPackages", "Attaching polls to private messages")
           ])
  end

  def get_audiophile
    return Struct_PremiumPackages_PremiumPackage.new("audiophile", p_("PremiumPackages", "Audiophile"), [
             p_("PremiumPackages", "Downloading of soundthemes"),
             p_("PremiumPackages", "Lifting the 2-minute limit for private voice messages"),
             p_("PremiumPackages", "Lifting the 32kbps quality limit in private voice messages"),
             p_("PremiumPackages", "Recording conferences"),
             p_("PremiumPackages", "Soundcard streaming in conferences"),
             #p_("PremiumPackages", "Creation of up to three channels public to friends in conferences"),
             p_("PremiumPackages", "Creation of group channels in conferences"),
             p_("PremiumPackages", "Placing own background and objects in HRTF"),
             p_("PremiumPackages", "Changing HRTF dimensions"),
             p_("PremiumPackages", "Setting different output soundcard for conferences than the one selected in Elten")
           #p_("PremiumPackages", "Placing beacons in HRTF channels"),
           ])
  end

  def get_scribe
    return Struct_PremiumPackages_PremiumPackage.new("scribe", p_("PremiumPackages", "Scribe"), [
             p_("PremiumPackages", "Creation of second and following blogs"),
             p_("PremiumPackages", "Pinning blogs to groups"),
             p_("PremiumPackages", "Spell checking"),
             p_("PremiumPackages", "Changing of blog address"),
             p_("PremiumPackages", "Option to disable request for support on blogs"),
             p_("PremiumPackages", "Informing about new blog followers"),
             p_("PremiumPackages", "Translator"),
             p_("PremiumPackages", "Blog posts scheduling")
           ])
  end

  def get_sponsor
    return Struct_PremiumPackages_PremiumPackage.new("sponsor", p_("PremiumPackages", "Sponsorship package"), [
             p_("PremiumPackages", "Includes profits from courier, audiophile and scribe"),
             p_("PremiumPackages", "Special assigning of user on lists and forum"),
             p_("PremiumPackages", "Entry in the list of sponsors")
           ])
  end

  def context(menu)
    if @packages.size > 0
      package = @packages[@sel.index]
      menu.option(p_("PremiumPackages", "Show profits")) {
        show(package)
        @sel.focus
      }
      if package.allowed
        s = p_("PremiumPackages", "Buy")
        s = p_("PremiumPackages", "Extend") if package.totime > 0
        menu.option(s) {
          buy(package)
          refresh
          @sel.focus
        }
        if !package.special
          s = p_("PremiumPackages", "Activate package using code")
          s = p_("PremiumPackages", "Extend package using code") if package.totime > 0
          menu.option(s) {
            activate(package)
            refresh
            @sel.focus
          }
        end
      end
    end
    menu.option(_("Refresh"), nil, "r") {
      refresh
      @sel.focus
    }
  end

  def show(package)
    sbuy = p_("PremiumPackages", "Buy")
    sbuy = p_("PremiumPackages", "Extend") if package.totime > 0
    sactivate = p_("PremiumPackages", "Activate package using code")
    sactivate = p_("PremiumPackages", "Extend package using code") if package.totime > 0
    form = Form.new([
      lst_profits = ListBox.new(package.profits, p_("PremiumPackages", "Profits of package %{name}") % { "name" => package.name }, 0, 0, true),
      btn_buy = Button.new(sbuy),
      btn_activate = Button.new(sactivate),
      btn_close = Button.new(p_("PremiumPackages", "Close"))
    ], 0, false, true)
    form.cancel_button = btn_close
    btn_close.on(:press) { form.resume }
    btn_buy.on(:press) {
      buy(package)
      refresh
      form.resume
    }
    btn_activate.on(:press) {
      activate(package)
      refresh
      form.resume
    }
    form.wait
  end

  def refresh
    @packages = [
      get_courier,
      get_audiophile,
      get_scribe,
      get_sponsor
    ]
    pc = srvproc("premiumpackages", { "ac" => "list" })
    if pc[0].to_i == 0
      for i in 0...pc[1].to_i
        for c in @packages
          c.totime = pc[2 + i * 2 + 1].to_i if c.package == pc[2 + i * 2].delete("\r\n")
        end
      end
    end
    pc = srvproc("payments", { "ac" => "prices" })
    if pc[0].to_i == 0
      j = JSON.load(pc[1])
      for k in j.keys
        for c in @packages
          if c.package == k
            c.price = j[k]["price"]
            c.halfprice = j[k]["halfprice"]
            c.available = j[k]["available"]
            c.allowed = true if c.totime == 0 || j[k]["yearlimit"] >= Time.at(c.totime).year
            c.special = j[k]["special"]
          end
        end
      end
    end
    @sel.rows = @packages.map { |c|
      st = p_("PremiumPackages", "Inactive")
      st = p_("PremiumPackages", "Active until %{time}") % { "time" => format_date(Time.at(c.totime)) } if c.totime > 0
      halfprice = nil
      price = nil
      halfprice = c.halfprice.to_s + " PLN" if c.halfprice != nil
      price = c.price.to_s + " PLN" if c.price != nil
      [c.name, st, price, halfprice]
    }
    @sel.reload
  end

  def buy(package)
    if !package.available
      alert(p_("PremiumPackages", "This package is currently unavailable. Try to buy it in the next month."))
      return
    end
    accepted = false
    form = Form.new([
      edt_info = EditBox.new(p_("PremiumPackages", "Information"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, p_("PremiumPackages",
                                                                                                                            "EltenLink's premium packages are given to users as a reward for supporting the portal.
A project of this size cannot exist without the help of users.
The granting of a premium package does not constitute a commitment or a commercial contract. The user who supports the project is aware that if the necessary amount is not raised for EltenLink to continue, the premium packages will become unavailable.")),
      btn_accept = Button.new(p_("PremiumPackages", "I accept")),
      btn_refuse = Button.new(p_("PremiumPackages", "I refuse"))
    ], 0, false, true)
    form.cancel_button = btn_refuse
    btn_refuse.on(:press) { form.resume }
    btn_accept.on(:press) { accepted = true; form.resume }
    form.wait
    return if !accepted
    transfer = nil
    pc = srvproc("payments", { "ac" => "methods" })
    if pc[0].to_i == 0
      j = JSON.load(pc[1])
      for m in j
        if m["id"] == "transfer" and m["type"] == "transfer"
          transfer = m
        end
      end
    end
    if transfer == nil
      alert(p_("PremiumPackages", "I cannot download the data required to make a transfer"))
      return
    end
    info = p_("PremiumPackages", "Below are the transfer details.
In the title of the transfer, please indicate your user name on the EltenLink portal and which package the payment concerns.")
    if !package.special
      info += "\n" + p_("PremiumPackages", "If, instead of a package, you wish to receive a code that can be used to activate any of the packages: %{packages} by any user, mark this information in the transfer title.") % { "packages" => @packages.find_all { |pc| pc.special == false }.map { |pc| pc.name }.join(", ") }
    end
    info += "\n" + p_("PremiumPackages", "Please note that if you transfer a larger amount, the remainder will be treated as a donation.

In order to reduce the processing time of your payment, you can forward the transfer confirmation to the Council of Elders.")
    info += "\n\n"
    info += p_("PremiumPackages", "National transfer details (from Poland):
%{holder}
Address: %{address}
Account number: %{placcount}

Additional data for foreign transfers:
IBAN number: %{iban}
BIC / SWIFT: %{swift}
Bank address: %{bankaddress}
Sort code: %{sortcode}") % { "holder" => transfer["holder"], "address" => transfer["address"], "placcount" => transfer["placcount"], "iban" => transfer["iban"], "swift" => transfer["swift"], "bankaddress" => transfer["bankaddress"], "sortcode" => transfer["sortcode"] }
    form = Form.new([
      edt_info = EditBox.new(p_("PremiumPackages", "Information"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, info),
      btn_accept = Button.new(p_("PremiumPackages", "I accept"))
    ], 0, false, true)
    form.cancel_button = btn_accept
    btn_accept.on(:press) { form.resume }
    form.wait
  end

  def activate(package)
    code = input_text(p_("PremiumPackages", "Type code to activate this package"), 0, "", true)
    return if code == nil
    pc = srvproc("premiumpackages", { "ac" => "testcode", "code" => code })
    if pc[0].to_i < 0
      case pc[0].to_i
      when -4
        alert(p_("PremiumPackages", "Code not found."))
      when -5
        alert(p_("PremiumPackages", "This code has been already used."))
      else
        alert(_("Error"))
      end
      return
    end
    tim = package.totime
    tim = Time.now.to_i if tim == 0
    tim += pc[1].to_i
    confirm(p_("PremiumPackages", "The package %{name} will be active until %{time}. This code will be used up and you will not be able to use it again. Do you want to continue?") % { "name" => package.name, "time" => format_date(Time.at(tim)) }) {
      pc = srvproc("premiumpackages", { "ac" => "usecode", "package" => package.package, "code" => code })
      if pc[0].to_i < 0
        alert(_("Error"))
      else
        alert(p_("PremiumPackages", "Package activated"))
      end
    }
    return
  end
end

class Struct_PremiumPackages_PremiumPackage
  attr_accessor :package, :name, :profits, :totime, :halfprice, :price, :available, :allowed, :special

  def initialize(package, name, profits = [])
    @package, @name, @profits = package, name, profits
    @totime = 0
    @available, @allowed, @special = false, false, false
  end
end
