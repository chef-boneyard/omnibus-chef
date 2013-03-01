#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

bootstrap_status_file = "/var/opt/chef-server/bootstrapped"
erchef_dir = "/opt/chef-server/embedded/service/erchef"

erchef_status_url = "http://#{node['chef_server']['erchef']['listen']}"
erchef_status_url << ":#{node['chef_server']['erchef']['port']}/_status"

execute "verify-system-status" do
  command "curl -sf #{erchef_status_url}"
  retries 20
  not_if { File.exists?(bootstrap_status_file) }
end

execute "boostrap-chef-server" do
  command "bin/bootstrap-chef-server"
  cwd erchef_dir
  not_if { File.exists?(bootstrap_status_file) }
  environment({ 'CHEF_ADMIN_USER' => node['chef_server']['chef-server-webui']['web_ui_admin_user_name'],
                 'CHEF_ADMIN_PASS' => node['chef_server']['chef-server-webui']['web_ui_admin_default_password'] })
  notifies :restart, 'service[erchef]'
end

# servers need access to this key.
chef_user = node['chef_server']['user']['username']
file "/etc/chef-server/chef-webui.pem" do
  owner "root"
  group chef_user
  mode "0640"
  not_if { File.exists?(bootstrap_status_file) }
end

file bootstrap_status_file do
  owner "root"
  group "root"
  mode "0600"
  content "All your bootstraps are belong to Chef"
end
