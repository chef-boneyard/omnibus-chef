
# terrible hack because the omnibus-chef build tries to write into /opt/rubies.
# %w{/opt/chef /opt/rubies}.each do |dir|
#   execute "chown -R vagrant #{dir}" do
#     only_if { ::Dir.exists?(dir) }
#   end
# end

# sudo "overwrite-sudoers" do
  # node.default['authorization']['sudo'] = {
  #   'groups' => ['sudo', 'admin'],
  #   'users'  => ['vagrant'],
  #   'passwordless' => true,
  # }
# end

if windows?
  ENV['OMNICHEF_DIR'] = node.default['client-test']['omnichef_dir']
  ENV['CLEAN'] = true
else
  file "/etc/sudoers" do
    owner "root"
    group "root"
    mode '0440'
    content File.open("#{node.default['client-test']['omnichef_dir']}/jenkins/sudoers").read
  end

  bash "build-omnibus-chef" do
    user "vagrant"
    group "vagrant"
    cwd node.default['client-test']['omnichef_dir']

    ENV['USE_LOCAL_CHEF'] ||= "/home/vagrant/chef"
    ENV['OMNIBUS_PROJECT_NAME'] = "chef"
    ENV['OVERRIDE_BUILD_USER'] = "vagrant"
    ENV['OMNICHEF_DIR'] = node.default['client-test']['omnichef_dir']
    ENV['BUILD_ID'] = Time.now.strftime('%Y-%m-%d_%H-%m-%S')

    code <<-EOS
    env > lastrun-env.sh
    export BUILD_TAG=`git log --oneline -n1 | awk '{print $1}'`

    $OMNICHEF_DIR/jenkins/build
    EOS

    not_if { File.exists?("#{node.default['client-test']['omnichef_dir']}/nobuild") }
  end
end