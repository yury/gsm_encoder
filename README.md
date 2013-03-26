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
