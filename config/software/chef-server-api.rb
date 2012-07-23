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

name "chef-server-api"
version ENV["CHEF_GIT_REV"] || "bd61f7a80db3f77d2977439271fdf9ddd19ef591"

dependencies ["ruby",
              "bundler",
              "gecode",
              "libxml2",
              "libxslt",
              "curl",
              "rsync"]

source :git => "git://github.com/opscode/chef"

project_dir = "#{source_dir}/#{name}/#{name}"

build do
  bundle "install --without test --path=#{install_dir}/embedded/service/gem", :cwd => project_dir
  command "mkdir -p #{install_dir}/embedded/service/chef-server-api"
  command "#{install_dir}/embedded/bin/rsync -a #{project_dir}/ --delete --exclude=.git/*** --exclude=.gitignore #{install_dir}/embedded/service/chef-server-api/"
end
