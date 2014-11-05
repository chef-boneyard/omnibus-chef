
# build an omnibus-chef package.

log node.run_state.inspect

ruby_block "setup-environment" do
  block do
    ENV['USE_LOCAL_CHEF'] ||= "/home/vagrant/chef"
    ENV['OMNIBUS_PROJECT_NAME'] = "chef"
    ENV['OMNICHEF_DIR'] = node.default['client-test']['omnichef_dir']
    ENV['BUILD_ID'] = Time.now.strftime('%Y-%m-%d_%H-%m-%S')
    ENV['BUILD_TAG'] = `git log --oneline -n1`.split[0]
    ENV['BUILD_BRANCH'] = `git branch -l | grep '\*'`.split[1]
    ENV['PATH'] = "/opt/ruby-2.1.2/bin:/opt/ruby1.9/bin:/usr/local/bin:#{ENV['PATH']}"
    ENV['MANIFEST_FILE'] = "/opt/#{ENV['OMNIBUS_PROJECT_NAME']}/version-manifest.txt"
  end
end

file "build_timestamp" do
  content "#{ENV['BUILD_ID']} / #{ENV['BUILD_TAG']} (#{ENV['BUILD_BRANCH']})"
end

if false && windows?
  ENV['OMNICHEF_DIR'] = node.default['client-test']['omnichef_dir']
  ENV['CLEAN'] = "true"
  execute "windows-build-omnibus-chef" do
    cwd ENV['OMNICHEF_DIR']
    command "#{ENV['OMNICHEF_DIR']}/jenkins/build.bat"
  end
else

  # otherwise doing bundle install as non-root fails.
  ["chef", "rubies"].each do |dir|
    execute "chown -R vagrant /opt/#{dir}"
  end

  # avoid weird errors about not being allowed to sudo without a terminal. the sudo resource
  # failed validation even when called without parameters.
  file "/etc/sudoers" do
    owner "root"
    group "root"
    mode '0440'
    content File.open("#{node.default['client-test']['omnichef_dir']}/jenkins/sudoers").read
  end

  # this git caching stuff is weird, but particularly unsuitable for this use case.
  bash "clean-cache-directories" do
    code "sudo rm -rf /var/cache/omnibus/* || true"
  end

  execute "bundle-install" do
    cwd node.default['client-test']['omnichef_dir']
    user "vagrant"

    if false && node[:platform] =~ /solaris/
      command "bundle install --without development"
    else
      command "bundle install"
    end
  end

  bash "build-omnibus-package" do

    user "vagrant"
    group "vagrant"
    cwd node.default['client-test']['omnichef_dir']

    # don't forget to bring over the AIX conditionals, and the Solaris /etc/release thing.

    code "bundle exec omnibus build chef -l internal"
  end

  bash "write-build-version" do
    cwd node.default['client-test']['omnichef_dir']

    code <<-EOS
    awk -v p=#{ENV['OMNIBUS_PROJECT_NAME']} '$1 == p {print $2}' #{ENV['MANIFEST_FILE']} > pkg/BUILD_VERSION
    true
    EOS

    only_if { File.exists?(ENV['MANIFEST_FILE']) }
  end

end