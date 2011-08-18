# Stealing from Twitter's Java implementation
# https://github.com/twitter/cloudhopper-commons-charset/blob/master/src/main/java/com/cloudhopper/commons/charset/GSMCharset.java

#
# This class encodes and decodes Ruby Strings to and from the SMS default
# alphabet. It also supports the default extension table. The default alphabet
# and it's extension table is defined in GSM 03.38.
module GSMEncoder
  
  EXTENDED_ESCAPE = 0x1b
  
  CHAR_TABLE = [
    '@', "\u00a3", '$', "\u00a5", "\u00e8", "\u00e9", "\u00f9", "\u00ec",
    "\u00f2", "\u00c7", '\n', "\u00d8", "\u00f8", '\r', "\u00c5", "\u00e5",
    "\u0394", '_', "\u03a6", "\u0393", "\u039b", "\u03a9", "\u03a0", "\u03a8",
    "\u03a3", "\u0398", "\u039e", " ", "\u00c6", "\u00e6", "\u00df", "\u00c9",
    " ", '!', '"', '#', "\u00a4", '%', '&', "'",
    '(', ')', '*', '+', ',', '-', '.', '/',
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', ':', ';', '<', '=', '>', '?',
    "\u00a1", 'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
    'X', 'Y', 'Z', "\u00c4", "\u00d6", "\u00d1", "\u00dc", "\u00a7",
    "\u00bf", 'a', 'b', 'c', 'd', 'e', 'f', 'g',
    'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
    'x', 'y', 'z', "\u00e4", "\u00f6", "\u00f1", "\u00fc", "\u00e0",
  ]
  

  # Extended character table. Characters in this table are accessed by the
  # 'escape' character in the base table. It is important that none of the
  # 'inactive' characters ever be matchable with a valid base-table
  # character as this breaks the encoding loop.
  EXT_CHAR_TABLE = [
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, "^", 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    '{', '}', 0, 0, 0, 0, 0, "\\",
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, '[', '~', ']', 0,
    '|', 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, "\u20ac", 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
  ]

  # Verifies that this charset can represent every character in the Ruby
  # String.
  # @param str The String to verfiy
  # @return True if the charset can represent every character in the Ruby
  #   String, otherwise false.
  def can_encode? str
    return true if !str

    str.chars.each do |c|
      # a very easy check a-z, A-Z, and 0-9 are always valid
      if c >= ?A && c <= ?Z || c >= ?a && c <= ?z || c >= ?0 && c <= ?9
        next
      else
        # search both charmaps (if char is in either, we're good!)
        found = false
        j = 0
        while j < CHAR_TABLE.length
          if c == CHAR_TABLE[j] || c == EXT_CHAR_TABLE[j]
            found = true
            break
          end
          j += 1
        end
        # if we searched both charmaps and didn't find it, then its bad
        return false if !found
      end
    end  
    
    true
  end
    
  def encode str 
    return nil if !str

    buffer = ''.encode('binary')

    begin
      str.chars.each do |c|
        search = 0
        while search < CHAR_TABLE.length
          if search == EXTENDED_ESCAPE
            search += 1
            next
          end
          if c == CHAR_TABLE[search]
            buffer << search
            break
          end
          if c == EXT_CHAR_TABLE[search]
            buffer << EXTENDED_ESCAPE
            buffer << search
            break
          end
          search += 1
        end
        if search == CHAR_TABLE.length
          buffer << '?'
        end
      end
    rescue 
      # TODO: ?
    end
    buffer
  end

  def decode bstring
    return nil if !bstring
    
    buffer = ''.encode('utf-8')
    
    table = CHAR_TABLE
    bstring.bytes.each do |c|
      code = c & 0x000000ff
      if code == EXTENDED_ESCAPE
        # take next char from extension table
        table = EXT_CHAR_TABLE
      else
        buffer << (code >= table.length ? '?' : table[code])
        # go back to the default table
        table = CHAR_TABLE 
      end
    end
    buffer
  end

  module_function :can_encode?
  module_function :encode  
  module_function :decode

end