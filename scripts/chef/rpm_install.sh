# cargo culted from OpsCode's guide at http://wiki.opscode.com/display/chef/Installing+Chef+Client+on+CentOS
# skip if chef-solo is present
if (which chef-solo); then exit 0; fi

# add the repo for ruby and other deps
rpm -Uvh http://rbel.frameos.org/rbel6

# install the pre-reqs
yum install -y ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow gcc gcc-c++ automake autoconf make curl dmidecode

# install rubygems
if ! (which gem); then
  cd /tmp
  curl -O http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
  tar zxf rubygems-1.8.10.tgz
  cd rubygems-1.8.10
  ruby setup.rb --no-format-executable
fi

# install chef via rubygems
gem install chef --no-ri --no-rdoc
