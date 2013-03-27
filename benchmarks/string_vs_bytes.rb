#!/usr/bin/env ruby
#encoding: utf-8

require 'benchmark'

require File.expand_path(File.dirname(__FILE__) + '/../lib/gsm_encoder')

def byte_can_encode(str)
  str.each_char do |c|
    # simple range checks for most common characters (' '..'_') or ('a'..'~')
    b = c.getbyte(0)
    unless b >= 0x20 && b <= 0x5F || b >= 0x61 && b <= 0x7E
      return false
    end
  end
  true
end

def ord_can_encode(str)
  str.each_char do |c|
    # simple range checks for most common characters (' '..'_') or ('a'..'~')
    o = c.ord
    unless o >= 0x20 && o <= 0x5F || o >= 0x61 && o <= 0x7E
      return false
    end
  end
  true
end


def string_can_encode(str)
  str.each_char do |c|
    # simple range checks for most common characters (' '..'_') or ('a'..'~')
    unless c >= ' ' && c <= '_' || c >= 'a' && c <= '~'
      return false
    end
  end
  true
end

def regex_can_encode(str)
  str =~ /^[A-Za-z0-9]+$/
end

Benchmark.bmbm do |r|
  N = 200_000
  CHARS_ARRAY = (' '..'_').to_a
  STRING = CHARS_ARRAY.to_a.join('')
  POSITIVE = STRING
  NEGATIVE = POSITIVE + 'привет'
  COMMON = "this is a common phrase using just letters and numbers like 57 and 38"

  r.report("string positive") do
    N.times { string_can_encode(POSITIVE)}
  end

  r.report("byte   positive") do
    N.times { byte_can_encode(POSITIVE) }
  end

  r.report("ord    positive") do
    N.times { ord_can_encode(POSITIVE) }
  end

  r.report("regex  positive") do
    N.times { regex_can_encode(POSITIVE) }
  end

  r.report("string negative") do
    N.times { string_can_encode(NEGATIVE)}
  end

  r.report("ord    negative") do
    N.times { ord_can_encode(NEGATIVE) }
  end

  r.report("regex  negative") do
    N.times { regex_can_encode(NEGATIVE) }
  end

  r.report("string include?") do
    N.times { STRING.include?('A') }
  end

  r.report("string index   ") do
    N.times { STRING.index('A') }
  end

  r.report("array  include?") do
    N.times { CHARS_ARRAY.include?('A') }
  end

  r.report("array  index   ") do
    N.times { CHARS_ARRAY.index('A') }
  end

  r.report("string common phrase") do
    N.times { string_can_encode(COMMON)}
  end

  r.report("ord    common phrase") do
    N.times { ord_can_encode(COMMON)}
  end

  r.report("byte   common phrase") do
    N.times { byte_can_encode(COMMON)}
  end

  r.report("regex  common phrase") do
    N.times { regex_can_encode(COMMON)}
  end

end
