# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Programs
  def main
    @installed = []
    d = Dir.entries(Dirs.apps)
    d.delete(".")
    d.delete("..")
    for path in d
      @installed.push(Struct_Programs_Program.load(path)) if FileTest.exists?(Dirs.apps + "\\" + path + "\\__app.ini")
    end
    @programs = []
    l = srvproc("apps_list", {})
    if l[0].to_i == 0
      for i in 0...((l.size - 1) / 5)
        @programs.push(Struct_Programs_Program.new(*(l[(1 + i * 5)...(1 + i * 5 + 5)].map { |n| n.delete("\r\n") })))
      end
    end
    a = @installed.deep_dup
    for g in @programs
      suc = false
      @installed.each { |n| suc = true if n.path == g.path and n.name == g.name and n.author == g.author }
      a.push(g.deep_dup) if suc == false
    end
    @all = a
    selt = a.map { |g|
      s = g.name
      asuc = false
      @installed.each { |n| asuc = true if n.path == g.path and n.author == g.author and n.name == g.name }
      if asuc
        s += " #{g.version}"
        suc = false
        @programs.each { |n|
          suc = true if g.name == n.name and g.path == n.path and g.author == n.author and g.version != n.version
        }
        s += "\004NEW\004" if suc
      else
        s += " (#{p_("Programs", "not installed")})"
      end
      s
    }
    @sel = ListBox.new(selt, p_("Programs", "Programs installation"), 0, 0, false)
    @sel.bind_context { |menu| context(menu) }
    @refresh = false
    loop do
      loop_update
      @sel.update
      GlobalMenu.show(false) if @sel.selected?
      return main if @refresh
      break if escape or $scene != self
    end
    $scene = Scene_Main.new if $scene == self
  end

  def context(menu)
    program = @all[@sel.index]
    s = p_("Programs", "Install")
    inst = false
    @installed.each { |g|
      if g.name == program.name and g.path == program.path and g.author == program.author
        inst = true
        if g.version == program.version
          s = p_("Programs", "Reinstall")
        else
          s = p_("Programs", "Update")
        end
      end
    }
    menu.option(s) {
      d = srvproc("apps_list", { "listfiles" => program.path })
      if d[0].to_i == 0 and d.size > 1
        sz = d[1].to_i
        size = sz
        if sz > 1024 ** 3
          size = (((sz * 100.0 / 1024 ** 3).round) / 100.0).to_s + "GB"
        elsif sz > 1024 ** 2
          size = (((sz * 100.0 / 1024 ** 2).round) / 100.0).to_s + "MB"
        elsif sz > 1024
          size = (((sz * 100.0 / 1024).round) / 100.0).to_s + "kB"
        else
          size = sz.to_s + "B"
        end
        confirm(p_("Programs", "Do you want to install program %{name}? Need to download %{size} of data.") % { "name" => program.name, "size" => size.to_s }) {
          path = program.realpath
          if path == nil
            bpath = Dirs.apps + "\\" + program.path
            path = bpath + ""
            i = 0
            loop {
              path = bpath + ""
              path += "(#{i})" if i > 0
              break if !FileTest.exists?(Dirs.apps + "\\" + path)
              i += 1
            }
          else
            path = Dirs.apps + "\\" + path
          end
          waiting
          ds = []
          prc = 0
          lprc = 0
          for i in 0...(d.size / 2 - 1)
            src = $url + d[2 + i * 2 + 1].delete("\r\n")
            dst = path + "\\" + d[2 + i * 2].delete("\r\n").gsub("/", "\\").delete(":")
            next if dst.include?("..\\")
            pr = dst.sub(Dirs.apps, "").split("\\")[0...-1]
            for j in 0...pr.size
              t = Dirs.apps + "\\" + pr[0..j].join("\\")
              if !ds.include?(t)
                createdirifneeded(t)
                ds.push(t)
              end
            end
            downloadfile(src, dst, false, false, true)
            prc = ((i + 1).to_f / (d.size / 2).to_f * 100.0).to_i
            if prc > lprc + 5
              speak(prc.to_s + "%")
              lprc = prc
            end
          end
          waiting_end
          alert(p_("Programs", "Installation completed."))
          Programs.delete(program.realpath) if program.realpath != nil
          Programs.load_sig(path.sub(Dirs.apps + "\\", ""))
          setlocale(Configuration.language)
          @refresh = true
        }
      end
    }
    if inst == true
      menu.option(p_("Programs", "Remove")) {
        confirm(p_("Programs", "Are you sure you want to remove program %{name}?") % { "name" => program.name }) {
          deldir(Dirs.apps + "\\" + program.realpath)
          Programs.delete(program.realpath)
          alert(p_("Programs", "Program removed"))
          @refresh = true
        }
      }
    end
  end
end

class Struct_Programs_Program
  attr_accessor :name, :file, :version, :author, :path
  attr_reader :realpath
  def self.load(path)
    f = Dirs.apps + "\\" + path + "\\__app.ini"
    return if !FileTest.exists?(f)
    name = readini(f, "App", "Name", "")
    version = readini(f, "App", "Version", "")
    author = readini(f, "App", "Author", "")
    file = readini(f, "App", "File", "")
    ppath = path.gsub(/\([^\)]+\)/, "")
    new(ppath, name, version, author, file, path)
  end

  def initialize(path, name, version, author, file, realpath = nil)
    @realpath = realpath
    @name = name
    @version = version
    @author = author
    @file = file
    @path = path
  end
end
