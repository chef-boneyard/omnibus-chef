# terrible hack because the omnibus build fails as vagrant.
%w{/opt/chef /opt/rubies}.each do |dir|
  execute "chown -R vagrant:vagrant #{dir}" do
    only_if { ::Dir.exists?(dir) }
  end
end

# git "/home/vagrant/chef" do
#   repository "git://github.com/opscode/chef.git"
#   depth 1
#   user "vagrant"
# end
