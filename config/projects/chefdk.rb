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

name "chefdk"
friendly_name "Chef Development Kit"
maintainer "Chef Software, Inc. <maintainers@chef.io>"
homepage "https://www.chef.io"

build_iteration 1
build_version '0.8.0'

if windows?
  # NOTE: Ruby DevKit fundamentally CANNOT be installed into "Program Files"
  #       Native gems will use gcc which will barf on files with spaces,
  #       which is only fixable if everyone in the world fixes their Makefiles
  install_dir "#{default_root}/opscode/#{name}"
else
  install_dir "#{default_root}/#{name}"
end

# Uncomment to pin the chef version
override :chef,           version: "stable"
override :ohai,           version: 'stable'

override :berkshelf,      version: "v3.3.0"
override :bundler,        version: "1.10.0"
override :'chef-vault',   version: "v2.6.1"

# TODO: Can we bump default versions in omnibus-software?
override :libedit,        version: "20130712-3.1"
override :libtool,        version: "2.4.2"
override :libxml2,        version: "2.9.1"
override :libxslt,        version: "1.1.28"

override :ruby,           version: "2.1.6"
######
# Ruby 2.1/2.2 has an error on Windows - HTTPS gem downloads aren't working
# https://bugs.ruby-lang.org/issues/11033
# Going to leave 2.1.5 for now since there is a workaround
override :'ruby-windows', version: "2.1.6"
override :'ruby-windows-devkit', version: "4.7.2-20130224"
override :'openssl-windows', version: "1.0.1m"
######

######
# rubygems 2.4.5 is not working on windows.
# See https://github.com/rubygems/rubygems/issues/1120
# Once this is fixed, we can bump the version
override :rubygems,       version: "2.4.4"
######

override :'test-kitchen', version: "v1.4.2"
override :'kitchen-vagrant', version: "v0.18.0"
override :yajl,           version: "1.2.1"
override :zlib,           version: "1.2.8"

# NOTE: the base chef-provisioning gem is a dependency of chef-dk (the app).
# Manage the chef-provisioning version via chef-dk.gemspec.
override :'chef-provisioning-fog', version: "v0.13.2"
override :'chef-provisioning-vagrant', version: "v0.9.0"
override :'chef-provisioning-azure', version: "v0.3.2"
override :'chef-provisioning-aws', version: "v1.3.1"

dependency "preparation"
dependency "chef"
dependency "chef-provisioning-fog"
dependency "chef-provisioning-vagrant"
dependency "chef-provisioning-azure"
dependency "chef-provisioning-aws"
dependency "chefdk"
dependency "rubygems-customization"
dependency "shebang-cleanup"
dependency "version-manifest"
dependency "openssl-customization"

package :rpm do
  signing_passphrase ENV['OMNIBUS_RPM_SIGNING_PASSPHRASE']
end

package :pkg do
  identifier "com.getchef.pkg.chefdk"
  signing_identity "Developer ID Installer: Chef Software, Inc. (EU3VF8YLX2)"
end

package :msi do
  upgrade_code "AB1D6FBD-F9DC-4395-BDAD-26C4541168E7"
  signing_identity "F74E1A68005E8A9C465C3D2FF7B41F3988F0EA09", machine_store: true
end

compress :dmg
