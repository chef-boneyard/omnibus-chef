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
maintainer "Opscode, Inc."
homepage "http://www.opscode.com"

replaces        "chef-full"
install_path    "/opt/chef"
build_version   Omnibus::BuildVersion.full
build_iteration 4

dependency "preparation"
dependency "chef"
dependency "ohai" if ENV["OHAI_GIT_REV"]
dependency "opscode-pushy-client"
dependency "version-manifest"
