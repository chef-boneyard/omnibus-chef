#
# Copyright 2014 Chef Software, Inc.
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

name "chef-container"
friendly_name "Chef Container"
maintainer "Chef Software, Inc"
homepage "https://www.getchef.com"

build_iteration  1
build_version do
  # Use chef to determine the build version
  source :git, from_dependency: 'chef'

  # Set a rubygems style version
  output_format :semver
end

install_dir "#{default_root}/chef"

dependency "preparation"
dependency "chef"
dependency "chef-init"
dependency "version-manifest"

package :rpm do
  signing_passphrase ENV['OMNIBUS_RPM_SIGNING_PASSPHRASE']
end

package :pkg do
  identifier "com.getchef.pkg.chef-container"
  signing_identity "Developer ID Installer: Opscode Inc. (9NBR9JL2R2)"
end

compress :dmg
