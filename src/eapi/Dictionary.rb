# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module Dictionary
    private

    DictCache = {}
    Docs = {}
    Params = []
    Sources = []
    Translations = []
    Languages = []

    class Language
      attr_accessor :code, :mo, :docs

      def initialize(code = "")
        @code = code
        @mo = ""
        @docs = {}
      end

      def realcode
        return "" if @code.size != 4
        @code[0..1].downcase + "-" + @code[2..3].upcase
      end
    end

    def loadedlanguages
      Languages.deep_dup
    end

    def loadlocaledata(file)
      return if !FileTest.exists?(file)
      io = StringIO.new(readfile(file))
      hdcount = io.read(1).unpack("C").first
      langs = []
      hdcount.times {
        code = io.read(4)
        size = io.read(4).unpack("I").first
        langs.push([code, size])
      }
      languages = []
      for l in langs
        lio = StringIO.new(zstd_decompress(io.read(l[1])))
        lang = Language.new(l[0])
        mosize = lio.read(4).unpack("I").first
        lang.mo = lio.read(mosize)
        while !lio.eof?
          namesize = lio.read(1).unpack("C").first
          name = lio.read(namesize)
          docsize = lio.read(4).unpack("I").first
          doc = lio.read(docsize)
          lang.docs[name] = doc
        end
        languages.push(lang)
      end
      Languages.clear
      for l in languages
        Languages.push(l)
      end
    rescue Exception
    end

    def getlocale(code)
      lang = nil
      for l in Languages
        if l.realcode == code
          lang = l
          break
        end
      end
      return lang
    end

    def setlocale(code)
      code.gsub!("_", "-")
      lang = nil
      for l in Languages
        if l.realcode == code
          lang = l
          break
        end
      end
      return if lang == nil
      loadmo(lang.mo)
      di = Dir.entries(Dirs.apps)
      di.delete(".")
      di.delete("..")
      for d in di
        file = Dirs.apps + "\\" + d + "\\locale\\#{code}.mo"
        loadlocale(file, false) if FileTest.exists?(file)
        file = Dirs.apps + "\\" + d + "\\locale\\#{code[0..1]}.mo"
        loadlocale(file, false) if FileTest.exists?(file)
      end
      for d in lang.docs
        Docs[d[0]] = d[1]
      end
    end

    def loadlocale(file, reset = true)
      loadmo(readfile(file), reset) if FileTest.exists?(file)
    end

    def loadmo(data, reset = true)
      DictCache.clear if reset
      if reset
        Params[0] = nil
        Sources.clear
        Translations.clear
        Params[2] = 2
        Params[3] = "(n!=1)?1:0"
        Params[1] = 0
      end
      Params[0] = nil #file if reset
      return if data == nil
      magic = data[0..3].unpack("I").first
      return if magic != 0x950412de
      format = data[4..7].unpack("I").first
      return if format != 0
      n = data[8..11].unpack("I").first
      Params[1] += n
      src = data[12..15].unpack("I").first
      dst = data[16..19].unpack("I").first
      for i in 0...n
        src_length = data[src + 8 * i..src + 8 * i + 3].unpack("I").first
        src_offset = data[src + 8 * i + 4..src + 8 * i + 7].unpack("I").first
        dst_length = data[dst + 8 * i..dst + 8 * i + 3].unpack("I").first
        dst_offset = data[dst + 8 * i + 4..dst + 8 * i + 7].unpack("I").first
        if reset or !Sources.include?(data[src_offset..src_offset + src_length].split("\0"))
          Sources.push(data[src_offset..src_offset + src_length].split("\0"))
          Translations.push(data[dst_offset..dst_offset + dst_length].split("\0"))
          if Sources.last == []
            t = Translations.last
            setparams(t[0]) if t[0].is_a?(String)
          end
          DictCache[Sources.last.first] ||= []
          DictCache[Sources.last.first].push(Sources.size - 1)
        end
      end
    end

    def _doc(d)
      Docs[d] || getlocale("en-GB").docs[d] || ""
    end

    def _(src)
      DictCache
      find(src)[0]
    end

    def n_(*pr)
      forms = []
      n = 0
      for param in pr
        if param.is_a?(String)
          forms.push(param)
        elsif param.is_a?(Integer)
          n = param
        end
      end
      f = find(*forms)
      f[pluralform(n)] || f.last
    end

    def p_(context, src)
      _(context + "\004" + src).gsub(context + "\004", "")
    end

    def s_(str)
      s = _(str)
      if s == str
        return str[str.index("|") + 1..-1]
      else
        return str
      end
    end

    def np_(context, src, *params)
      n_(context + "\004" + src, *params).gsub(context + "\004", "")
    end

    def ns_(context, src, *params)
      str = n_(context + "|" + src, *params)
      str.sub(context + "|", "")
    end

    def N_(*params); end
    def Nn_(*params); end

    private

    def find(*forms)
      c = DictCache[forms.first]
      return forms if c == nil
      for i in c
        return Translations[i] if Sources[i].size >= forms.size && Sources[i][0...forms.size] == forms
      end
      return forms
    end

    def setparams(t)
      pr = t.split("\n")
      for param in pr
        c = param.index(": ")
        next if c == nil
        head = param[0...c]
        val = param[c + 2..-1]
        if head == "Plural-Forms"
          parse_plurals(val)
        end
      end
    end

    def parse_plurals(pl)
      pl = pl.delete(" \t")
      if (/Params[2]=(\d+)/ =~ pl) != nil
        Params[2] = $1.to_i
      end
      if (/plural=([^;]+);/ =~ pl) != nil
        Params[3] = $1
      end
    end

    def pluralform(n)
      eval(Params[3]).to_i
    rescue Exception
      return 0
    end
  end

  include Dictionary
end
