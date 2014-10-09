# terrible hack because the omnibus-chef build tries to write into /opt/rubies.
%w{ /opt/chef /opt/rubies }.each do |dir|
  execute "chown -R vagrant:vagrant #{dir}" do
    only_if { ::Dir.exists?(dir) }
  end
end

BASE    = "/home/vagrant"
PKG_DIR = "#{BASE}/omnibus-chef/pkg"
SRC_DIR = "#{BASE}/chef"

%w{omnibus-chef}.each do |omnigem|
  execute "#{omnigem}-bundle-install" do
    cwd "#{BASE}/#{omnigem}"
    command "bundle install"
    action :run
  end
end

# directory PKG_DIR do
#   action [:delete, :create]
#   recursive true
# end

execute "build-chef-package" do
  # user "vagrant"
  # group "vagrant"
  cwd "#{BASE}/omnibus-chef"

  # these first 2 steps should be doable with resources.
  command "bundle exec omnibus build chef -l internal --config omnibus-client-test.rb --override base_dir:local"
  action :run
end

ruby_block "store-package-info" do
  block do
    require 'json'
    globbed = Dir.glob("#{PKG_DIR}/*.json")

    if globbed.size > 0
      json_file = "#{PKG_DIR}/" + globbed[0]
      pkg_info = JSON.load(File.open(json_file).read)
      pkg_info["package_fullpath"] = "#{PKG_DIR}/#{pkg_info["basename"]}"
      node['chef-client-test']['pkg_info'] = pkg_info
    else
      {}
    end
  end
  action :run
end

# log "node-info" do
#   level :info
#   message node.inspect
# end


package "chef" do
  # notifies :run, "bash[build-chef-package]", :immediately
  # notifies :run, "ruby_block[store-package-info]", :immediately
  action :upgrade
  version lazy { node['chef-client-test']['pkg_info']["version"] }
  source  lazy { node['chef-client-test']['pkg_info']["package_fullpath"] }
  # source "cheese"
end


# run the specs in /home/vagrant/chef.
# %w{ unit functional integration }.each do |spec_type|
%w{  }.each do |spec_type|
  bash "run the #{spec_type} specs in #{SRC_DIR}/spec/#{spec_type}" do
    user "vagrant"
    group "vagrant"
    cwd SRC_DIR
    code <<-EOS
    bundle install
    bundle exec rspec spec/#{spec_type}
    EOS
  end
end