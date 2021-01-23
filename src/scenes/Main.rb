# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Main
  @@acselindex = nil

  def main
    if Session.name == nil || Session.name == ""
      $scene = Scene_Loading.new
      return
    end
    NVDA.braille("") if NVDA.check
    if $restart == true
      $restart = false
      $scene = Scene_Loading.new
    end
    dialog_close if dialog_opened
    waiting_end if $waitingopened
    $silentstart = false
    if Thread::current != $mainthread
      t = Thread::current
      loop_update
      t.exit
    end
    if $preinitialized != true
      $preinitialized = true
      whatsnew(true)
      return
    end
    $thr1 = Thread.new { thr1 } if $thr1.alive? == false
    $thr2 = Thread.new { thr2 } if $thr2.alive? == false
    if (($nbeta > $beta) and $isbeta == 1) and $denyupdate != true
      if $portable != 1
        #$scene = Scene_Update_Confirmation.new($scene)
        #return
      else
        alert(p_("Main", "A new beta version of the program is available."))
      end
    end
    $speech_lasttext = ""
    $ctrldisable = false
    key_update
    ci = 0
    plsinfo = false
    ci += 1 if ci < 20
    acsel_load
    #speak(p_("Main", "Press the alt key to open the menu."))
    loop do
      loop_update
      @acsel.update
      if $keyr[0x10]
        if @acsel.index > 0 && arrow_up
          qacup
        end
        if @acsel.index < @actions.size - 1 and arrow_down
          qacdown
        end
      end
      if @acsel.selected?
        @actions[@acsel.index].call
      end
      if escape
        quit
      end
      break if $scene != self
    end
    @@acselindex = @acsel.index if @acsel != nil
  end

  def qacup
    times = 1
    index = @acsel.index - 1
    if !@acselshowhidden
      while index > 0 && @acsel.ishidden(index)
        times += 1
        index -= 1
      end
    end
    times.times { |i| QuickActions.up(@acsel.index - i) }
    @acsel.index -= times
    acsel_load(false)
    @acsel.sayoption
  end

  def qacdown
    times = 1
    index = @acsel.index + 1
    if !@acselshowhidden
      while index < @acsel.options.size - 1 && @acsel.ishidden(index)
        times += 1
        index += 1
      end
    end
    times.times { |i| QuickActions.down(@acsel.index + i) }
    @acsel.index += times
    acsel_load(false)
    @acsel.sayoption
  end

  def acsel_load(fc = true)
    @acselshowhidden ||= false
    @@acselindex = @acsel.index if @acsel != nil
    @actions = QuickActions.get
    @acsel = ListBox.new(@actions.map { |a| a.detail }, p_("Main", "Quick actions"), @@acselindex, 0, true)
    @acsel.add_tip(p_("Main", "Use Shift with up/down arrows to move quick actions"))
    for i in 0...@actions.size
      @acsel.disable_item(i) if @actions[i].show == false && !@acselshowhidden
    end
    @acsel.bind_context { |menu| accontext(menu) }
    @acsel.focus if fc == true
  end

  def accontext(menu)
    if @actions.size > 0 && @acsel.index >= 0 && !@acsel.ishidden(@acsel.index)
      menu.option(p_("Main", "Rename"), nil, "e") {
        label = input_text(p_("Main", "Action label"), 0, @actions[@acsel.index].label, true)

        if label != nil
          QuickActions.rename(@acsel.index, label)
          acsel_load
        end
      }
      menu.option(p_("Main", "Change hotkey"), nil, "k") {
        s = [p_("Main", "None")]
        k = [0]
        for i in 1..11
          s.push("F" + i.to_s)
          k.push(i)
          s.push("SHIFT+F" + i.to_s)
          k.push(-i)
        end
        ind = k.find_index(@actions[@acsel.index].key) || 0
        sel = ListBox.new(s, p_("Main", "Hotkey for action %{label}") % { "label" => @actions[@acsel.index].label }, ind)
        loop {
          loop_update
          sel.update
          break if escape
          if sel.selected?
            key = k[sel.index]
            c = nil
            @actions.each { |a| c = a if a.key == key }
            if c == nil || c == @actions[@acsel.index] || key == 0
              QuickActions.rekey(@acsel.index, key)
              acsel_load
              break
            else
              alert(p_("Main", "This hotkey is already used by action %{action}") % { "action" => c.label }, false)
            end
          end
        }
        @acsel.focus
      }
      if @acsel.index > 0
        menu.option(p_("Main", "Move up")) {
          qacup
        }
      end
      if @acsel.index < @actions.size - 1
        menu.option(p_("Main", "Move down")) {
          qacdown
        }
      end
      s = p_("Main", "Hide this action")
      s = p_("Main", "Show this action") if @actions[@acsel.index].show == false
      menu.option(s) {
        QuickActions.reshow(@acsel.index, !@actions[@acsel.index].show)
        acsel_load
      }
      menu.option(p_("Main", "Delete"), nil, :del) {
        ac = 0
        if @actions[@acsel.index].key == 0 || @actions[@acsel.index].show == false
          ac = confirm(p_("Main", "Are you sure you want to delete this quick action?"))
        else
          ac = selector([_("Cancel"), p_("Main", "Delete"), p_("Main", "Hide this action")], p_("Main", "If you delete this action, you will also delete the keyboard shortcut assigned to it. If you want to keep the keyboard shortcut, you can hide this action. You can show or remove hidden actions at any time."), 0, 0, 1)
        end
        if ac == 1
          QuickActions.delete(@acsel.index)
          acsel_load(false)
          @acsel.sayoption
        elsif ac == 2
          QuickActions.reshow(@acsel.index, false)
          acsel_load
        end
      }
    end
    s = p_("Main", "Show hidden actions")
    s = p_("Main", "Hide hidden actions") if @acselshowhidden
    menu.option(s, nil, "h") {
      @acselshowhidden = !@acselshowhidden
      acsel_load
    }
    menu.option(p_("Main", "Add"), nil, "n") {
      action_add
    }
    menu.option(p_("Main", "Restore defaults")) {
      confirm(p_("Main", "Are you sure you want to restore default Quick Actions?")) {
        File.delete(Dirs.eltendata + "\\quickactions.dat") if FileTest.exists?(Dirs.eltendata + "\\quickactions.dat")
        QuickActions.load_actions
        acsel_load
        @acsel.focus
      }
    }
  end

  def action_add
    actions = []
    actionlabels = []
    c = QuickActions.predefined_procs
    for a in c
      actions.push(a[0])
      actionlabels.push(a[1])
    end
    g = GlobalMenu.scenes
    for m in g
      actions.push(m[1])
      actionlabels.push(m[0])
    end
    ind = selector(actionlabels, p_("Main", "Select quick action to add"), 0, -1)
    if ind >= 0
      action = actions[ind]
      params = []
      if action.is_a?(Array)
        params = action[1..-1]
        action = action[0]
      end
      QuickActions.create(action, actionlabels[ind], params)
      acsel_load
    else
      @acsel.focus
    end
  end
end
