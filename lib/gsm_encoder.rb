# frozen_string_literal: true
# Stealing from Twitter's Java implementation
# https://github.com/twitter/cloudhopper-commons-charset/blob/master/src/main/java/com/cloudhopper/commons/charset/GSMCharset.java

#
# This class encodes and decodes Ruby Strings to and from the SMS default
# alphabet. It also supports the default extension table. The default alphabet
# and it's extension table is defined in GSM 03.38.
module GSMEncoder
  # GSM to UTF8 tables
  nl = 10.chr
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

  GSM_EXT_TABLE = [
    nil, nil, nil, nil, nil, nil, nil, nil, nil, 'ç', nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, '^', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, '{', '}', nil, nil, nil, nil, nil, bs,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, '[', '~', ']', nil,
    '|', 'Á', nil, nil, nil, nil, nil, nil, nil, 'Í', nil, nil, nil, nil, nil, 'Ó',
    nil, nil, nil, nil, nil, 'Ú', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, 'á', nil, nil, nil, '€', nil, nil, nil, 'í', nil, nil, nil, nil, nil, 'ó',
    nil, nil, nil, nil, nil, 'ú', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
  ].freeze

  # build UTF8 to GSM tables
  UTF8_ARRAY_SIZE = 128
  UTF8_ARRAY = []
  UTF8_HASH = {}
  [
    [ GSM_TABLE, nil ],
    [ GSM_EXT_TABLE, GSM_ESCAPE ]
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
        UTF8_ARRAY[key] = value
      else
        UTF8_HASH[key] = value
      end
    end
  end
  UTF8_ARRAY.freeze
  UTF8_ARRAY.each(&:freeze)
  UTF8_HASH.freeze
  UTF8_HASH.each_value(&:freeze)

  REGEXP = /\A[#{Regexp.escape((GSM_TABLE + GSM_EXT_TABLE).compact.join)}]*\Z/

  # Verifies that the given string can be encoded in GSM 03.38
  def can_encode?(str)
    !str || !!(REGEXP =~ str)
  end

  # Encode given UTF-8 string to GSM 03.38
  def encode(string, replacement = "?")
    return nil if string.nil?
    replacement = replacement == "?" ? 63 : encode(replacement)
    buffer = String.new(encoding: "binary")
    string.each_codepoint do |codepoint|
      if codepoint < UTF8_ARRAY_SIZE
        buffer << (UTF8_ARRAY[codepoint] || replacement)
      else
        buffer << (UTF8_HASH[codepoint] || replacement)
      end
    end
    buffer
  end

  # Encode given GSM 03.38 string to UTF-8
  def decode(string, replacement = "?")
    return nil if string.nil?
    buffer = +""
    escaped = false
    string.each_byte do |c|
      if c == GSM_ESCAPE
        escaped = true
      elsif escaped
        buffer << GSM_EXT_TABLE[c] || replacement
        escaped = false
      else
        buffer << GSM_TABLE[c] || replacement
      end
    end
    buffer
  end

  module_function :can_encode?
  module_function :encode
  module_function :decode

end
