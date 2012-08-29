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

#
# Enable MySQL support by adding the following to '/etc/chef-server/chef-server.rb':
#
#   database_type = "mysql"
#   postgresql['enable'] = false
#   mysql['enable'] = true
#   mysql['destructive_migrate'] = true
#
# Then run 'chef-server-ctl reconfigure'
#

if !File.exists?("/var/opt/chef-server/mysql-bootstrap")
  if node["chef_server"]["mysql"]["destructive_migrate"] && node['chef_server']['bootstrap']['enable']

    ###
    # Create the database, migrate it, and create the users we need, and grant them
    # privileges.
    ###
    chpst = "/opt/chef-server/embedded/bin/chpst -u#{node['chef_server']['mysql']['username']}"
    mysql = "mysql -h#{node['chef_server']['mysql']['vip']}"
    sql_user = node['chef_server']['mysql']['sql_user']
    sql_password = node['mysql']['sql_password']

    database_exists = "#{chpst} mysqlshow | grep #{db_name}"
    user_exists     = "#{chpst} #{mysql} -e \"SELECT User FROM mysql.user\" | grep #{sql_user}"

    execute "#{mysql} -e \"CREATE DATABASE IF NOT EXISTS #{db_name};\"" do
      user node['chef_server']['mysql']['username']
      not_if database_exists
      retries 30
      notifies :run, "execute[migrate_database]", :immediately
    end

    execute "migrate_database" do
      command "#{mysql} -d#{db_name} < mysql_schema.sql"
      user node['chef_server']['mysql']['username']
      cwd "/opt/chef-server/embedded/service/chef_db/priv"
      action :nothing
    end

    execute "#{mysql} -e \"CREATE USER #{sql_user} IDENTIFIED BY PASSWORD '#{sql_password}'\"" do
      user node['chef_server']['mysql']['username']
      notifies :run, "execute[grant opscode_chef privileges]", :immediately
      not_if user_exists
    end

    execute "grant opscode_chef privileges" do
      command "#{mysql} -d#{db_name} -e \"GRANT ALL ON #{db_name}.* TO '#{sql_user}'@'#{db_vip}'\""
      user node['chef_server']['mysql']['username']
      action :nothing
    end
  end

  file "/var/opt/chef-server/mysql-bootstrap"
end
