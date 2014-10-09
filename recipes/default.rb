# terrible hack because the omnibus-chef build tries to write into /opt/rubies.
%w{ /opt/chef /opt/rubies }.each do |dir|
  execute "chown -R vagrant:vagrant #{dir}" do
    only_if { ::Dir.exists?(dir) }
  end
end

BASE    = "/home/vagrant"
PKG_DIR = "#{BASE}/omnibus-chef/pkg"
SRC_DIR = "#{BASE}/chef"

bash "build-chef-package" do
  user "vagrant"
  group "vagrant"
  cwd "#{BASE}/omnibus-chef"

  # these first 2 steps should be doable with resources.
  code <<-EOS
  bundle install
  echo "Wiping pkg/ directory"
  rm pkg/*
  bundle exec omnibus build chef --config omnibus-client-test.rb
  EOS
end

ruby_block "store-package-info" do
  block do
    require 'json'
    globbed = Dir.glob("#{PKG_DIR}/*.json")

    pkg_info = if globbed.size > 0
      json_file = "#{PKG_DIR}/" + globbed[0]
      JSON.load(File.open(json_file).read)
    else
      {}
    end

    pkg_info["package_fullpath"] = "#{PKG_DIR}/#{pkg_info["basename"]}"
    node['chef-client-test']['pkg_info'] = pkg_info
  end
  action :run
end

# # install the built package.
# bash "install via package file #{pkg_file}" do
#   code "sudo dpkg -i #{PKG_DIR}/#{pkg_file}"

#   # not_if installed package is same as this file's package.
# end

package "chef" do
  notifies :run, "ruby_block[store-package-info]", :immediately
  action :upgrade
  # version node['chef-client-test']['pkg_info']["version"]
  source node['chef-client-test']['pkg_info']["package_fullpath"]
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