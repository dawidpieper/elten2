#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Contacts
  def initialize(type=0)
    @type=type
  end
      def main
      if $name=="guest"
      alert(_("This section is unavailable for guests"))
      $scene=Scene_Main.new
      return
      end
      ct=["-4"]
      case @type
      when 0
      ct = srvproc("contacts",{})
      when 1
        ct = srvproc("contacts",{"birthday"=>"1"})
      end
        err = ct[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      @contact = []
      for i in 1..ct.size - 1
        ct[i].delete!("\r\n")
      end
            for i in 1..ct.size - 1
        @contact.push(ct[i]) if ct[i].size > 1
      end
      @contact.polsort!
      if @contact.size < 1
        alert(p_("Contacts", "Empty list"))
              end
      selt = []
      for i in 0..@contact.size - 1
        selt[i] = @contact[i] + ". " + getstatus(@contact[i])
        end
      header=p_("Contacts", "Contacts")
      header="" if @type>0
              @sel = Select.new(selt,true,0,header)
              @sel.bind_context{|menu|context(menu)}
            loop do
loop_update
        @sel.update if @contact.size > 0
        update
        if $scene != self
          break
          end
                  end
      end
      def update
        if escape
          case @type
          when 0
          $scene = Scene_Main.new
          when 1
            ct = srvproc("contacts",{"birthday"=>"2"})
            $scene=Scene_WhatsNew.new
            end
        end
        if $key[0x2e] and @type==0
          if @contact.size >= 1
          if confirm(p_("Contacts", "Are you sure you want to delete this contact?")) == 1
            $scene = Scene_Contacts_Delete.new(@contact[@sel.index],self)
            @sel.disable_item(@sel.index)
loop_update            
            end
          end
          end
        if enter and @contact.size > 0
                    usermenu(@contact[@sel.index],false)
          end
        end
            

        def context(menu)
                  if @contact.size>0
          menu.useroption(@contact[@sel.index])
        end
        if @type==0
          menu.option(p_("Contacts", "New contact")) {
                          $scene = Scene_Contacts_Insert.new
          }
          end
          end
        end
        
        class Scene_Contacts_Insert
          def initialize(user="",scene=nil)
            @user = user
            @scene = scene
          end
          def main
                        user = @user
            while user==""
              user = input_text(p_("Contacts", "Enter the name of the user you want to add to your contacts' list."))
            end
            ct=""
            user=finduser(user) if user.upcase==finduser(user).upcase
            if user_exist(user)            
            ct = srvproc("contacts_mod",{"searchname"=>user, "insert"=>"1"})
          else
            ct=[-5]
            end
                        err = ct[0].to_i
            case err
            when 0
              alert(p_("Contacts", "Contact was added."))
              $scene = @scene
              when -1
                alert(_("Database Error"))
                $scene = Scene_Main.new
                when -2
                  alert(_("Token expired"))
                  $scene = Scene_Loading.new
                  when -3
                    alert(p_("Contacts", "This user is already added to your contacts' list."))
                    $scene = @scene
                    when -5
                      alert(p_("Contacts", "This user does not exist."))
                      $scene = Scene_Contacts.new
                    end
                                      $scene = Scene_Contacts.new if $scene == nil
                                end
          end
          
                  class Scene_Contacts_Delete
          def initialize(user="",scene=nil)
            @user = user
            @scene = scene
          end
          def main
            user = @user
            while user==""
              user = input_text(p_("Contacts", "Type a username which you want to remove from your contact list."))
            end
                        ct = srvproc("contacts_mod",{"searchname"=>user, "delete"=>"1"})
                        err = ct[0].to_i
            case err
            when 0
              alert(p_("Contacts", "Contact has been deleted."))
              $scene = @scene
              when -1
                alert(_("Database Error"))
                $scene = Scene_Main.new
                when -2
                  alert(_("Token expired"))
                  $scene = Scene_Loading.new
                  when -3
                    alert(p_("Contacts", "This user is not added to your contacts' list."))
                    $scene = @scene
                    when -5
                      alert(p_("Contacts", "This user does not exist."))
                      $scene = Scene_Contacts.new
                    end
                    $scene = Scene_Contacts.new if $scene == nil
            end
          end