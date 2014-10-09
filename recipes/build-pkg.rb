
# terrible hack because the omnibus-chef build tries to write into /opt/rubies.
%w{/opt/chef /opt/rubies}.each do |dir|
  execute "chown -R vagrant #{dir}" do
    only_if { ::Dir.exists?(dir) }
  end
end

bash "build-omnibus-chef" do
  user "vagrant"
  group "vagrant"
  cwd node.default['client-test']['omnichef_dir']

  ENV['USE_LOCAL_CHEF'] ||= "/home/vagrant/chef"

  # these first 2 steps should be doable with resources.
  code <<-EOS
  env > lastrun-env.sh

  bundle install
  bundle exec omnibus clean chef --purge
  bundle exec omnibus build chef --config omnibus-client-test.rb
  EOS

  not_if { File.exists?("#{node.default['client-test']['omnichef_dir']}/nobuild") }
end

