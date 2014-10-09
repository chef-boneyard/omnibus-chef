
# remote_file "/tmp/local-chef-package" do
#   source lazy { "file://" + node.run_state['chef-client-test']['pkg_info']["package_fullpath"] }
#   action :nothing
# end

package "chef" do
  action :install
  version lazy { node.run_state['chef-client-test']['pkg_info']["version"] }
  source lazy { node.run_state['chef-client-test']['pkg_info']["package_fullpath"] }
  provider Chef::Provider::Package::Dpkg
end
