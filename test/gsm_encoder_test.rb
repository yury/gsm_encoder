#!/usr/bin/env ruby
#encoding: utf-8

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/../lib/gsm_encoder')

class GSMEncoderTest < Test::Unit::TestCase
  include GSMEncoder

  def test_nil_and_empty
    assert_nil encode(nil)
    assert_equal '', encode('')
  end

  def test_replacements_for_unsupported_chars
    assert_equal '??????', encode('привет')
    assert_equal '?', encode('`')    
  end

  def test_can_encode?
    assert can_encode?(nil)
    assert can_encode?('')
    assert can_encode?("?")
    assert can_encode?("1234567890qwertyuiop[]asdfghjkl;'zxcvbnm,./?{}() \"+-_!@#$\%^&*|\\")
    assert !can_encode?("`")
    assert !can_encode?("вот так вот")
  end

  def test_encoding
    alphabet = ('a'..'z').to_a.join
    numbers = '01234567890'
    
    cases = [nil, "", " ", "hello", "@dcab", "^&*", "€ euro", alphabet, alphabet.upcase, numbers,
            "@->--", "<3", ":)", ">.<", "%", "o_O"]
    
    cases.each do |c|
      assert_equal c, decode(encode(c)), "Failed to decode encoded '#{c}'"
    end
  end

end