GSMEncoder encodes and decodes Ruby Strings to and from the SMS default
alphabet. It also supports the default extension table. The default alphabet
and it's extension table is defined in GSM 03.38

This is port of Twitter's Java [implementation](https://github.com/twitter/cloudhopper-commons-charset/blob/master/src/main/java/com/cloudhopper/commons/charset/GSMCharset.java)

## Installation

__NOTE: ruby >= 1.9.2 is required__

    gem install gsm_encoder

## Usage

    require 'gsm_encoder'
   
    # encoding
    GSMEncoder.encode 'hello @ world' # => binary string
   
    # decoding
    GSMEncoder.decode(GSMEncoder.encode('hi')) # => 'hi'
   
    # can encode?
    GSMEncoder.can_encode?('`') # => false
    
    # replaces unsupported chars with '?'
    GSMEncoder.encode('`') # => '?'

    # replaces unsupported chars with a provided value ' '
    GSMEncoder.encode('`', ' ') # => ' '

## Extension tables

Characters like `{ } [ ] ~ \ | € ^` are sent as an escape plus a code from an
extension table. Two tables are built in:

- `:spanish` (the default) - the Spanish national language single shift table.
  It adds `ç Á Í Ó Ú á í ó ú` on top of the standard table.
- `:standard` - the GSM 03.38 default extension table.

The Spanish characters are only valid GSM 7-bit when the message header selects
the Spanish shift table. Most SMS providers (Twilio, Telnyx, Plivo, ...) don't,
so a message containing them is sent as UCS-2 instead. That cuts a segment from
160 characters to 70. Use `:standard` if you rely on `can_encode?` or
`encode` to keep messages in GSM 7-bit:

    # for every call
    GSMEncoder.extension_table = :standard

    # or for one call
    GSMEncoder.can_encode?('á', extension_table: :standard) # => false
    GSMEncoder.encode('á', extension_table: :standard) # => '?'
    GSMEncoder.decode(bytes, extension_table: :standard)

You can also register your own table, an Array indexed by GSM code with `nil`
for unused codes:

    GSMEncoder.register_extension_table(:mine, table)
    GSMEncoder.extension_table = :mine

## Updates

### 0.1.1

Added support for Spanish shift

### 0.1.2

Fixed bug when encoding line feed & carriage return

### 0.1.3

Adds the ability to provide the character used when encoding
unsupported strings

### 0.1.4

Code cleanup and speedup

### 0.1.5

Even faster. About 4 times. Many thanks to @dlarrabee

### 0.1.7

Even faster! Many thanks to @ThomasSevestre

### 0.1.8

- Configurable extension table (`:standard` or `:spanish`), defaults to `:spanish`
- Adds form feed to the extension tables
- `decode` returns the replacement for unknown codes instead of raising `TypeError`

