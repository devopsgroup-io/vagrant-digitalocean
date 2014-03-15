require 'bundler/gem_helper'
require 'rspec/core/rake_task'

namespace :gem do
  Bundler::GemHelper.install_tasks
end

RSpec::Core::RakeTask.new(:spec)

task :default => :test

desc "Run the spec and integration tests (default)"
task :test => [:spec, 'test:integration']

namespace :test do
  desc "Integration tests - creates and destroys droplets"
  task :integration do
    result = sh 'bash test/test.sh'

    if result
      puts 'Success!'
    else
      puts 'Failure!'
      exit 1
    end
  end
end

def env
  ['DO_CLIENT_ID', 'DO_API_KEY', 'VAGRANT_LOG'].inject('') do |acc, key|
    acc += "#{key}=#{ENV[key] || 'error'} "
  end
end
