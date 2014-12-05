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

#
# Use this software definition to fix the shebangs of binaries under embedded/bin
# to point to the embedded ruby.
#

name "gem-cleanup"

default_version "0.0.1"

build do
  env = with_standard_compiler_flags(with_embedded_path).merge(
    # Rubocop pulls in nokogiri 1.5.11, so needs PKG_CONFIG_PATH and
    # NOKOGIRI_USE_SYSTEM_LIBRARIES until rubocop stops doing that
    "PKG_CONFIG_PATH" => "#{install_dir}/embedded/lib/pkgconfig",
    "NOKOGIRI_USE_SYSTEM_LIBRARIES" => "true",
  )
  gem "uninstall chef --version 0.8.10 -q", env: env, returns: [0, 1]
  gem "uninstall chef --version 10.34.6 -q", env: env, returns: [0, 1]
  gem "uninstall chef --version 11.6.0 -q", env: env, returns: [0, 1]
  gem "uninstall chef --version 11.6.2 -q", env: env, returns: [0, 1]
  gem "uninstall chef --version 11.16.4 -q", env: env, returns: [0, 1]
  gem "uninstall ohai --version 6.18.0 -q", env: env, returns: [0, 1]
  gem "uninstall ohai --version 6.24.2 -q", env: env, returns: [0, 1]
end
