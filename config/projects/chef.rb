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

name "chef"
friendly_name "Chef Client"
maintainer "Chef Software, Inc."
homepage "http://www.getchef.com"

build_iteration 1
build_version do
  # Use chef to determine the build version
  source :git, from_dependency: 'chef'

  # Set a Rubygems style version
  output_format :git_describe
end

if windows?
  install_dir    "c:/opscode/chef"
else
  install_dir    "/opt/chef"
end

mac_pkg_identifier "com.getchef.pkg.chef"

override :rubygems, version: "1.8.29"

dependency "preparation"
dependency "chef"
dependency "version-manifest"

if windows?
  package_name    "chef-client"

  msi_parameters do
    # Find path in which chef gem is installed to.
    # Note that install_dir is something like: c:/opscode/chef
    search_pattern = "#{install_dir}/**/gems/chef-[0-9]*"
    chef_gem_path  = Dir.glob(search_pattern).find do |path|
      File.directory?(path)
    end

    if chef_gem_path.nil?
      raise "Could not find a chef gem in `#{search_pattern}'!"
    end

    # Convert the chef gem path to a relative path based on install_dir
    relative_path = Pathname.new(chef_gem_path)
      .relative_path_from(Pathname.new(install_dir))
      .to_s

    # Return the result as a hash
    {
      # We are going to use this path in the startup command of chef
      # service. So we need to change file seperators to make windows
      # happy.
      chef_gem_path: relative_path.gsub(File::SEPARATOR, File::ALT_SEPARATOR),
      upgrade_code:  'D607A85C-BDFA-4F08-83ED-2ECB4DCD6BC5',
    }
  end
end
