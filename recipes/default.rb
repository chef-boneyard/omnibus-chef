%w{chef rubies}.each do |opt_dir|
  directory "/opt/#{opt_dir} is vagrant:vagrant" do
    path "/opt/#{opt_dir}"
    owner "vagrant"
    group "vagrant"
    recursive true
  end
end

# git "/home/vagrant/chef" do
#   repository "git://github.com/opscode/chef.git"
#   depth 1
#   user "vagrant"
# end
