# install and test an omnibus-chef package.

if windows?
else
  bash "test-omnibus-chef-pkg" do
    user "vagrant"
    group "vagrant"
    cwd node.default['client-test']['omnichef_dir']

    ENV['OMNICHEF_DIR'] = node.default['client-test']['omnichef_dir']
    ENV['WORKSPACE'] = ENV['OMNICHEF_DIR']

    code <<-EOS

    $OMNICHEF_DIR/jenkins/client-test
    EOS
  end
end