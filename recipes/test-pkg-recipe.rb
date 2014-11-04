# install and test an omnibus-chef package.

if windows?
else
  ruby_block "setup" do
    block do
      if node[:platform] == "smartos"
        node.run_state[:client_test][:prefix] = "/opt/local"
      else
        node.run_state[:client_test][:prefix] = "/usr"
      end

      node.run_state[:client_test][:symlinks] = %w{chef-client chef-solo chef-apply chef-shell knife shef ohai}
    end
  end

  ruby_block "create-pkg-cmds" do
    block do
    end
  end

  package "uninstall-previous-chef" do
    package_name "chef"
    action :remove
  end

  bash "nuke-old-remnants" do
    code <<-EOS
    rm -rf /opt/chef/*
    for symlink in #{node.run_state[:client_test][:symlinks].join(" ")}; do
      rm -f #{node.run_state[:client_test][:prefix]}/bin/$symlink || true
    end
    EOS
  end

  bash "install-new-pkg" do
  end

  # run the specs that got installed by the built package.
  bash "run-specs" do
    action :nothing
    cwd "/opt/chef/embedded/apps/chef"

    ENV['PATH'] = "/opt/chef/bin:/opt/chef/embedded/bin:ENV['PATH']"

    # think PATH here is redundant since we're not sudoing.
    code <<-EOS
    env PATH=#{ENV['PATH']} TERM=xterm bundle exec rspec -r rspec_junit_formatter \
    -f RspecJunitFormatter -o $WORKSPACE/test.xml -f documentation spec
    EOS
  end

  # uninstall the built package.

end