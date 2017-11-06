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

  def test_custom_replacements_for_unsupported_chars
    assert_equal '      ', encode('привет', replace_char: ' ')
    assert_equal ' ', encode('`', replace_char: ' ')

    # unsupported Spanish characters
    assert_equal ' ', encode('ï', replace_char: ' ')

    # unsupported French characters
    assert_equal ' ',  encode('À', replace_char: ' ')
    assert_equal '  ', encode('Ââ', replace_char: ' ')
    assert_equal ' ',  encode('È', replace_char: ' ')
    assert_equal '  ', encode('Êê', replace_char: ' ')
    assert_equal '  ', encode('Ëë', replace_char: ' ')
    assert_equal '  ', encode('Îî', replace_char: ' ')
    assert_equal '  ', encode('Ïï', replace_char: ' ')
    assert_equal '  ', encode('Ôô', replace_char: ' ')
    assert_equal '  ', encode('Œœ', replace_char: ' ')
    assert_equal ' ',  encode('Ù', replace_char: ' ')
    assert_equal '  ', encode('Ûû', replace_char: ' ')
    assert_equal '  ', encode('Ÿÿ', replace_char: ' ')

    # unsupported Czech characters
    assert_equal '                    ', replace_char: encode('ČčĎďĚěŇňŘřŠšŤťŮůÝýŽž', ' ')
  end

  def test_custom_replacement_using_unsupported_char
    assert_equal '??????', encode('привет', 'ï')
  end

  def test_replacements_for_unsupported_chars
    assert_equal '??????', encode('привет')
    assert_equal '?', encode('`')

    # unsupported Spanish characters
    assert_equal '?', encode('ï')

    # unsupported French characters
    assert_equal '?',  encode('À')
    assert_equal '??', encode('Ââ')
    assert_equal '?',  encode('È')
    assert_equal '??', encode('Êê')
    assert_equal '??', encode('Ëë')
    assert_equal '??', encode('Îî')
    assert_equal '??', encode('Ïï')
    assert_equal '??', encode('Ôô')
    assert_equal '??', encode('Œœ')
    assert_equal '?',  encode('Ù')
    assert_equal '??', encode('Ûû')
    assert_equal '??', encode('Ÿÿ')

    # unsupported Czech characters
    assert_equal '????????????????????', encode('ČčĎďĚěŇňŘřŠšŤťŮůÝýŽž')
  end

  def test_can_encode?
    assert can_encode?(nil)
    assert can_encode?('')
    assert can_encode?('?')
    assert can_encode?("1234567890qwertyuiop[]asdfghjkl;'zxcvbnm,./?{}() \"+-_!@#$\%^&*|\\")

    # test encoding for Spanish characters
    # diaeresis over i (vïuda) is not supported and appears to be for poetic use only
    assert can_encode?('á é í ó ú pingüino ¡Ó señor! ¿A dónde vas?')
    assert can_encode?('Á É Í Ó Ú PINGÜINO')

    # test encoding for certain French characters
    assert can_encode?('à Ææ Çç Éé è ù Üü')

    # test encoding for certain Czech characters
    assert can_encode?(' á É é Í í Ó ó Ú ú')

    # found this on a random website
    assert can_encode?(' £$¥èéùìòØøÅå_FG????ST?ÆæßÉ')
    assert can_encode?(" !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà^{}\[~]|€")

    # should be able to encode line feed & carriage returns
    assert can_encode?("this is line one
this is line two")
    assert can_encode?("this is line one\rthis is line two")
  end

  def test_can_encode_false
    assert !can_encode?('`')
    assert !can_encode?('вот так вот')
    assert !can_encode?("\t hello")

    # non-allowed Spanish characters
    assert !can_encode?('ï')

    #non-allowed French characters
    'ÀÂâÈÊêËëÎîÏïÔôŒœÙÛûŸÿ'.each_char do |char|
      assert !can_encode?(char)
    end

    # non-allowed Czech characters
    'ČčĎďĚěŇňŘřŠšŤťŮůÝýŽž'.each_char do |char|
      assert !can_encode?(char)
    end
  end

  def test_encoding
    alphabet = ('a'..'z').to_a.join
    numbers = '01234567890'

    cases = [nil, '', ' ', 'hello', '@dcab', '^&*', '€ euro', alphabet, alphabet.upcase, numbers,
            '@->--', '<3', ':)', '>.<', '%', 'o_O', 'á é í ó ú pingüino ¡Ó señor! ¿A dónde vas?',
            'Á É Í Ó Ú PINGÜINO', 'à Ææ Çç Éé è ù Üü', 'Á á É é Í í Ó ó Ú ú', '£$¥èéùìòØøÅå_FG????ST?ÆæßÉ',
            "!\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà^{}\[~]|€"]

    cases.each do |c|
      assert_equal c, decode(encode(c)), "Failed to decode encoded '#{c}'"
    end
  end

end
