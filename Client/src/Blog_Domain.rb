#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Blog_Domain
  def initialize(blog=nil)
    blog=Session.name if blog==nil
    @blog=blog
  end
  
  def main
    bt=srvproc("blog_domains", {'ac'=>'getblogdomain', 'searchname'=>@blog})
    if bt[0].to_i<0
      alert(_("Error"))
      return $scene=Scene_Main.new
      end
    @form=Form.new ([
    @txt_olddomain = EditBox.new(p_("Blog", "Current blog domain"), EditBox::Flags::ReadOnly, bt[1].delete("\r\n"), true),
    @btn_change = Button.new(p_("Blog", "Change")),
    nil, nil, nil,nil,
    @btn_cancel = Button.new(_("Cancel"))
    ])
    @btn_change.on(:press) {changer}
    loop do
      loop_update
      @form.update
      break if escape or @btn_cancel.pressed?
      end
    $scene=Scene_Main.new
  end
  def changer
    @lst_domaintype = @form.fields[2] = ListBox.new([
    p_("Blog", "Personal Elten blog domain (%{username}.eltenblog.net)")%{'username'=>Session.name},
    p_("Blog", "Shared Elten blog domain (selectedname.s.eltenblog.net)"),
    p_("Blog", "External domain")
    ], p_("Blog", "Domain type"), 0, 0, true)
    @edt_domain = @form.fields[3] = EditBox.new("", 0, "", true)
    @txt_fulldomain = @form.fields[4] = EditBox.new(p_("Blog", "Full domain"), EditBox::Flags::ReadOnly, "", true)
    @btn_next = @form.fields[5] = Button.new(p_("Blog", "Proceed with domain change"))
    @edt_domain.on(:change) {
    case @lst_domaintype.index
    when 0
      @txt_fulldomain.settext((Session.name+".eltenblog.net").downcase)
      when 1
        @txt_fulldomain.settext((@edt_domain.text+".s.eltenblog.net").downcase)
        when 2
          @txt_fulldomain.settext((@edt_domain.text).downcase)
    end
}
    @lst_domaintype.on(:move) {
    case @lst_domaintype.index
    when 0
      @form.hide(@edt_domain)
      when 1
        @form.show(@edt_domain)
        @edt_domain.header= p_("Blog", "Domain prefix (prefix.s.eltenblog.net)")
        when 2
          @form.show(@edt_domain)
          @edt_domain.header= p_("Blog", "Domain (like example.com)")
        end
        @edt_domain.trigger(:change)
    }
    @lst_domaintype.trigger(:move)
    @btn_next.on(:press) {changeproceed}
    @form.hide(@btn_change)
    @form.index=@lst_domaintype
    @form.focus
  end
  def changevalidate
    if @txt_fulldomain.text==@txt_olddomain.text
      alert(p_("Blog", "The new domain is the same as a previous one"))
      return false
    end
    if @lst_domaintype.index==0 && srvproc("blog_exist", {'searchname'=>Session.name})[1].to_i==1
      alert(p_("Blog", "You already have one blog associated with your Elten profile. Please change its type and then proceed."))
      return false
    end
    if @lst_domaintype.index==1 && @edt_domain.text.include?(".")
      alert(p_("Blog", "Only first level subdomains are allowed"))
      return false
    end
    if @lst_domaintype.index==1 && @edt_domain.text.size<3
      alert(p_("Blog", "Blog subdomain must be at least 3 characters long"))
      return false
      end
    dom=@txt_fulldomain.text
    if (/[^a-z0-9\.\-]/=~dom)!=nil
      alert(p_("Blog", "The entered domain contains invalid characters"))
      return false
      end
    if dom[0..0]=="." || dom[0..0]=="-" || dom.include?("-.") || dom.include?(".-") || dom[-1..-1]=="." || dom[-1..-1]=="-" || !dom.include?(".") || dom.split(".").last.size<2 || dom=="eltenblog.net"
      alert(p_("Blog", "The entered domain is not valid"))
      return false
      end
    end
  def changeproceed
    return if changevalidate==false
    return if confirm(p_("Blog", "Warning! If you change your blog URL, some links may stop working. If you directly linked posts or other resources on your blog, they would no longer be available at previous URLs. In such case you will be required to fix them manualy. Are you sure you want to continue?"))==0
    dom=@txt_fulldomain.text
    d=".eltenblog.net"
    if dom[-1*d.size..-1]!=d
if externalchangecheck(dom)==false
    @form.focus
    return
  end
end
    end
    def externalchangecheck(domain)
      dt=srvproc("blog_domains", {'ac'=>'propers'})
      return false if dt[0].to_i<0
        ip=dt[2].delete("\r\n")
      text=p_("Blog", "To continue, you should point your domain to Elten Blogging server.
You can buy your own domain from domain providers, such as ovh.com, domain.com, godaddy.com or bluehost.com.
Once bought, you should point your domain's A DNS record to IP address:
%{ip}
. Please note that redirecting your domain is not aliasing and setting aliases or HTTP 300 / 301 redirections will not work.
You can get detailed description from your domain provider, for example at:
https://support.us.ovhcloud.com/hc/en-us/articles/115001994890-Getting-Familiar-with-DNS
Once completed, please continue.")%{'ip'=>ip}
      form=Form.new([
      txt=EditBox.new(p_("Blog", "Setting the domain"), EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly, text, true),
      btn_next = Button.new(p_("Blog", "Ready, take me next")),
      btn_cancel = Button.new(_("Cancel"))
      ])
      r=true
      btn_cancel.on(:press) {
      r=false
      form.resume
      }
      form.cancel_button = btn_cancel
      btn_next.on(:press) {
      ch=srvproc("blog_domains", {'ac'=>'check', 'domain'=>domain})
      if ch[1].to_i==0
        alert(p_("Blog", "Your domain is not pointing to Elten Blogs, please try again or wait a while to refresh DNS. It may take up to 24 hours to perform full DNS update."))
      else
        return true
        end
      }
      form.wait
      return r
      end
  end