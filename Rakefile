#!/usr/bin/env rake
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
require 'rake'

Dir[File.expand_path('./lib/tasks/*.rake')].each{|f| load f }
