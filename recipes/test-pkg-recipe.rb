ruby_block "setup" do

  block do

    node.run_state[:client_test] ||= {}

    if node[:platform] == "smartos"
      node.run_state[:client_test][:prefix] = "/opt/local"
    else
      node.run_state[:client_test][:prefix] = "/usr"
    end


    node.run_state[:client_test][:symlinks] = %w{chef-client chef-solo chef-apply chef-shell knife shef ohai}

    pkg_provider, extension = value_for_platform_family(
                                "debian"                   => [ Chef::Provider::Package::Dpkg, "deb" ],
                                ["rhel", "fedora", "arch"] => [ Chef::Provider::Package::Yum,  "rpm" ],
                              )

    pkg_file = Dir.glob("#{node.default['client-test']['omnichef_dir']}/pkg/*.#{extension}").
              sort_by{ |f| File.mtime(f) }.reverse[0]

    if pkg_file.nil?
      raise Chef::Exception.new "Could not find a candidate package file in pkg/*.#{extension}; did you build one?"
    end

    { provider: pkg_provider, extension: extension, pkg_file: pkg_file }.each do |k, v|
      node.run_state[:client_test][k] = v
    end

    Chef::Log.info "#{pkg_provider} #{extension} #{pkg_file}"
  end
end

# not all providers support :purge, so add that to the platform-specific stuff.
package "uninstall-chef" do
  package_name "chef"
  action :purge
  provider lazy { node.run_state[:client_test][:provider] }
end

ruby_block "clear-symlinks" do
  block do
    node.run_state[:client_test][:symlinks].each do |symlink|
      Chef::Resource::File.new(symlink, run_context).run_action :delete
    end
  end
end

package "install-pkg-under-test" do
  action :install
  source lazy { node.run_state[:client_test][:pkg_file] }
  provider lazy { node.run_state[:client_test][:provider] }
end

# run the specs that got installed by the built package.
bash "run-specs" do

  cwd "/opt/chef/embedded/apps/chef"

  code <<-EOS
  env PATH=/opt/chef/bin:/opt/chef/embedded/bin:#{ENV['PATH']} TERM=xterm bundle exec rspec \
  -r rspec_junit_formatter \
  -f RspecJunitFormatter -o #{ENV['TEMP']}/test.xml -f documentation spec
  EOS
end


# uninstall the built package--meant to test postrm scripts?
package "uninstall-pkg-under-test" do
  package_name "chef"
  action :purge
  provider lazy { node.run_state[:client_test][:provider] }
end
