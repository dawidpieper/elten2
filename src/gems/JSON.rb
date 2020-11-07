#frozen_string_literal: false
# frozen_string_literal: false
module JSON
  # JSON version
  VERSION = "2.2.0"
  VERSION_ARRAY = VERSION.split(/\./).map { |x| x.to_i } # :nodoc:
  VERSION_MAJOR = VERSION_ARRAY[0] # :nodoc:
  VERSION_MINOR = VERSION_ARRAY[1] # :nodoc:
  VERSION_BUILD = VERSION_ARRAY[2] # :nodoc:
end

#frozen_string_literal: false

module JSON
  class GenericObject < OpenStruct
    class << self
      alias [] new

      def json_creatable?
        @json_creatable
      end

      attr_writer :json_creatable

      def json_create(data)
        data = data.dup
        data.delete JSON.create_id
        self[data]
      end

      def from_hash(object)
        case
        when object.respond_to?(:to_hash)
          result = new
          object.to_hash.each do |key, value|
            result[key] = from_hash(value)
          end
          result
        when object.respond_to?(:to_ary)
          object.to_ary.map { |a| from_hash(a) }
        else
          object
        end
      end

      def load(source, proc = nil, opts = {})
        result = ::JSON.load(source, proc, opts.merge(:object_class => self))
        result.nil? ? new : result
      end

      def dump(obj, *args)
        ::JSON.dump(obj, *args)
      end
    end
    self.json_creatable = false

    def to_hash
      table
    end

    def [](name)
      __send__(name)
    end unless method_defined?(:[])

    def []=(name, value)
      __send__("#{name}=", value)
    end unless method_defined?(:[]=)

    def |(other)
      self.class[other.to_hash.merge(to_hash)]
    end

    def as_json(*)
      { JSON.create_id => self.class.name }.merge to_hash
    end

    def to_json(*a)
      as_json.to_json(*a)
    end
  end
end

