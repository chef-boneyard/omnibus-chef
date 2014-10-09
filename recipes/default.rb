# terrible hack because the omnibus-chef build tries to write into /opt/rubies.
%w{/opt/chef /opt/rubies}.each do |dir|
  execute "chown -R vagrant:vagrant #{dir}" do
    only_if { ::Dir.exists?(dir) }
  end
end

BASE    = "/home/vagrant"
PKG_DIR = "#{BASE}/omnibus-chef/pkg"
SRC_DIR = "#{BASE}/chef"

do the omnibus-chef build from /home/vagrant/chef instead of github.
bash "omnibus-chef package build from dev checkout" do
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

require 'json'
json_file = Dir.glob("#{PKG_DIR}/*.json")[0]
pkg_file = JSON.load(File.open(json_file).read)["basename"]

# install the built package.
bash "install via package file #{pkg_file}" do
  code "sudo dpkg -i #{PKG_DIR}/#{pkg_file}"

  # not_if installed package is same as this file's package.
end

# make sure /opt/chef etc. are first in PATH.

# run the specs in /home/vagrant/chef.