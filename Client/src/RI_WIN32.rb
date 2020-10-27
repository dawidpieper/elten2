=begin
= Win32 Registry I/F
win32/registry is registry accessor library for Win32 platform.
It uses Win32API to call Win32 Registry APIs.

== example
  Win32::Registry::HKEY_CURRENT_USER.open('SOFTWARE\foo') do |reg|
    value = reg['foo']                               # read a value
    value = reg['foo', Win32::Registry::REG_SZ]      # read a value with type
    type, value = reg.read('foo')                    # read a value
    reg['foo'] = 'bar'                               # write a value
    reg['foo', Win32::Registry::REG_SZ] = 'bar'      # write a value with type
    reg.write('foo', Win32::Registry::REG_SZ, 'bar') # write a value
    
    reg.each_value { |name, type, data| ... }        # Enumerate values
    reg.each_key { |key, wtime| ... }                # Enumerate subkeys
    
    reg.delete_value(name)                         # Delete a value
    reg.delete_key(name)                           # Delete a subkey
    reg.delete_key(name, true)                     # Delete a subkey recursively
  end

= Reference

== Win32::Registry class

=== including modules

* Enumerable
* Registry::Constants

=== class methods
--- Registry.open(key, subkey, desired = KEY_READ, opt = REG_OPTION_RESERVED)
--- Registry.open(key, subkey, desired = KEY_READ, opt = REG_OPTION_RESERVED) { |reg| ... }
    Open the registry key ((|subkey|)) under ((|key|)).
    ((|key|)) is Win32::Registry object of parent key.
    You can use predefined key HKEY_* (see ((<constants>)))
    
    ((|desired|)) and ((|opt|)) is access mask and key option.
    For detail, see ((<MSDN Library|URL:http://msdn.microsoft.com/library/en-us/sysinfo/base/regopenkeyex.asp>)).
    
    If block is given, the key is closed automatically.

--- Registry.create(key, subkey, desired = KEY_ALL_ACCESS, opt = REG_OPTION_RESERVED)
--- Registry.create(key, subkey, desired = KEY_ALL_ACCESS, opt = REG_OPTION_RESERVED) { |reg| ... }
    Create or open the registry key ((|subkey|)) under ((|key|)).
    You can use predefined key HKEY_* (see ((<constants>)))
    
    If subkey is already exists, key is opened and Registry#((<created?>))
    method will return false.
    
    If block is given, the key is closed automatically.

--- Registry.expand_environ(str)
    Replace (({%\w+%})) into the environment value of ((|str|)).
    This method is used for REG_EXPAND_SZ.
    
    For detail, see ((<ExpandEnvironmentStrings|URL:http://msdn.microsoft.com/library/en-us/sysinfo/base/expandenvironmentstrings.asp>)) Win32 API.

--- Registry.type2name(type)
    Convert registry type value to readable string.

--- Registry.wtime2time(wtime)
    Convert 64-bit FILETIME integer into Time object.

--- Registry.time2wtime(time)
    Convert Time object or Integer object into 64-bit FILETIME.

=== instance methods
--- open(subkey, desired = KEY_READ, opt = REG_OPTION_RESERVED)
    Same as (({Win32::((<Registry.open>))(self, subkey, desired, opt)}))

--- create(subkey, desired = KEY_ALL_ACCESS, opt = REG_OPTION_RESERVED)
    Same as (({Win32::((<Registry.create>))(self, subkey, desired, opt)}))

--- close
    Close key.
    
    After closed, most method raises error.

--- read(name, *rtype)
    Read a registry value named ((|name|)) and return array of
    [ ((|type|)), ((|data|)) ].
    When name is nil, the `default' value is read.
    
    ((|type|)) is value type. (see ((<Win32::Registry::Constants module>)))
    ((|data|)) is value data, its class is:
    :REG_SZ, REG_EXPAND_SZ
       String
    :REG_MULTI_SZ
       Array of String
    :REG_DWORD, REG_DWORD_BIG_ENDIAN, REG_QWORD
       Integer
    :REG_BINARY
       String (contains binary data)
    
    When ((|rtype|)) is specified, the value type must be included by
    ((|rtype|)) array, or TypeError is raised.

--- self[name, *rtype]
    Read a registry value named ((|name|)) and return its value data.
    The class of value is same as ((<read>)) method returns.
    
    If the value type is REG_EXPAND_SZ, returns value data whose environment
    variables are replaced.
    If the value type is neither REG_SZ, REG_MULTI_SZ, REG_DWORD,
    REG_DWORD_BIG_ENDIAN, nor REG_QWORD, TypeError is raised.
    
    The meaning of ((|rtype|)) is same as ((<read>)) method.

--- read_s(name)
--- read_i(name)
--- read_bin(name)
    Read a REG_SZ(read_s), REG_DWORD(read_i), or REG_BINARY(read_bin)
    registry value named ((|name|)).
    
    If the values type does not match, TypeError is raised.

--- read_s_expand(name)
    Read a REG_SZ or REG_EXPAND_SZ registry value named ((|name|)).
    
    If the value type is REG_EXPAND_SZ, environment variables are replaced.
    Unless the value type is REG_SZ or REG_EXPAND_SZ, TypeError is raised.

--- write(name, type, data)
    Write ((|data|)) to a registry value named ((|name|)).
    When name is nil, write to the `default' value.
    
    ((|type|)) is type value. (see ((<Registry::Constants module>)))
    Class of ((|data|)) must be same as which ((<read>))
    method returns.

--- self[name, wtype = nil] = value
    Write ((|value|)) to a registry value named ((|name|)).
    
    If ((|wtype|)) is specified, the value type is it.
    Otherwise, the value type is depend on class of ((|value|)):
    :Integer
      REG_DWORD
    :String
      REG_SZ
    :Array
      REG_MULTI_SZ

--- write_s(name, value)
--- write_i(name, value)
--- write_bin(name, value)
    Write ((|value|)) to a registry value named ((|name|)).
    
    The value type is REG_SZ(write_s), REG_DWORD(write_i), or
    REG_BINARY(write_bin).

--- each { |name, type, value| ... }
--- each_value { |name, type, value| ... }
    Enumerate values.

--- each_key { |subkey, wtime| ... }
    Enumerate subkeys.
    
    ((|subkey|)) is String which contains name of subkey.
    ((|wtime|)) is last write time as FILETIME (64-bit integer).
    (see ((<Registry.wtime2time>)))

--- delete(name)
--- delete_value(name)
    Delete a registry value named ((|name|)).
    We can not delete the `default' value.

--- delete_key(name, recursive = false)
    Delete a subkey named ((|name|)) and all its values.
    
    If ((|recursive|)) is false, the subkey must not have subkeys.
    Otherwise, this method deletes all subkeys and values recursively.

--- flush
    Write all the attributes into the registry file.

--- created?
    Returns if key is created ((*newly*)).
    (see ((<Registry.create>)))

--- open?
    Returns if key is not closed.

--- hkey
    Returns key handle value.

--- parent
    Win32::Registry object of parent key, or nil if predefeined key.

--- keyname
    Same as ((|subkey|)) value of ((<Registry.open>)) or
    ((<Registry.create>)) method.

--- disposition
    Disposition value (REG_CREATED_NEW_KEY or REG_OPENED_EXISTING_KEY).

--- name
--- to_s
    Full path of key such as (({'HKEY_CURRENT_USER\SOFTWARE\foo\bar'})).

--- info
    Returns key information as Array of:
    :num_keys
      The number of subkeys.
    :max_key_length
      Maximum length of name of subkeys.
    :num_values
      The number of values.
    :max_value_name_length
      Maximum length of name of values.
    :max_value_length
      Maximum length of value of values.
    :descriptor_length
      Length of security descriptor.
    :wtime
      Last write time as FILETIME(64-bit integer)
    
    For detail, see ((<RegQueryInfoKey|URL:http://msdn.microsoft.com/library/en-us/sysinfo/base/regqueryinfokey.asp>)) Win32 API.

--- num_keys
--- max_key_length
--- num_values
--- max_value_name_length
--- max_value_length
--- descriptor_length
--- wtime
    Returns an item of key information.

=== constants
--- HKEY_CLASSES_ROOT
--- HKEY_CURRENT_USER
--- HKEY_LOCAL_MACHINE
--- HKEY_PERFORMANCE_DATA
--- HKEY_CURRENT_CONFIG
--- HKEY_DYN_DATA
    Win32::Registry object whose key is predefined key.
    For detail, see ((<MSDN Library|URL:http://msdn.microsoft.com/library/en-us/sysinfo/base/predefined_keys.asp>)).

== Win32::Registry::Constants module

For detail, see ((<MSDN Library|URL:http://msdn.microsoft.com/library/en-us/sysinfo/base/registry.asp>)).

--- HKEY_*
    Predefined key ((*handle*)).
    These are Integer, not Win32::Registry.

--- REG_*
    Registry value type.

--- KEY_*
    Security access mask.

--- KEY_OPTIONS_*
    Key options.

--- REG_CREATED_NEW_KEY
--- REG_OPENED_EXISTING_KEY
    If the key is created newly or opened existing key.
    See also Registry#((<disposition>)) method.

=end


module Win32
  class Registry
    module Constants
      HKEY_CLASSES_ROOT = 0x80000000
      HKEY_CURRENT_USER = 0x80000001
      HKEY_LOCAL_MACHINE = 0x80000002
      HKEY_USERS = 0x80000003
      HKEY_PERFORMANCE_DATA = 0x80000004
      HKEY_PERFORMANCE_TEXT = 0x80000050
      HKEY_PERFORMANCE_NLSTEXT = 0x80000060
      HKEY_CURRENT_CONFIG = 0x80000005
      HKEY_DYN_DATA = 0x80000006
      
      REG_NONE = 0
      REG_SZ = 1
      REG_EXPAND_SZ = 2
      REG_BINARY = 3
      REG_DWORD = 4
      REG_DWORD_LITTLE_ENDIAN = 4
      REG_DWORD_BIG_ENDIAN = 5
      REG_LINK = 6
      REG_MULTI_SZ = 7
      REG_RESOURCE_LIST = 8
      REG_FULL_RESOURCE_DESCRIPTOR = 9
      REG_RESOURCE_REQUIREMENTS_LIST = 10
      REG_QWORD = 11
      REG_QWORD_LITTLE_ENDIAN = 11
      
      STANDARD_RIGHTS_READ = 0x00020000
      STANDARD_RIGHTS_WRITE = 0x00020000
      KEY_QUERY_VALUE = 0x0001
      KEY_SET_VALUE = 0x0002
      KEY_CREATE_SUB_KEY = 0x0004
      KEY_ENUMERATE_SUB_KEYS = 0x0008
      KEY_NOTIFY = 0x0010
      KEY_CREATE_LINK = 0x0020
      KEY_READ = STANDARD_RIGHTS_READ |
        KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS | KEY_NOTIFY
      KEY_WRITE = STANDARD_RIGHTS_WRITE |
        KEY_SET_VALUE | KEY_CREATE_SUB_KEY
      KEY_EXECUTE = KEY_READ
      KEY_ALL_ACCESS = KEY_READ | KEY_WRITE | KEY_CREATE_LINK
      
      REG_OPTION_RESERVED = 0x0000
      REG_OPTION_NON_VOLATILE = 0x0000
      REG_OPTION_VOLATILE = 0x0001
      REG_OPTION_CREATE_LINK = 0x0002
      REG_OPTION_BACKUP_RESTORE = 0x0004
      REG_OPTION_OPEN_LINK = 0x0008
      REG_LEGAL_OPTION = REG_OPTION_RESERVED |
        REG_OPTION_NON_VOLATILE | REG_OPTION_CREATE_LINK |
        REG_OPTION_BACKUP_RESTORE | REG_OPTION_OPEN_LINK
      
      REG_CREATED_NEW_KEY = 1
      REG_OPENED_EXISTING_KEY = 2
      
      REG_WHOLE_HIVE_VOLATILE = 0x0001
      REG_REFRESH_HIVE = 0x0002
      REG_NO_LAZY_FLUSH = 0x0004
      REG_FORCE_RESTORE = 0x0008
      
      MAX_KEY_LENGTH = 514
      MAX_VALUE_LENGTH = 32768
    end
    include Constants
    include Enumerable
    
    #
    # Error
    #
    class Error < ::StandardError
      FormatMessageA = Win32API.new('kernel32.dll', 'FormatMessageA', 'LPLLPLP', 'L')
      def initialize(code)
        @code = code
        msg = "\0" * 1024
        len = FormatMessageA.call(0x1200, 0, code, 0, msg, 1024, 0)
        super msg[0, len].tr("\r", '').chomp
      end
      attr_reader :code
    end
    
    #
    # Predefined Keys
    #
    class PredefinedKey < Registry
      def initialize(hkey, keyname)
        @hkey = hkey
        @parent = nil
        @keyname = keyname
        @disposition = REG_OPENED_EXISTING_KEY
      end
      
      # Predefined keys cannot be closed
      def close
        raise Error.new(5) ## ERROR_ACCESS_DENIED
      end
      
      # Fake class for Registry#open, Registry#create
      def class
        Registry
      end
      
      # Make all
      Constants.constants.grep(/^HKEY_/) do |c|
        Registry.const_set c, new(Constants.const_get(c), c)
      end
    end
    
    #
    # Win32 APIs
    #
    module API
      [
        %w/RegOpenKeyExA    LPLLP        L/,
        %w/RegCreateKeyExA  LPLLLLPPP    L/,
        %w/RegEnumValueA    LLPPPPPP     L/,
        %w/RegEnumKeyExA    LLPPLLLP     L/,
        %w/RegQueryValueExA LPLPPP       L/,
        %w/RegSetValueExA   LPLLPL       L/,
        %w/RegDeleteValue   LP           L/,
        %w/RegDeleteKey     LP           L/,
        %w/RegFlushKey      L            L/,
        %w/RegCloseKey      L            L/,
        %w/RegQueryInfoKey  LPPPPPPPPPPP L/,
      ].each do |fn|
        const_set fn[0].intern, Win32API.new('advapi32.dll', *fn)
      end
      
      module_function
      
      def check(result)
        raise Error, result, caller(2) if result != 0
      end
      
      def packdw(dw)
        [dw].pack('V')
      end
      
      def unpackdw(dw)
        dw += [0].pack('V')
        dw.unpack('V')[0]
      end
      
      def packqw(qw)
        [ qw & 0xFFFFFFFF, qw >> 32 ].pack('VV')
      end
      
      def unpackqw(qw)
        qw = qw.unpack('VV')
        (qw[1] << 32) | qw[0]
      end
      
      def OpenKey(hkey, name, opt, desired)
        result = packdw(0)
        check RegOpenKeyExA.call(hkey, name, opt, desired, result)
        unpackdw(result)
      end
      
      def CreateKey(hkey, name, opt, desired)
        result = packdw(0)
        disp = packdw(0)
        check RegCreateKeyExA.call(hkey, name, 0, 0, opt, desired,
                                   0, result, disp)
        [ unpackdw(result), unpackdw(disp) ]
      end
      
      def EnumValue(hkey, index)
        name = ' ' * Constants::MAX_KEY_LENGTH
        size = packdw(Constants::MAX_KEY_LENGTH)
        check RegEnumValueA.call(hkey, index, name, size, 0, 0, 0, 0)
        name[0, unpackdw(size)]
      end
      
      def EnumKey(hkey, index)
        name = ' ' * Constants::MAX_KEY_LENGTH
        size = packdw(Constants::MAX_KEY_LENGTH)
        wtime = ' ' * 8
        check RegEnumKeyExA.call(hkey, index, name, size, 0, 0, 0, wtime)
        [ name[0, unpackdw(size)], unpackqw(wtime) ]
      end
      
      def QueryValue(hkey, name)
        type = packdw(0)
        size = packdw(0)
        check RegQueryValueExA.call(hkey, name, 0, type, 0, size)
        data = ' ' * unpackdw(size)
        check RegQueryValueExA.call(hkey, name, 0, type, data, size)
        [ unpackdw(type), data[0, unpackdw(size)] ]
      end
      
      def SetValue(hkey, name, type, data, size)
        check RegSetValueExA.call(hkey, name, 0, type, data, size)
      end
      
      def DeleteValue(hkey, name)
        check RegDeleteValue.call(hkey, name)
      end
      
      def DeleteKey(hkey, name)
        check RegDeleteKey.call(hkey, name)
      end
      
      def FlushKey(hkey)
        check RegFlushKey.call(hkey)
      end
      
      def CloseKey(hkey)
        check RegCloseKey.call(hkey)
      end
      
      def QueryInfoKey(hkey)
        subkeys = packdw(0)
        maxsubkeylen = packdw(0)
        values = packdw(0)
        maxvaluenamelen = packdw(0)
        maxvaluelen = packdw(0)
        secdescs = packdw(0)
        wtime = ' ' * 8
        check RegQueryInfoKey.call(hkey, 0, 0, 0, subkeys, maxsubkeylen, 0,
          values, maxvaluenamelen, maxvaluelen, secdescs, wtime)
        [ unpackdw(subkeys), unpackdw(maxsubkeylen), unpackdw(values),
          unpackdw(maxvaluenamelen), unpackdw(maxvaluelen),
          unpackdw(secdescs), unpackqw(wtime) ]
      end
    end
    
    #
    # utility functions
    #
    def self.expand_environ(str)
      str.gsub(/%([^%]+)%/) { ENV[$1] || ENV[$1.upcase] || $& }
    end
    
    @@type2name = { }
    %w[
      REG_NONE REG_SZ REG_EXPAND_SZ REG_BINARY REG_DWORD
      REG_DWORD_BIG_ENDIAN REG_LINK REG_MULTI_SZ
      REG_RESOURCE_LIST REG_FULL_RESOURCE_DESCRIPTOR
      REG_RESOURCE_REQUIREMENTS_LIST REG_QWORD
    ].each do |type|
      @@type2name[Constants.const_get(type)] = type
    end
    
    def self.type2name(type)
      @@type2name[type] || type.to_s
    end
    
    def self.wtime2time(wtime)
      Time.at((wtime - 116444736000000000) / 10000000)
    end
    
    def self.time2wtime(time)
      time.to_i * 10000000 + 116444736000000000
    end
    
    #
    # constructors
    #
    private_class_method :new
    
    def self.open(hkey, subkey, desired = KEY_READ, opt = REG_OPTION_RESERVED)
      subkey = subkey.chomp('\\')
      newkey = API.OpenKey(hkey.hkey, subkey, opt, desired)
      obj = new(newkey, hkey, subkey, REG_OPENED_EXISTING_KEY)
      if block_given?
        begin
          yield obj
        ensure
          obj.close
        end
      else
        obj
      end
    end
    
    def self.create(hkey, subkey, desired = KEY_ALL_ACCESS, opt = REG_OPTION_RESERVED)
      newkey, disp = API.CreateKey(hkey.hkey, subkey, opt, desired)
      obj = new(newkey, hkey, subkey, disp)
      if block_given?
        begin
          yield obj
        ensure
          obj.close
        end
      else
        obj
      end
    end
    
    #
    # finalizer
    #
    @@final = proc { |hkey| proc { API.CloseKey(hkey[0]) if hkey[0] } }
    
    #
    # initialize
    #
    def initialize(hkey, parent, keyname, disposition)
      @hkey = hkey
      @parent = parent
      @keyname = keyname
      @disposition = disposition
      @hkeyfinal = [ hkey ]
      ObjectSpace.define_finalizer self, @@final.call(@hkeyfinal)
    end
    attr_reader :hkey, :parent, :keyname, :disposition
    
    #
    # attributes
    #
    def created?
      @disposition == REG_CREATED_NEW_KEY
    end
    
    def open?
      !@hkey.nil?
    end
    
    def name
      parent = self
      name = @keyname
      while parent = parent.parent
        name = parent.keyname + '\\' + name
      end
      name
    end
    
    def inspect
      "\#<Win32::Registry key=#{name.inspect}>"
    end
    
    #
    # marshalling
    #
    def _dump(depth)
      raise TypeError, "can't dump Win32::Registry"
    end
    
    #
    # open/close
    #
    def open(subkey, desired = KEY_READ, opt = REG_OPTION_RESERVED, &blk)
      self.class.open(self, subkey, desired, opt, &blk)
    end
    
    def create(subkey, desired = KEY_ALL_ACCESS, opt = REG_OPTION_RESERVED, &blk)
      self.class.create(self, subkey, desired, opt, &blk)
    end
    
    def close
      API.CloseKey(@hkey)
      @hkey = @parent = @keyname = nil
      @hkeyfinal[0] = nil
    end
    
    #
    # iterator
    #
    def each_value
      index = 0
      while true
        begin
          subkey = API.EnumValue(@hkey, index)
        rescue Error
          break
        end
        begin
          type, data = read(subkey)
        rescue Error
          next
        end
        yield subkey, type, data
        index += 1
      end
      index
    end
    alias each each_value
    
    def each_key
      index = 0
      while true
        begin
          subkey, wtime = API.EnumKey(@hkey, index)
        rescue Error
          break
        end
        yield subkey, wtime
        index += 1
      end
      index
    end
    
    def keys
      keys_ary = []
      each_key { |key,| keys_ary << key }
      keys_ary
    end
    
    #
    # reader
    #
    def read(name, *rtype)
            type, data = API.QueryValue(@hkey, name)
          unless rtype.empty? or rtype.include?(type)
        raise TypeError, "Type mismatch (expect #{rtype.inspect} but #{type} present)"
      end
      case type
      when REG_SZ, REG_EXPAND_SZ
        [ type, data.chop ]
      when REG_MULTI_SZ
        [ type, data.split(/\0/) ]
      when REG_BINARY
        [ type, data ]
      when REG_DWORD
        [ type, API.unpackdw(data) ]
      when REG_DWORD_BIG_ENDIAN
        [ type, data.unpack('N')[0] ]
      when REG_QWORD
        [ type, API.unpackqw(data) ]
      else
        raise TypeError, "Type #{type} is not supported."
      end
    end
    
    def [](name, *rtype)
      type, data = read(name, *rtype)
      return nil if type == nil
            case type
      when REG_SZ, REG_DWORD, REG_QWORD, REG_MULTI_SZ
        data
      when REG_EXPAND_SZ
        Registry.expand_environ(data)
      else
        raise TypeError, "Type #{type} is not supported."
      end
    end
    
    def read_s(name)
      read(name, REG_SZ)[1]
    end
    
    def read_s_expand(name)
      type, data = read(name, REG_SZ, REG_EXPAND_SZ)
      if type == REG_EXPAND_SZ
        Registry.expand_environ(data)
      else
        data
      end
    end
    
    def read_i(name)
      read(name, REG_DWORD, REG_DWORD_BIG_ENDIAN, REG_QWORD)[1]
    end
    
    def read_bin(name)
      read(name, REG_BINARY)[1]
    end
    
    #
    # writer
    #
    def write(name, type, data)
      case type
      when REG_SZ, REG_EXPAND_SZ
        data = data.to_s + "\0"
      when REG_MULTI_SZ
        data = data.to_a.join("\0") + "\0\0"
      when REG_BINARY
        data = data.to_s
      when REG_DWORD
        data = API.packdw(data.to_i)
      when REG_DWORD_BIG_ENDIAN
        data = [data.to_i].pack('N')
      when REG_QWORD
        data = API.packqw(data.to_i)
      else
        raise TypeError, "Unsupported type #{type}"
      end
      API.SetValue(@hkey, name, type, data, data.length)
    end
    
    def []=(name, rtype, value = nil)
      if value
        write name, rtype, value
      else
        case value = rtype
        when Integer
          write name, REG_DWORD, value
        when String
          write name, REG_SZ, value
        when Array
          write name, REG_MULTI_SZ, value
        else
          raise TypeError, "Unexpected type #{value.class}"
        end
      end
      value
    end
    
    def write_s(name, value)
      write name, REG_SZ, value.to_s
    end
    
    def write_i(name, value)
      write name, REG_DWORD, value.to_i
    end
    
    def write_bin(name, value)
      write name, REG_BINARY, value.to_s
    end
    
    #
    # delete
    #
    def delete_value(name)
      API.DeleteValue(@hkey, name)
    end
    alias delete delete_value
    
    def delete_key(name, recursive = false)
      if recursive
        open(name, KEY_ALL_ACCESS) do |reg|
          reg.keys.each do |key|
            begin
              reg.delete_key(key, true)
            rescue Error
              #
            end
          end
        end
        API.DeleteKey(@hkey, name)
      else
        begin
          API.EnumKey @hkey, 0
        rescue Error
          return API.DeleteKey(@hkey, name)
        end
        raise Error.new(5) ## ERROR_ACCESS_DENIED
      end
    end
    
    #
    # flush
    #
    def flush
      API.FlushKey @hkey
    end
    
    #
    # key information
    #
    def info
      API.QueryInfoKey(@hkey)
    end
    %w[
      num_keys max_key_length
      num_values max_value_name_length max_value_length
      descriptor_length wtime
    ].each_with_index do |s, i|
      eval <<-__END__
        def #{s}
          info[#{i}]
        end
      __END__
    end
  end
end


=begin
= Win32 DNS and DHCP I/F

=end



module Win32
  module Resolv
    API = Registry::API
    
    def self.get_hosts_path
      path = get_hosts_dir
      path = File.expand_path('hosts', path)
      File.exist?(path) ? path : nil
    end
    
    def self.get_resolv_info
      search, nameserver = get_info
      if search.empty?
        search = nil
      else
        search.delete("")
        search.uniq!
      end
      if nameserver.empty?
        nameserver = nil
      else
        nameserver.delete("")
        nameserver.delete("0.0.0.0")
        nameserver.uniq!
      end
      [ search, nameserver ]
    end

getv = Win32API.new('kernel32.dll', 'GetVersionExA', 'P', 'L')
info = [ 148, 0, 0, 0, 0 ].pack('V5') + "\0" * 128
getv.call(info)
if info.unpack('V5')[4] == 2  # VER_PLATFORM_WIN32_NT
#====================================================================
# Windows NT
#====================================================================
  module_eval <<-'__EOS__', __FILE__, __LINE__+1
    TCPIP_NT = 'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
    
    class << self
      private
      def get_hosts_dir
        Registry::HKEY_LOCAL_MACHINE.open(TCPIP_NT) do |reg|
          reg.read_s_expand('DataBasePath')
        end
      end
      
      def get_info
        search = nil
        nameserver = []
        Registry::HKEY_LOCAL_MACHINE.open(TCPIP_NT) do |reg|
          begin
            slist = reg.read_s('SearchList')
            search = slist.split(/,\s*/) unless slist.empty?
          rescue Registry::Error
          end
          
          if add_search = search.nil?
            search = []
            begin
              nvdom = reg.read_s('NV Domain')
              unless nvdom.empty?
                @search = [ nvdom ]
                if reg.read_i('UseDomainNameDevolution') != 0
                  if /^[\w\d]+\./ =~ nvdom
                    devo = $'
                  end
                end
              end
            rescue Registry::Error
            end
          end
          
          reg.open('Interfaces') do |reg|
            reg.each_key do |iface,|
              reg.open(iface) do |regif|
                begin
                  [ 'NameServer', 'DhcpNameServer' ].each do |key|
                    ns = regif.read_s(key)
                    unless ns.empty?
                      nameserver.concat(ns.split(/[,\s]\s*/))
                      break
                    end
                  end
                rescue Registry::Error
                end
                
                if add_search
                  begin
                    [ 'Domain', 'DhcpDomain' ].each do |key|
                      dom = regif.read_s(key)
                      unless dom.empty?
                        search.concat(dom.split(/,\s*/))
                        break
                      end
                    end
                  rescue Registry::Error
                  end
                end
              end
            end
          end
          search << devo if add_search and devo
        end
        [ search.uniq, nameserver.uniq ]
      end
    end
  __EOS__
else
#====================================================================
# Windows 9x
#====================================================================
  module_eval <<-'__EOS__', __FILE__, __LINE__+1
    TCPIP_9X = 'SYSTEM\CurrentControlSet\Services\VxD\MSTCP'
    DHCP_9X = 'SYSTEM\CurrentControlSet\Services\VxD\DHCP'
    WINDOWS = 'Software\Microsoft\Windows\CurrentVersion'
    
    class << self
   #   private
      
      def get_hosts_dir
        Registry::HKEY_LOCAL_MACHINE.open(WINDOWS) do |reg|
          reg.read_s_expand('SystemRoot')
        end
      end
      
      def get_info
        search = []
        nameserver = []
        begin
          Registry::HKEY_LOCAL_MACHINE.open(TCPIP_9X) do |reg|
            if reg.read_s("EnableDNS") == "1"
              domain = reg.read_s("Domain")
              ns = reg.read_s("NameServer")
              slist = reg.read_s("SearchList")
              search << domain unless domain.empty?
              search.concat(slist.split(/,\s*/))
              nameserver.concat(ns.split(/[,\s]\s*/))
            end
          end
        rescue Registry::Error
        end
        
        dhcpinfo = get_dhcpinfo
        search.concat(dhcpinfo[0])
        nameserver.concat(dhcpinfo[1])
        [ search, nameserver ]
      end
      
      def get_dhcpinfo
        macaddrs = {}
        ipaddrs = {}
        WsControl.get_iflist.each do |index, macaddr, *ipaddr|
          macaddrs[macaddr] = 1
          ipaddr.each { |ipaddr| ipaddrs[ipaddr] = 1 }
        end
        iflist = [ macaddrs, ipaddrs ]
        
        search = []
        nameserver = []
        version = -1
        Registry::HKEY_LOCAL_MACHINE.open(DHCP_9X) do |reg|
          begin
            version = API.unpackdw(reg.read_bin("Version"))
          rescue Registry::Error
          end
          
          reg.each_key do |key,|
            catch(:not_used) do
              reg.open(key) do |regdi|
                dom, ns = get_dhcpinfo_key(version, regdi, iflist)
                search << dom if dom
                nameserver.concat(ns) if ns
              end
            end
          end
        end
        [ search, nameserver ]
      end
      
      def get_dhcpinfo_95(reg)
        dhcp = reg.read_bin("DhcpInfo")
        [
          API.unpackdw(dhcp[4..7]),
          API.unpackdw(dhcp[8..11]),
          1,
          dhcp[45..50],
          reg.read_bin("OptionInfo"),
        ]
      end
      
      def get_dhcpinfo_98(reg)
        [
          API.unpackdw(reg.read_bin("DhcpIPAddress")),
          API.unpackdw(reg.read_bin("DhcpSubnetMask")),
          API.unpackdw(reg.read_bin("HardwareType")),
          reg.read_bin("HardwareAddress"),
          reg.read_bin("OptionInfo"),
        ]
      end
      
      def get_dhcpinfo_key(version, reg, iflist)
        info = case version
               when 1
                 get_dhcpinfo_95(reg)
               when 2
                 get_dhcpinfo_98(reg)
               else
                 begin
                   get_dhcpinfo_98(reg)
                 rescue Registry::Error
                   get_dhcpinfo_95(reg)
                 end
               end
        ipaddr, netmask, hwtype, macaddr, opt = info
        throw :not_used unless
          ipaddr and ipaddr != 0 and
          netmask and netmask != 0 and
          macaddr and macaddr.size == 6 and
          hwtype == 1 and
          iflist[0][macaddr] and iflist[1][ipaddr]
        
        size = opt.size
        idx = 0
        while idx <= size
          opttype = opt[idx]
          optsize = opt[idx + 1]
          optval  = opt[idx + 2, optsize]
          case opttype
          when 0xFF    ## term
            break
          when 0x0F    ## domain
            domain = optval.chomp("\0")
          when 0x06    ## dns
            nameserver = optval.scan(/..../).collect { |addr|
              "%d.%d.%d.%d" % addr.unpack('C4')
            }
          end
          idx += optsize + 2
        end
        [ domain, nameserver ]
      rescue Registry::Error
        throw :not_used
      end
    end
    
    module WsControl
      WsControl = Win32API.new('wsock32.dll', 'WsControl', 'LLPPPP', 'L')
      WSAGetLastError = Win32API.new('wsock32.dll', 'WSAGetLastError', 'V', 'L')
      
      MAX_TDI_ENTITIES = 512
      IPPROTO_TCP = 6
      WSCTL_TCP_QUERY_INFORMATION = 0
      INFO_CLASS_GENERIC = 0x100
      INFO_CLASS_PROTOCOL = 0x200
      INFO_TYPE_PROVIDER = 0x100
      ENTITY_LIST_ID = 0
      GENERIC_ENTITY = 0
      CL_NL_ENTITY = 0x301
      IF_ENTITY = 0x200
      ENTITY_TYPE_ID = 1
      CL_NL_IP = 0x303
      IF_MIB = 0x202
      IF_MIB_STATS_ID = 1
      IP_MIB_ADDRTABLE_ENTRY_ID = 0x102
      
      def self.wsctl(tei_entity, tei_instance,
                     toi_class, toi_type, toi_id,
                     buffsize)
        reqinfo = [
                  ## TDIEntityID
                    tei_entity, tei_instance,
                  ## TDIObjectID
                    toi_class, toi_type, toi_id,
                  ## TCP_REQUEST_INFORMATION_EX
                    ""
                  ].pack('VVVVVa16')
        reqsize = API.packdw(reqinfo.size)
        buff = "\0" * buffsize
        buffsize = API.packdw(buffsize)
        result = WsControl.call(
                   IPPROTO_TCP,
                   WSCTL_TCP_QUERY_INFORMATION,
                   reqinfo, reqsize,
                   buff, buffsize)
        if result != 0
          raise RuntimeError, "WsControl failed.(#{result})"
        end
        [ buff, API.unpackdw(buffsize) ]
      end
      private_class_method :wsctl
      
      def self.get_iflist
        # Get TDI Entity List
        entities, size =
          wsctl(GENERIC_ENTITY, 0,
                INFO_CLASS_GENERIC,
                INFO_TYPE_PROVIDER,
                ENTITY_LIST_ID,
                MAX_TDI_ENTITIES * 8)  # sizeof(TDIEntityID)
        entities = entities[0, size].
                     scan(/.{8}/).
                     collect { |e| e.unpack('VV') }

        # Get MIB Interface List
        iflist = []
        ifcount = 0
        entities.each do |entity, instance|
          if( (entity & IF_ENTITY)>0 )
            ifcount += 1
            etype, = wsctl(entity, instance,
                           INFO_CLASS_GENERIC,
                           INFO_TYPE_PROVIDER,
                           ENTITY_TYPE_ID,
                           4)
            if( (API.unpackdw(etype) & IF_MIB)==IF_MIB )
              ifentry, = wsctl(entity, instance,
                               INFO_CLASS_PROTOCOL,
                               INFO_TYPE_PROVIDER,
                               IF_MIB_STATS_ID,
                               21 * 4 + 8 + 130)  # sizeof(IFEntry)
              iflist << [
                API.unpackdw(ifentry[0,4]),
                ifentry[20, 6]
              ]
            end
          end
        end
        
        # Get IP Addresses
        entities.each do |entity, instance|
          if entity == CL_NL_ENTITY
            etype, = wsctl(entity, instance,
                           INFO_CLASS_GENERIC,
                           INFO_TYPE_PROVIDER,
                           ENTITY_TYPE_ID,
                           4)
            if API.unpackdw(etype) == CL_NL_IP
              ipentries, = wsctl(entity, instance,
                                 INFO_CLASS_PROTOCOL,
                                 INFO_TYPE_PROVIDER,
                                 IP_MIB_ADDRTABLE_ENTRY_ID,
                                 24 * (ifcount+1))  # sizeof(IPAddrEntry)
              ipentries.scan(/.{24}/) do |ipentry|
                ipaddr, index = ipentry.unpack('VV')
                if ifitem = iflist.assoc(index)
                  ifitem << ipaddr
                end
              end
            end
          end
        end
        iflist
      end
    end
  __EOS__
end
#====================================================================
  end
end
