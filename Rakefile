require 'rubygems'
require 'rake'
require 'cucumber'
require 'cucumber/rake/task'
require 'bundler'

Bundler::GemHelper.install_tasks

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress"
end

task :default => :features