module JSON
  class << self
    # If _object_ is string-like, parse the string and return the parsed
    # result as a Ruby data structure. Otherwise generate a JSON text from the
    # Ruby data structure object and return it.
    #
    # The _opts_ argument is passed through to generate/parse respectively.
    # See generate and parse for their documentation.
    def [](object, opts = {})
      if object.respond_to? :to_str
        JSON.parse(object.to_str, opts)
      else
        JSON.generate(object, opts)
      end
    end

    # Returns the JSON parser class that is used by JSON. This is either
    # JSON::Ext::Parser or JSON::Pure::Parser.
    attr_reader :parser

    # Set the JSON parser class _parser_ to be used by JSON.
    def parser=(parser) # :nodoc:
      @parser = parser
      remove_const :Parser if const_defined?(:Parser)
      const_set :Parser, parser
    end

    # Return the constant located at _path_. The format of _path_ has to be
    # either ::A::B::C or A::B::C. In any case, A has to be located at the top
    # level (absolute namespace path?). If there doesn't exist a constant at
    # the given path, an ArgumentError is raised.
    def deep_const_get(path) # :nodoc:
      path.to_s.split(/::/).inject(Object) do |p, c|
        case
        when c.empty?            then p
        when p.const_defined?(c) then p.const_get(c)
        else
          begin
            p.const_missing(c)
          rescue NameError => e
            raise ArgumentError, "can't get const #{path}: #{e}"
          end
        end
      end
    end

    # Set the module _generator_ to be used by JSON.
    def generator=(generator) # :nodoc:
      old, $VERBOSE = $VERBOSE, nil
      @generator = generator
      generator_methods = generator::GeneratorMethods
      for const in generator_methods.constants
        klass = deep_const_get(const)
        modul = generator_methods.const_get(const)
        klass.class_eval do
          instance_methods(false).each do |m|
            m.to_s == "to_json" and remove_method m
          end
          include modul
        end
      end
      self.state = generator::State
      const_set :State, self.state
      const_set :SAFE_STATE_PROTOTYPE, State.new
      const_set :FAST_STATE_PROTOTYPE, State.new(
        :indent => "",
        :space => "",
        :object_nl => "",
        :array_nl => "",
        :max_nesting => false
      )
      const_set :PRETTY_STATE_PROTOTYPE, State.new(
        :indent => "  ",
        :space => " ",
        :object_nl => "\n",
        :array_nl => "\n"
      )
    ensure
      $VERBOSE = old
    end

    # Returns the JSON generator module that is used by JSON. This is
    # either JSON::Ext::Generator or JSON::Pure::Generator.
    attr_reader :generator

    # Returns the JSON generator state class that is used by JSON. This is
    # either JSON::Ext::Generator::State or JSON::Pure::Generator::State.
    attr_accessor :state

    # This is create identifier, which is used to decide if the _json_create_
    # hook of a class should be called. It defaults to 'json_class'.
    attr_accessor :create_id
  end
  self.create_id = "json_class"

  NaN = 0.0 / 0

  Infinity = 1.0 / 0

  MinusInfinity = -Infinity

  # The base exception for JSON errors.
  class JSONError < StandardError
    def self.wrap(exception)
      obj = new("Wrapped(#{exception.class}): #{exception.message.inspect}")
      obj.set_backtrace exception.backtrace
      obj
    end
  end

  # This exception is raised if a parser error occurs.
  class ParserError < JSONError; end

  # This exception is raised if the nesting of parsed data structures is too
  # deep.
  class NestingError < ParserError; end

  # :stopdoc:
  class CircularDatastructure < NestingError; end

  # :startdoc:

  # This exception is raised if a generator or unparser error occurs.
  class GeneratorError < JSONError; end

  # For backwards compatibility
  UnparserError = GeneratorError

  # This exception is raised if the required unicode support is missing on the
  # system. Usually this means that the iconv library is not installed.
  class MissingUnicodeSupport < JSONError; end

  module_function

  # Parse the JSON document _source_ into a Ruby data structure and return it.
  #
  # _opts_ can have the following
  # keys:
  # * *max_nesting*: The maximum depth of nesting allowed in the parsed data
  #   structures. Disable depth checking with :max_nesting => false. It
  #   defaults to 100.
  # * *allow_nan*: If set to true, allow NaN, Infinity and -Infinity in
  #   defiance of RFC 7159 to be parsed by the Parser. This option defaults
  #   to false.
  # * *symbolize_names*: If set to true, returns symbols for the names
  #   (keys) in a JSON object. Otherwise strings are returned. Strings are
  #   the default.
  # * *create_additions*: If set to false, the Parser doesn't create
  #   additions even if a matching class and create_id was found. This option
  #   defaults to false.
  # * *object_class*: Defaults to Hash
  # * *array_class*: Defaults to Array
  def parse(source, opts = {})
    Parser.new(source, opts).parse
  end

  # Parse the JSON document _source_ into a Ruby data structure and return it.
  # The bang version of the parse method defaults to the more dangerous values
  # for the _opts_ hash, so be sure only to parse trusted _source_ documents.
  #
  # _opts_ can have the following keys:
  # * *max_nesting*: The maximum depth of nesting allowed in the parsed data
  #   structures. Enable depth checking with :max_nesting => anInteger. The
  #   parse! methods defaults to not doing max depth checking: This can be
  #   dangerous if someone wants to fill up your stack.
  # * *allow_nan*: If set to true, allow NaN, Infinity, and -Infinity in
  #   defiance of RFC 7159 to be parsed by the Parser. This option defaults
  #   to true.
  # * *create_additions*: If set to false, the Parser doesn't create
  #   additions even if a matching class and create_id was found. This option
  #   defaults to false.
  def parse!(source, opts = {})
    opts = {
      :max_nesting => false,
      :allow_nan => true
    }.merge(opts)
    Parser.new(source, opts).parse
  end

  # Generate a JSON document from the Ruby data structure _obj_ and return
  # it. _state_ is * a JSON::State object,
  # * or a Hash like object (responding to to_hash),
  # * an object convertible into a hash by a to_h method,
  # that is used as or to configure a State object.
  #
  # It defaults to a state object, that creates the shortest possible JSON text
  # in one line, checks for circular data structures and doesn't allow NaN,
  # Infinity, and -Infinity.
  #
  # A _state_ hash can have the following keys:
  # * *indent*: a string used to indent levels (default: ''),
  # * *space*: a string that is put after, a : or , delimiter (default: ''),
  # * *space_before*: a string that is put before a : pair delimiter (default: ''),
  # * *object_nl*: a string that is put at the end of a JSON object (default: ''),
  # * *array_nl*: a string that is put at the end of a JSON array (default: ''),
  # * *allow_nan*: true if NaN, Infinity, and -Infinity should be
  #   generated, otherwise an exception is thrown if these values are
  #   encountered. This options defaults to false.
  # * *max_nesting*: The maximum depth of nesting allowed in the data
  #   structures from which JSON is to be generated. Disable depth checking
  #   with :max_nesting => false, it defaults to 100.
  #
  # See also the fast_generate for the fastest creation method with the least
  # amount of sanity checks, and the pretty_generate method for some
  # defaults for pretty output.
  def generate(obj, opts = nil)
    if State === opts
      state, opts = opts, nil
    else
      state = SAFE_STATE_PROTOTYPE.dup
    end
    if opts
      if opts.respond_to? :to_hash
        opts = opts.to_hash
      elsif opts.respond_to? :to_h
        opts = opts.to_h
      else
        raise TypeError, "can't convert #{opts.class} into Hash"
      end
      state = state.configure(opts)
    end
    state.generate(obj)
  end

  # :stopdoc:
  # I want to deprecate these later, so I'll first be silent about them, and
  # later delete them.
  alias unparse generate
  module_function :unparse
  # :startdoc:

  # Generate a JSON document from the Ruby data structure _obj_ and return it.
  # This method disables the checks for circles in Ruby objects.
  #
  # *WARNING*: Be careful not to pass any Ruby data structures with circles as
  # _obj_ argument because this will cause JSON to go into an infinite loop.
  def fast_generate(obj, opts = nil)
    if State === opts
      state, opts = opts, nil
    else
      state = FAST_STATE_PROTOTYPE.dup
    end
    if opts
      if opts.respond_to? :to_hash
        opts = opts.to_hash
      elsif opts.respond_to? :to_h
        opts = opts.to_h
      else
        raise TypeError, "can't convert #{opts.class} into Hash"
      end
      state.configure(opts)
    end
    state.generate(obj)
  end

  # :stopdoc:
  # I want to deprecate these later, so I'll first be silent about them, and later delete them.
  alias fast_unparse fast_generate
  module_function :fast_unparse
  # :startdoc:

  # Generate a JSON document from the Ruby data structure _obj_ and return it.
  # The returned document is a prettier form of the document returned by
  # #unparse.
  #
  # The _opts_ argument can be used to configure the generator. See the
  # generate method for a more detailed explanation.
  def pretty_generate(obj, opts = nil)
    if State === opts
      state, opts = opts, nil
    else
      state = PRETTY_STATE_PROTOTYPE.dup
    end
    if opts
      if opts.respond_to? :to_hash
        opts = opts.to_hash
      elsif opts.respond_to? :to_h
        opts = opts.to_h
      else
        raise TypeError, "can't convert #{opts.class} into Hash"
      end
      state.configure(opts)
    end
    state.generate(obj)
  end

  # :stopdoc:
  # I want to deprecate these later, so I'll first be silent about them, and later delete them.
  alias pretty_unparse pretty_generate
  module_function :pretty_unparse
  # :startdoc:

  class << self
    # The global default options for the JSON.load method:
    #  :max_nesting: false
    #  :allow_nan:   true
    #  :allow_blank:  true
    attr_accessor :load_default_options
  end
  self.load_default_options = {
    :max_nesting => false,
    :allow_nan => true,
    :allow_blank => true,
    :create_additions => true
  }

  # Load a ruby data structure from a JSON _source_ and return it. A source can
  # either be a string-like object, an IO-like object, or an object responding
  # to the read method. If _proc_ was given, it will be called with any nested
  # Ruby object as an argument recursively in depth first order. To modify the
  # default options pass in the optional _options_ argument as well.
  #
  # BEWARE: This method is meant to serialise data from trusted user input,
  # like from your own database server or clients under your control, it could
  # be dangerous to allow untrusted users to pass JSON sources into it. The
  # default options for the parser can be changed via the load_default_options
  # method.
  #
  # This method is part of the implementation of the load/dump interface of
  # Marshal and YAML.
  def load(source, proc = nil, options = {})
    opts = load_default_options.merge options
    if source.respond_to? :to_str
      source = source.to_str
    elsif source.respond_to? :to_io
      source = source.to_io.read
    elsif source.respond_to?(:read)
      source = source.read
    end
    if opts[:allow_blank] && (source.nil? || source.empty?)
      source = "null"
    end
    result = parse(source, opts)
    recurse_proc(result, &proc) if proc
    result
  end

  # Recursively calls passed _Proc_ if the parsed data structure is an _Array_ or _Hash_
  def recurse_proc(result, &proc)
    case result
    when Array
      result.each { |x| recurse_proc x, &proc }
      proc.call result
    when Hash
      result.each { |x, y| recurse_proc x, &proc; recurse_proc y, &proc }
      proc.call result
    else
      proc.call result
    end
  end

  alias restore load
  module_function :restore

  class << self
    # The global default options for the JSON.dump method:
    #  :max_nesting: false
    #  :allow_nan:   true
    #  :allow_blank: true
    attr_accessor :dump_default_options
  end
  self.dump_default_options = {
    :max_nesting => false,
    :allow_nan => true
  }

  # Dumps _obj_ as a JSON string, i.e. calls generate on the object and returns
  # the result.
  #
  # If anIO (an IO-like object or an object that responds to the write method)
  # was given, the resulting JSON is written to it.
  #
  # If the number of nested arrays or objects exceeds _limit_, an ArgumentError
  # exception is raised. This argument is similar (but not exactly the
  # same!) to the _limit_ argument in Marshal.dump.
  #
  # The default options for the generator can be changed via the
  # dump_default_options method.
  #
  # This method is part of the implementation of the load/dump interface of
  # Marshal and YAML.
  def dump(obj, anIO = nil, limit = nil)
    if anIO and limit.nil?
      anIO = anIO.to_io if anIO.respond_to?(:to_io)
      unless anIO.respond_to?(:write)
        limit = anIO
        anIO = nil
      end
    end
    opts = JSON.dump_default_options
    opts = opts.merge(:max_nesting => limit) if limit
    result = generate(obj, opts)
    if anIO
      anIO.write result
      anIO
    else
      result
    end
  rescue JSON::NestingError
    raise ArgumentError, "exceed depth limit"
  end

  # Encodes string using Ruby's _String.encode_
  def self.iconv(to, from, string)
    string
  end
