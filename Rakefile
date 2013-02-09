# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "lessneglect"
  gem.homepage = "http://github.com/lessneglect/lessneglect-ruby"
  gem.license = "MIT"
  gem.summary = "LessNeglect client API"
  gem.description = "API library to allow you to connect and submit messages and actions to your LessNeglect project account"
  gem.email = "gooley@lessneglect.com"
  gem.authors = ["Christopher Gooley"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
require File.expand_path("../lib/lessneglect/version", __FILE__)
Rake::RDocTask.new do |rdoc|
  version = LessNeglect::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "lessneglect #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
