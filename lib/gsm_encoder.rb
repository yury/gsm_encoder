# frozen_string_literal: true
# Stealing from Twitter's Java implementation
# https://github.com/twitter/cloudhopper-commons-charset/blob/master/src/main/java/com/cloudhopper/commons/charset/GSMCharset.java

#
# This class encodes and decodes Ruby Strings to and from the SMS default
# alphabet. It also supports an extension table. The default alphabet and
# its extension tables are defined in GSM 03.38 (3GPP TS 23.038).
#
# Which extension table is used can be configured:
#
#   GSMEncoder.extension_table = :standard # GSM 03.38 default extension table only
#   GSMEncoder.extension_table = :spanish  # Spanish single shift table (the default)
#
# or per call:
#
#   GSMEncoder.encode("¿Qué?", extension_table: :standard)
module GSMEncoder
  # GSM to UTF8 tables
  nl = 10.chr
  ff = 12.chr
  cr = 13.chr
  bs = 92.chr

  GSM_ESCAPE = 0x1b

  GSM_TABLE = [
    '@', '£', '$', '¥', 'è', 'é', 'ù', 'ì',
    'ò', 'Ç',  nl, 'Ø', 'ø', cr , 'Å', 'å',
    'Δ', '_', 'Φ', 'Γ', 'Λ', 'Ω', 'Π', 'Ψ',
    'Σ', 'Θ', 'Ξ', nil, 'Æ', 'æ', 'ß', 'É', # 0x1b is the escape
    " ", '!', '"', '#', '¤', '%', '&', "'",
    '(', ')', '*', '+', ',', '-', '.', '/',
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', ':', ';', '<', '=', '>', '?',
    '¡', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
    'X', 'Y', 'Z', 'Ä', 'Ö', 'Ñ', 'Ü', '§',
    '¿', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
    'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
    'x', 'y', 'z', 'ä', 'ö', 'ñ', 'ü', 'à',
  ].freeze

  # GSM 03.38 default extension table. This is the only extension table a
  # handset (or SMS provider) uses unless the message explicitly selects a
  # national language shift table in its header.
  STANDARD_EXT_TABLE = [
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  ff, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, '^', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, '{', '}', nil, nil, nil, nil, nil, bs,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, '[', '~', ']', nil,
    '|', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, '€', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
  ].freeze

  # Spanish national language single shift table (3GPP TS 23.038 A.2.2).
  # Only decoded correctly when the message header selects the Spanish shift.
  SPANISH_EXT_TABLE = [
    nil, nil, nil, nil, nil, nil, nil, nil, nil, 'ç',  ff, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, '^', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, '{', '}', nil, nil, nil, nil, nil, bs,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, '[', '~', ']', nil,
    '|', 'Á', nil, nil, nil, nil, nil, nil, nil, 'Í', nil, nil, nil, nil, nil, 'Ó',
    nil, nil, nil, nil, nil, 'Ú', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, 'á', nil, nil, nil, '€', nil, nil, nil, 'í', nil, nil, nil, nil, nil, 'ó',
    nil, nil, nil, nil, nil, 'ú', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
  ].freeze

  # kept for backwards compatibility, this was the only extension table before
  GSM_EXT_TABLE = SPANISH_EXT_TABLE

  UTF8_ARRAY_SIZE = 128

  # UTF8 to GSM lookups for one extension table
  Charset = Struct.new(:ext_table, :utf8_array, :utf8_hash, :regexp)

  def self.build_charset(ext_table)
    unless ext_table.is_a?(Array) && ext_table.size <= UTF8_ARRAY_SIZE
      raise ArgumentError, "extension table must be an Array of at most #{UTF8_ARRAY_SIZE} entries"
    end

    utf8_array = []
    utf8_hash = {}
    [
      [ GSM_TABLE, nil ],
      [ ext_table, GSM_ESCAPE ]
    ].each do |table, prefix|
      table.each.with_index do |char, index|
        next if char.nil?
        # build GSM value
        if prefix
          value = +''.encode('binary')
          value << prefix
          value << index
        else
          value = index
        end
        # store GSM value
        key = char.codepoints.first
        if key < UTF8_ARRAY_SIZE
          utf8_array[key] = value
        else
          utf8_hash[key] = value
        end
      end
    end
    utf8_array.each(&:freeze)
    utf8_hash.each_value(&:freeze)

    regexp = /\A[#{Regexp.escape((GSM_TABLE + ext_table).compact.join)}]*\Z/

    Charset.new(ext_table.dup.freeze, utf8_array.freeze, utf8_hash.freeze, regexp).freeze
  end

  @charsets = {
    standard: build_charset(STANDARD_EXT_TABLE),
    spanish: build_charset(SPANISH_EXT_TABLE)
  }

  # kept for backwards compatibility
  UTF8_ARRAY = @charsets[:spanish].utf8_array
  UTF8_HASH = @charsets[:spanish].utf8_hash
  REGEXP = @charsets[:spanish].regexp

  @extension_table = :spanish

  class << self
    # The extension table used when a call doesn't pass one (:spanish by default)
    attr_reader :extension_table

    def extension_table=(name)
      charset(name) # validate
      @extension_table = name
    end

    # Register a custom extension table (an Array indexed by GSM code, nil for unused codes)
    #
    #   GSMEncoder.register_extension_table(:mine, table)
    #   GSMEncoder.extension_table = :mine
    def register_extension_table(name, table)
      @charsets = @charsets.merge(name.to_sym => build_charset(table)).freeze
    end

    def extension_tables
      @charsets.keys
    end

    def charset(name = nil)
      name ||= @extension_table
      @charsets.fetch(name.to_sym) do
        raise ArgumentError, "unknown extension table #{name.inspect}, expected one of #{@charsets.keys.inspect}"
      end
    end
  end

  # Verifies that the given string can be encoded in GSM 03.38
  def can_encode?(str, extension_table: nil)
    !str || !!(GSMEncoder.charset(extension_table).regexp =~ str)
  end

  # Encode given UTF-8 string to GSM 03.38
  def encode(string, replacement = "?", extension_table: nil)
    return nil if string.nil?
    charset = GSMEncoder.charset(extension_table)
    utf8_array = charset.utf8_array
    utf8_hash = charset.utf8_hash
    replacement = replacement == "?" ? 63 : encode(replacement, extension_table: extension_table)
    buffer = String.new(encoding: "binary")
    string.each_codepoint do |codepoint|
      if codepoint < UTF8_ARRAY_SIZE
        buffer << (utf8_array[codepoint] || replacement)
      else
        buffer << (utf8_hash[codepoint] || replacement)
      end
    end
    buffer
  end

  # Encode given GSM 03.38 string to UTF-8
  def decode(string, replacement = "?", extension_table: nil)
    return nil if string.nil?
    ext_table = GSMEncoder.charset(extension_table).ext_table
    buffer = +""
    escaped = false
    string.each_byte do |c|
      if c == GSM_ESCAPE
        escaped = true
      elsif escaped
        buffer << (ext_table[c] || replacement)
        escaped = false
      else
        buffer << (GSM_TABLE[c] || replacement)
      end
    end
    buffer
  end

  module_function :can_encode?
  module_function :encode
  module_function :decode

end
