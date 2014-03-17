source 'https://rubygems.org'

ruby '2.0.0'

group :development do
  gem "vagrant", :git => "https://github.com/mitchellh/vagrant.git"
  gem 'rake'
end

group :test do
  gem 'rspec'
end

group :plugins do
  #gem "my-vagrant-plugin", path: "."
  gemspec
  gem 'vagrant-omnibus' if ENV['EXCLUDE'].to_s !~ /chef/
end

