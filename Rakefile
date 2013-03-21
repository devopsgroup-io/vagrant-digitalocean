require "bundler/gem_tasks"

namespace "dev" do
  task "build" do
    system "bash bin/build.sh"
  end
end

task "test" do
  result = system("bash bin/test_run.sh")

  if result
    puts "Success!"
  else
    puts "Failure!"
    exit 1
  end
end

def env
  ['DO_CLIENT_ID', 'DO_API_KEY', 'VAGRANT_LOG'].inject("") do |acc, key|
    acc += "#{key}=#{ENV[key] || 'error'} "
  end
end
