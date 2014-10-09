
# terrible hack because the omnibus-chef build tries to write into /opt/rubies.
%w{/opt/chef /opt/rubies}.each do |dir|
  execute "chown -R vagrant #{dir}" do
    only_if { ::Dir.exists?(dir) }
  end
end

BASE    = "/home/vagrant"
OMNICHEF_DIR = "#{BASE}/omnibus-chef"
PKG_DIR = "#{OMNICHEF_DIR}/pkg"
SRC_DIR = "#{BASE}/chef"

bash "build-omnibus-chef" do
  user "vagrant"
  group "vagrant"
  cwd OMNICHEF_DIR

  ENV['PATH'] = "/usr/local/bin:/home/vagrant/.gem/ruby/2.1.2/bin:/opt/rubies/ruby-2.1.2/lib/ruby/gems/2.1.0/bin:/opt/rubies/ruby-2.1.2/bin:/opt/chef/embedded/bin:/opt/chef/embedded/bin:#{ENV['PATH']}"
  ENV['USE_LOCAL_CHEF'] ||= "/home/vagrant/chef"

  # these first 2 steps should be doable with resources.
  code <<-EOS
  env > lastrun-env.sh

  bundle install
  bundle exec omnibus clean chef --purge
  bundle exec omnibus build chef --config omnibus-client-test.rb
  EOS
end

# require 'json'
# json_file = Dir.glob("#{PKG_DIR}/*.json")[0]
# pkg_file = JSON.load(File.open(json_file).read)["basename"]

# # install the built package.
# bash "install via package file #{pkg_file}" do
#   code "sudo dpkg -i #{PKG_DIR}/#{pkg_file}"

#   # not_if installed package is same as this file's package.
# end

# make sure /opt/chef etc. are first in PATH.

# run the specs in /home/vagrant/chef.