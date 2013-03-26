#!/usr/bin/env ruby
#encoding: utf-8

require 'benchmark'

require File.expand_path(File.dirname(__FILE__) + '/../lib/gsm_encoder')


text_to_encode = "!\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà^{}\[~]|€"
n = 5000

Benchmark.bmbm do |x|
  x.report("encode:") { n.times  { GSMEncoder.encode(text_to_encode) } }
  x.report("can_encode?:") { n.times  { GSMEncoder.can_encode?(text_to_encode) } }
end


