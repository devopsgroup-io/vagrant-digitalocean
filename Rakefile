require "bundler/gem_tasks"

task "test" do
  result = system("bash test/test.sh")

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
