#
# Copyright 2012-2014 Chef Software, Inc.
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

name "exboot"
friendly_name "Sendgrid Engineering Services bootstrap tool"
maintainer "SendGrid Engineering Services"
homepage "https://githbu.com/sendgrid/esboot"

build_iteration 1
build_version do
  # Use chef to determine the build version
  source :git, from_dependency: 'esboot'

  # Output a SemVer compliant version string
  output_format :semver
end

install_dir "#{default_root}/#{name}"

# As of 27 October 2014, the newest CA cert bundle does not work with AWS's
# root cert. See:
# * https://github.com/opscode/chef-dk/issues/199
# * https://blog.mozilla.org/security/2014/09/08/phasing-out-certificates-with-1024-bit-rsa-keys/
# * https://forums.aws.amazon.com/thread.jspa?threadID=164095
# * https://github.com/opscode/omnibus-supermarket/commit/89197026af2931de82cfdc13d92ca2230cced3b6
#
# For now we resolve it by using an older version of the cert. This only works
# if you have this version of the CA bundle stored via S3 caching (which Chef
# Software does).
override :cacerts, version: '2014.08.20'

override :bundler,        version: "1.7.2"
override :ruby,           version: "2.1.4"
######
# Ruby 2.1.3 is currently not working on windows due to:
# https://github.com/ffi/ffi/issues/375
# Enable below once above issue is fixed.
# override :'ruby-windows', version: "2.1.3"
# override :'ruby-windows-devkit', version: "4.7.2-20130224-1151"
override :'ruby-windows', version: "2.0.0-p451"
######
override :rubygems,       version: "2.4.4"

dependency "preparation"
dependency "chef"
dependency "esboot"
dependency "shebang-cleanup"
dependency "version-manifest"

package :pkg do
  identifier "com.sendgrid.pkg.esboot"
end
compress :dmg

