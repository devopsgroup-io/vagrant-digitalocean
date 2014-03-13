log 'Testing 1 2 3 with chef provisioner!'

directory "/tmp/folder" do
  owner "root"
  group "root"
  mode 0777
  action :create
end

file "/tmp/folder/file_from_chef" do
  mode "0666"
  content "Some text contents"
  action :create
end
