
# terrible hack because the omnibus-chef build tries to write into /opt/rubies.
%w{/opt/chef /opt/rubies}.each do |dir|
  execute "chown -R vagrant #{dir}" do
    only_if { ::Dir.exists?(dir) }
  end
end

BASE         = "/home/vagrant"
OMNICHEF_DIR = "#{BASE}/omnibus-chef"
PKG_DIR      = "#{OMNICHEF_DIR}/pkg"
SRC_DIR      = "#{BASE}/chef"
ENV['PATH']  = "/usr/local/bin:/home/vagrant/.gem/ruby/2.1.2/bin:/opt/rubies/ruby-2.1.2/lib/ruby/gems/2.1.0/bin:/opt/rubies/ruby-2.1.2/bin:/opt/chef/embedded/bin:/opt/chef/embedded/bin:#{ENV['PATH']}"

bash "build-omnibus-chef" do
  user "vagrant"
  group "vagrant"
  cwd OMNICHEF_DIR

  ENV['USE_LOCAL_CHEF'] ||= "/home/vagrant/chef"

  # these first 2 steps should be doable with resources.
  code <<-EOS
  env > lastrun-env.sh

  bundle install
  bundle exec omnibus clean chef --purge
#  bundle exec omnibus build chef --config omnibus-client-test.rb
  EOS

  not_if { File.exists?("nobuild") || ENV['NOBUILD'] }
end

ruby_block "store-package-info" do
  block do
    globbed = Dir.glob("#{PKG_DIR}/*.json")

    if globbed.size > 0
      # pick the latest package file.
      latest_json_file = globbed.sort.reverse[0]
      pkg_info = JSON.load(File.open(latest_json_file).read)
      pkg_info["package_fullpath"] = "#{PKG_DIR}/#{pkg_info["basename"]}"

      (node.run_state['chef-client-test'] ||= {})['pkg_info'] = pkg_info
    end
  end
  action :run
end

log "node-pkg-info" do
  level :info
  message lazy { node.run_state['chef-client-test']['pkg_info'].inspect }
end

# remote_file "/tmp/local-chef-package" do
#   source lazy { "file://" + node.run_state['chef-client-test']['pkg_info']["package_fullpath"] }
#   action :nothing
# end

package "chef" do
  # notifies :run, "/tmp/local-chef-package", :immediately
  action :install
  version lazy { node.run_state['chef-client-test']['pkg_info']["version"] }
  source lazy { node.run_state['chef-client-test']['pkg_info']["package_fullpath"] }
  provider Chef::Provider::Package::Dpkg
end

# run the specs in /home/vagrant/chef.