
# build an omnibus-chef package.

if windows?
  ENV['OMNICHEF_DIR'] = node.default['client-test']['omnichef_dir']
  ENV['CLEAN'] = "true"
  execute "windows-build-omnibus-chef" do
    cwd ENV['OMNICHEF_DIR']
    command "#{ENV['OMNICHEF_DIR']}/jenkins/build.bat"
  end
else

  # avoid weird errors about not being allowed to sudo without a terminal.
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
    ENV['CLEAN'] = "true"

    # that Perl command is gross, but otherwise that test fails when run through TK.
    code <<-EOS
    env > lastrun-env.sh
    export BUILD_TAG=`git log --oneline -n1 | awk '{print $1}'`

    perl -i.orig -npe 's/8889/8890/g' #{ENV['USE_LOCAL_CHEF']}/spec/integration/knife/serve_spec.rb

    $OMNICHEF_DIR/jenkins/build
    EOS

    not_if { File.exists?("#{node.default['client-test']['omnichef_dir']}/nobuild") }
  end
end