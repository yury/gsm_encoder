#encoding: utf-8

lib = File.expand_path('../lib/', __FILE__)
  
Gem::Specification.new do |s|
  s.name        = "gsm_encoder"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Yury Korolev"]
  s.email       = ["yury.korolev@gmail.com"]
  s.homepage    = "http://github.com/yury/gsm_encoder"
  s.summary     = "ruby GSM 03.38 encoder/decoder"
  s.description = "GSMEncoder encodes and decodes Ruby Strings to and from the SMS default alphabet. It also supports the default extension table. The default alphabet and it's extension table is defined in GSM 03.38"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{lib}/**/*") + %w(README.md)
  s.require_path = 'lib'
end