end

module ::Kernel
  private

  # Outputs _objs_ to STDOUT as JSON strings in the shortest form, that is in
  # one line.
  def j(*objs)
    objs.each do |obj|
      puts JSON::generate(obj, :allow_nan => true, :max_nesting => false)
    end
    nil
  end

  # Outputs _objs_ to STDOUT as JSON strings in a pretty format, with
  # indentation and over many lines.
  def jj(*objs)
    objs.each do |obj|
      puts JSON::pretty_generate(obj, :allow_nan => true, :max_nesting => false)
    end
    nil
  end

  # If _object_ is string-like, parse the string and return the parsed result as
  # a Ruby data structure. Otherwise, generate a JSON text from the Ruby data
  # structure object and return it.
  #
  # The _opts_ argument is passed through to generate/parse respectively. See
  # generate and parse for their documentation.
  def JSON(object, *args)
    if object.respond_to? :to_str
      JSON.parse(object.to_str, args.first)
    else
      JSON.generate(object, args.first)
    end
  end
end

# Extends any Class to include _json_creatable?_ method.
class ::Class
  # Returns true if this class can be used to create an instance
  # from a serialised JSON string. The class has to implement a class
  # method _json_create_ that expects a hash as first parameter. The hash
  # should include the required data.
  def json_creatable?
    respond_to?(:json_create)
  end
end

#frozen_string_literal: false

module JSON
  module Pure
    # This class implements the JSON parser that is used to parse a JSON string
    # into a Ruby data structure.
    class Parser < StringScanner
      STRING = /" ((?:[^\x0-\x1f"\\] |
                                   # escaped special characters:
                                  \\["\\\/bfnrt] |
                                  \\u[0-9a-fA-F]{4} |
                                   # match all but escaped special characters:
                                  \\[\x20-\x21\x23-\x2e\x30-\x5b\x5d-\x61\x63-\x65\x67-\x6d\x6f-\x71\x73\x75-\xff])*)
                              "/nx
      INTEGER = /(-?0|-?[1-9]\d*)/
      FLOAT = /(-?
                                (?:0|[1-9]\d*)
                                (?:
                                  \.\d+(?i:e[+-]?\d+) |
                                  \.\d+ |
                                  (?i:e[+-]?\d+)
                                )
                                )/x
      NAN = /NaN/
      INFINITY = /Infinity/
      MINUS_INFINITY = /-Infinity/
      OBJECT_OPEN = /\{/
      OBJECT_CLOSE = /\}/
      ARRAY_OPEN = /\[/
      ARRAY_CLOSE = /\]/
      PAIR_DELIMITER = /:/
      COLLECTION_DELIMITER = /,/
      TRUE = /true/
      FALSE = /false/
      NULL = /null/
      IGNORE = %r(
        (?:
         //[^\n\r]*[\n\r]| # line comments
         /\*               # c-style comments
         (?:
          [^*/]|        # normal chars
          /[^*]|        # slashes that do not start a nested comment
          \*[^/]|       # asterisks that do not end this comment
          /(?=\*/)      # single slash before this comment's end
         )*
           \*/               # the End of this comment
           |[ \t\r\n]+       # whitespaces: space, horicontal tab, lf, cr
        )+
      )mx

      UNPARSED = Object.new.freeze

      # Creates a new JSON::Pure::Parser instance for the string _source_.
      #
      # It will be configured by the _opts_ hash. _opts_ can have the following
      # keys:
      # * *max_nesting*: The maximum depth of nesting allowed in the parsed data
      #   structures. Disable depth checking with :max_nesting => false|nil|0,
      #   it defaults to 100.
      # * *allow_nan*: If set to true, allow NaN, Infinity and -Infinity in
      #   defiance of RFC 7159 to be parsed by the Parser. This option defaults
      #   to false.
      # * *symbolize_names*: If set to true, returns symbols for the names
      #   (keys) in a JSON object. Otherwise strings are returned, which is
      #   also the default. It's not possible to use this option in
      #   conjunction with the *create_additions* option.
      # * *create_additions*: If set to true, the Parser creates
      #   additions when if a matching class and create_id was found. This
      #   option defaults to false.
      # * *object_class*: Defaults to Hash
      # * *array_class*: Defaults to Array
      # * *decimal_class*: Specifies which class to use instead of the default
      #    (Float) when parsing decimal numbers. This class must accept a single
      #    string argument in its constructor.
      def initialize(source, opts = {})
        opts ||= {}
        source = convert_encoding source
        super source
        if !opts.key?(:max_nesting) # defaults to 100
          @max_nesting = 100
        elsif opts[:max_nesting]
          @max_nesting = opts[:max_nesting]
        else
          @max_nesting = 0
        end
        @allow_nan = !!opts[:allow_nan]
        @symbolize_names = !!opts[:symbolize_names]
        if opts.key?(:create_additions)
          @create_additions = !!opts[:create_additions]
        else
          @create_additions = false
        end
        @symbolize_names && @create_additions and raise ArgumentError,
                                                        "options :symbolize_names and :create_additions cannot be used " \
                                                        "in conjunction"
        @create_id = @create_additions ? JSON.create_id : nil
        @object_class = opts[:object_class] || Hash
        @array_class = opts[:array_class] || Array
        @decimal_class = opts[:decimal_class]
        @match_string = opts[:match_string]
      end

      alias source string

      def reset
        super
        @current_nesting = 0
      end

      # Parses the current JSON string _source_ and returns the
      # complete data structure as a result.
      def parse
        reset
        obj = nil
        while !eos? && skip(IGNORE) do end
        if eos?
          raise ParserError, "source is not valid JSON!"
        else
          obj = parse_value
          UNPARSED.equal?(obj) and raise ParserError,
                                         "source is not valid JSON!"
        end
        while !eos? && skip(IGNORE) do end
        eos? or raise ParserError, "source is not valid JSON!"
        obj
      end

      private

      def convert_encoding(source)
        if source.respond_to?(:to_str)
          source = source.to_str
        else
          raise TypeError,
            "#{source.inspect} is not like a string"
        end
        source
      end

      # Unescape characters in strings.
      UNESCAPE_MAP = Hash.new { |h, k| h[k] = k.chr }
      UNESCAPE_MAP.update({
        ?" => '"',
        ?\\ => '\\',
        ?/ => "/",
        ?b => "\b",
        ?f => "\f",
        ?n => "\n",
        ?r => "\r",
        ?t => "\t",
        ?u => nil
      })

      EMPTY_8BIT_STRING = ""
      if ::String.method_defined?(:encode)
        EMPTY_8BIT_STRING.force_encoding Encoding::ASCII_8BIT
      end

      def parse_string
        if scan(STRING)
          return "" if self[1].empty?
          string = self[1].gsub(%r((?:\\[\\bfnrt"/]|(?:\\u(?:[A-Fa-f\d]{4}))+|\\[\x20-\xff]))n) do |c|
            if u = UNESCAPE_MAP[$&[1]]
              u
            else # \uXXXX
              bytes = EMPTY_8BIT_STRING.dup
              i = 0
              while c[6 * i] == ?\\ && c[6 * i + 1] == ?u
                bytes << c[6 * i + 2, 2].to_i(16) << c[6 * i + 4, 2].to_i(16)
                i += 1
              end
              JSON.iconv("utf-8", "utf-16be", bytes)
            end
          end
          if string.respond_to?(:force_encoding)
            string.force_encoding(::Encoding::UTF_8)
          end
          if @create_additions and @match_string
            for (regexp, klass) in @match_string
              klass.json_creatable? or next
              string =~ regexp and return klass.json_create(string)
            end
          end
          string
        else
          UNPARSED
        end
        #rescue => e
        #raise ParserError, "Caught #{e.class} at '#{peek(20)}': #{e}"
      end

      def parse_value
        case
        when scan(FLOAT)
          @decimal_class && @decimal_class.new(self[1]) || Float(self[1])
        when scan(INTEGER)
          Integer(self[1])
        when scan(TRUE)
          true
        when scan(FALSE)
          false
        when scan(NULL)
          nil
        when !UNPARSED.equal?(string = parse_string)
          string
        when scan(ARRAY_OPEN)
          @current_nesting += 1
          ary = parse_array
          @current_nesting -= 1
          ary
        when scan(OBJECT_OPEN)
          @current_nesting += 1
          obj = parse_object
          @current_nesting -= 1
          obj
        when @allow_nan && scan(NAN)
          NaN
        when @allow_nan && scan(INFINITY)
          Infinity
        when @allow_nan && scan(MINUS_INFINITY)
          MinusInfinity
        else
          UNPARSED
        end
      end

      def parse_array
        raise NestingError, "nesting of #@current_nesting is too deep" if
          @max_nesting.nonzero? && @current_nesting > @max_nesting
        result = @array_class.new
        delim = false
        until eos?
          case
          when !UNPARSED.equal?(value = parse_value)
            delim = false
            result << value
            skip(IGNORE)
            if scan(COLLECTION_DELIMITER)
              delim = true
            elsif match?(ARRAY_CLOSE)
            else
              raise ParserError, "expected ',' or ']' in array at '#{peek(20)}'!"
            end
          when scan(ARRAY_CLOSE)
            if delim
              raise ParserError, "expected next element in array at '#{peek(20)}'!"
            end
            break
          when skip(IGNORE)
          else
            raise ParserError, "unexpected token in array at '#{peek(20)}'!"
          end
        end
        result
      end

      def parse_object
        raise NestingError, "nesting of #@current_nesting is too deep" if
          @max_nesting.nonzero? && @current_nesting > @max_nesting
        result = @object_class.new
        delim = false
        until eos?
          case
          when !UNPARSED.equal?(string = parse_string)
            skip(IGNORE)
            unless scan(PAIR_DELIMITER)
              raise ParserError, "expected ':' in object at '#{peek(20)}'!"
            end
            skip(IGNORE)
            unless UNPARSED.equal?(value = parse_value)
              result[@symbolize_names ? string.to_sym : string] = value
              delim = false
              skip(IGNORE)
              if scan(COLLECTION_DELIMITER)
                delim = true
              elsif match?(OBJECT_CLOSE)
              else
                raise ParserError, "expected ',' or '}' in object at '#{peek(20)}'!"
              end
            else
              raise ParserError, "expected value in object at '#{peek(20)}'!"
            end
          when scan(OBJECT_CLOSE)
            if delim
              raise ParserError, "expected next name, value pair in object at '#{peek(20)}'!"
            end
            if @create_additions and klassname = result[@create_id]
              klass = JSON.deep_const_get klassname
              break unless klass and klass.json_creatable?
              result = klass.json_create(result)
            end
            break
          when skip(IGNORE)
          else
            raise ParserError, "unexpected token in object at '#{peek(20)}'!"
          end
        end
        result
      end
    end
  end
end

#frozen_string_literal: false
module JSON
  MAP = {
    "\x0" => '\u0000',
    "\x1" => '\u0001',
    "\x2" => '\u0002',
    "\x3" => '\u0003',
    "\x4" => '\u0004',
    "\x5" => '\u0005',
    "\x6" => '\u0006',
    "\x7" => '\u0007',
    "\b" => '\b',
    "\t" => '\t',
    "\n" => '\n',
    "\xb" => '\u000b',
    "\f" => '\f',
    "\r" => '\r',
    "\xe" => '\u000e',
    "\xf" => '\u000f',
    "\x10" => '\u0010',
    "\x11" => '\u0011',
    "\x12" => '\u0012',
    "\x13" => '\u0013',
    "\x14" => '\u0014',
    "\x15" => '\u0015',
    "\x16" => '\u0016',
    "\x17" => '\u0017',
    "\x18" => '\u0018',
    "\x19" => '\u0019',
    "\x1a" => '\u001a',
    "\x1b" => '\u001b',
    "\x1c" => '\u001c',
    "\x1d" => '\u001d',
    "\x1e" => '\u001e',
    "\x1f" => '\u001f',
    '"' => '\"',
    '\\' => '\\\\'
  } # :nodoc:

  # Convert a UTF8 encoded Ruby string _string_ to a JSON string, encoded with
  # UTF16 big endian characters as \u????, and return it.
  def utf8_to_json(string) # :nodoc:
    string = string.dup
    string.gsub!(/["\\\x0-\x1f]/) { MAP[$&] }
    string
  end

  def utf8_to_json_ascii(string) # :nodoc:
    string = string.dup
    string.force_encoding(::Encoding::ASCII_8BIT)
    string.gsub!(/["\\\x0-\x1f]/n) { MAP[$&] }
    string.gsub!(/(
      (?:
       [\xc2-\xdf][\x80-\xbf]    |
       [\xe0-\xef][\x80-\xbf]{2} |
       [\xf0-\xf4][\x80-\xbf]{3}
      )+ |
      [\x80-\xc1\xf5-\xff]       # invalid
    )/nx) { |c|
      c.size == 1 and raise GeneratorError, "invalid utf8 byte: '#{c}'"
      s = JSON.iconv("utf-16be", "utf-8", c).unpack("H*")[0]
      s.force_encoding(::Encoding::ASCII_8BIT)
      s.gsub!(/.{4}/n, '\\\\u\&')
      s.force_encoding(::Encoding::UTF_8)
    }
    string.force_encoding(::Encoding::UTF_8)
    string
  rescue => e
    raise GeneratorError.wrap(e)
  end

  def valid_utf8?(string)
    return true
  end

  module_function :utf8_to_json, :utf8_to_json_ascii, :valid_utf8?

  module Pure
    module Generator
      # This class is used to create State instances, that are use to hold data
      # while generating a JSON text from a Ruby data structure.
      class State
        # Creates a State object from _opts_, which ought to be Hash to create
        # a new State instance configured by _opts_, something else to create
        # an unconfigured instance. If _opts_ is a State object, it is just
        # returned.
        def self.from_state(opts)
          case
          when self === opts
            opts
          when opts.respond_to?(:to_hash)
            new(opts.to_hash)
          when opts.respond_to?(:to_h)
            new(opts.to_h)
          else
            SAFE_STATE_PROTOTYPE.dup
          end
        end

        # Instantiates a new State object, configured by _opts_.
        #
        # _opts_ can have the following keys:
        #
        # * *indent*: a string used to indent levels (default: ''),
        # * *space*: a string that is put after, a : or , delimiter (default: ''),
        # * *space_before*: a string that is put before a : pair delimiter (default: ''),
        # * *object_nl*: a string that is put at the end of a JSON object (default: ''),
        # * *array_nl*: a string that is put at the end of a JSON array (default: ''),
        # * *check_circular*: is deprecated now, use the :max_nesting option instead,
        # * *max_nesting*: sets the maximum level of data structure nesting in
        #   the generated JSON, max_nesting = 0 if no maximum should be checked.
        # * *allow_nan*: true if NaN, Infinity, and -Infinity should be
        #   generated, otherwise an exception is thrown, if these values are
        #   encountered. This options defaults to false.
        def initialize(opts = {})
          @indent = ""
          @space = ""
          @space_before = ""
          @object_nl = ""
          @array_nl = ""
          @allow_nan = false
          @ascii_only = false
          @buffer_initial_length = 1024
          configure opts
        end

        # This string is used to indent levels in the JSON text.
        attr_accessor :indent

        # This string is used to insert a space between the tokens in a JSON
        # string.
        attr_accessor :space

        # This string is used to insert a space before the ':' in JSON objects.
        attr_accessor :space_before

        # This string is put at the end of a line that holds a JSON object (or
        # Hash).
        attr_accessor :object_nl

        # This string is put at the end of a line that holds a JSON array.
        attr_accessor :array_nl

        # This integer returns the maximum level of data structure nesting in
        # the generated JSON, max_nesting = 0 if no maximum is checked.
        attr_accessor :max_nesting

        # :stopdoc:
        attr_reader :buffer_initial_length

        def buffer_initial_length=(length)
          if length > 0
            @buffer_initial_length = length
          end
        end

        # :startdoc:

        # This integer returns the current depth data structure nesting in the
        # generated JSON.
        attr_accessor :depth

        def check_max_nesting # :nodoc:
          return if @max_nesting.zero?
          current_nesting = depth + 1
          current_nesting > @max_nesting and
            raise NestingError, "nesting of #{current_nesting} is too deep"
        end

        # Returns true, if circular data structures are checked,
        # otherwise returns false.
        def check_circular?
          !@max_nesting.zero?
        end

        # Returns true if NaN, Infinity, and -Infinity should be considered as
        # valid JSON and output.
        def allow_nan?
          @allow_nan
        end

        # Returns true, if only ASCII characters should be generated. Otherwise
        # returns false.
        def ascii_only?
          @ascii_only
        end

        # Configure this State instance with the Hash _opts_, and return
        # itself.
        def configure(opts)
          if opts.respond_to?(:to_hash)
            opts = opts.to_hash
          elsif opts.respond_to?(:to_h)
            opts = opts.to_h
          else
            raise TypeError, "can't convert #{opts.class} into Hash"
          end
          for key, value in opts
            instance_variable_set "@#{key}", value
          end
          @indent = opts[:indent] if opts.key?(:indent)
          @space = opts[:space] if opts.key?(:space)
          @space_before = opts[:space_before] if opts.key?(:space_before)
          @object_nl = opts[:object_nl] if opts.key?(:object_nl)
          @array_nl = opts[:array_nl] if opts.key?(:array_nl)
          @allow_nan = !!opts[:allow_nan] if opts.key?(:allow_nan)
          @ascii_only = opts[:ascii_only] if opts.key?(:ascii_only)
          @depth = opts[:depth] || 0
          @buffer_initial_length ||= opts[:buffer_initial_length]

          if !opts.key?(:max_nesting) # defaults to 100
            @max_nesting = 100
          elsif opts[:max_nesting]
            @max_nesting = opts[:max_nesting]
          else
            @max_nesting = 0
          end
          self
        end

        alias merge configure

        # Returns the configuration instance variables as a hash, that can be
        # passed to the configure method.
        def to_h
          result = {}
          for iv in instance_variables
            iv = iv.to_s[1..-1]
            result[iv.to_sym] = self[iv]
          end
          result
        end

        alias to_hash to_h

        # Generates a valid JSON document from object +obj+ and
        # returns the result. If no valid JSON document can be
        # created this method raises a
        # GeneratorError exception.
        def generate(obj)
          result = obj.to_json(self)
          JSON.valid_utf8?(result) or raise GeneratorError,
                                            "source sequence #{result.inspect} is illegal/malformed utf-8"
          result
        end

        # Return the value returned by method +name+.
        def [](name)
          if respond_to?(name)
            __send__(name)
          else
            instance_variable_get("@#{name}")
          end
        end

        def []=(name, value)
          if respond_to?(name_writer = "#{name}=")
            __send__ name_writer, value
          else
            instance_variable_set "@#{name}", value
          end
        end
      end

      module GeneratorMethods
        module Object
          # Converts this object to a string (calling #to_s), converts
          # it to a JSON string, and returns the result. This is a fallback, if no
          # special method #to_json was defined for some object.
          def to_json(*) to_s.to_json end
        end

        module Hash
          # Returns a JSON string containing a JSON object, that is unparsed from
          # this Hash instance.
          # _state_ is a JSON::State object, that can also be used to configure the
          # produced JSON string output further.
          # _depth_ is used to find out nesting depth, to indent accordingly.
          def to_json(state = nil, *)
            state = State.from_state(state)
            state.check_max_nesting
            json_transform(state)
          end

          private

          def json_shift(state)
            state.object_nl.empty? or return ""
            state.indent * state.depth
          end

          def json_transform(state)
            delim = ","
            delim << state.object_nl
            result = "{"
            result << state.object_nl
            depth = state.depth += 1
            first = true
            indent = !state.object_nl.empty?
            each { |key, value|
              result << delim unless first
              result << state.indent * depth if indent
              result << key.to_s.to_json(state)
              result << state.space_before
              result << ":"
              result << state.space
              if value.respond_to?(:to_json)
                result << value.to_json(state)
              else
                result << %{"#{String(value)}"}
              end
              first = false
            }
            depth = state.depth -= 1
            result << state.object_nl
            result << state.indent * depth if indent
            result << "}"
            result
          end
        end

        module Array
          # Returns a JSON string containing a JSON array, that is unparsed from
          # this Array instance.
          # _state_ is a JSON::State object, that can also be used to configure the
          # produced JSON string output further.
          def to_json(state = nil, *)
            state = State.from_state(state)
            state.check_max_nesting
            json_transform(state)
          end

          private

          def json_transform(state)
            delim = ","
            delim << state.array_nl
            result = "["
            result << state.array_nl
            depth = state.depth += 1
            first = true
            indent = !state.array_nl.empty?
            each { |value|
              result << delim unless first
              result << state.indent * depth if indent
              if value.respond_to?(:to_json)
                result << value.to_json(state)
              else
                result << %{"#{String(value)}"}
              end
              first = false
            }
            depth = state.depth -= 1
            result << state.array_nl
            result << state.indent * depth if indent
            result << "]"
          end
        end

        module Integer
          # Returns a JSON string representation for this Integer number.
          def to_json(*) to_s end
        end

        module Float
          # Returns a JSON string representation for this Float number.
          def to_json(state = nil, *)
            state = State.from_state(state)
            case
            when infinite?
              if state.allow_nan?
                to_s
              else
                raise GeneratorError, "#{self} not allowed in JSON"
              end
            when nan?
              if state.allow_nan?
                to_s
              else
                raise GeneratorError, "#{self} not allowed in JSON"
              end
            else
              to_s
            end
          end
        end

        module String
          # This string should be encoded with UTF-8 A call to this method
          # returns a JSON string encoded with UTF16 big endian characters as
          # \u????.
          def to_json(state = nil, *args)
            state = State.from_state(state)
            string = self
            if state.ascii_only?
              '"' << JSON.utf8_to_json_ascii(string) << '"'
            else
              '"' << JSON.utf8_to_json(string) << '"'
            end
          end

          # Module that holds the extinding methods if, the String module is
          # included.
          module Extend
            # Raw Strings are JSON Objects (the raw bytes are stored in an
            # array for the key "raw"). The Ruby String can be created by this
            # module method.
            def json_create(o)
              o["raw"].pack("C*")
            end
          end

          # Extends _modul_ with the String::Extend module.
          def self.included(modul)
            modul.extend Extend
          end

          # This method creates a raw object hash, that can be nested into
          # other data structures and will be unparsed as a raw string. This
          # method should be used, if you want to convert raw strings to JSON
          # instead of UTF-8 strings, e. g. binary data.
          def to_json_raw_object
            {
              JSON.create_id => self.class.name,
              "raw" => self.unpack("C*")
            }
          end

          # This method creates a JSON text from the result of
          # a call to to_json_raw_object of this String.
          def to_json_raw(*args)
            to_json_raw_object.to_json(*args)
          end
        end

        module TrueClass
          # Returns a JSON string for true: 'true'.
          def to_json(*) "true" end
        end

        module FalseClass
          # Returns a JSON string for false: 'false'.
          def to_json(*) "false" end
        end

        module NilClass
          # Returns a JSON string for nil: 'null'.
          def to_json(*) "null" end
        end
      end
    end
  end
end

module JSON
  # This module holds all the modules/classes that implement JSON's
  # functionality in pure ruby.
  module Pure
    $DEBUG and warn "Using Pure library for JSON."
    JSON.parser = Parser
    JSON.generator = Generator
  end

  JSON_LOADED = true unless defined?(::JSON::JSON_LOADED)
end
