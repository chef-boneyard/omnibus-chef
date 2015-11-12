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

name "chefdk"
default_version "master"

source git: "git://github.com/chef/chef-dk.git"

relative_path "chef-dk"


if windows?
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
else
  dependency "libffi" if debian?
  dependency "ruby"
end

dependency "rubygems"
dependency "bundler"
dependency "appbundler"
dependency "chef"
dependency "berkshelf"
dependency "chef-vault"
dependency "foodcritic"
dependency "ohai"
dependency "inspec"
dependency "test-kitchen"
dependency "kitchen-inspec"
dependency "kitchen-vagrant"
dependency "openssl-customization"

dependency "chefdk-env-customization" if windows?

build do
  env = with_standard_compiler_flags(with_embedded_path).merge(
    # Rubocop pulls in nokogiri 1.5.11, so needs PKG_CONFIG_PATH and
    # NOKOGIRI_USE_SYSTEM_LIBRARIES until rubocop stops doing that
    "PKG_CONFIG_PATH" => "#{install_dir}/embedded/lib/pkgconfig",
    "NOKOGIRI_USE_SYSTEM_LIBRARIES" => "true",
  )

  bundle "install", env: env
  gem "build chef-dk.gemspec", env: env
  gem "install chef-dk*.gem" \
      " --no-ri --no-rdoc" \
      " --verbose", env: env

  # TODO: These gems should have software definitions created and in turn
  #       be properly appbundled.

  # Perform multiple gem installs to better isolate/debug failures
  {
    'chefspec'          => '4.4.0',
    'fauxhai'           => '2.3.0',
    'rubocop'           => '0.31.0',
    'knife-spork'       => '1.6.1',
    'winrm-transport'   => '1.0.2',
    'knife-windows'     => '1.1.1',
    # Strainer build is hosed on windows
    # 'strainer'        => '0.15.0',
  }.each do |name, version|
    gem "install #{name}" \
        " --version '#{version}'" \
        " --no-user-install" \
        " --bindir '#{install_dir}/bin'" \
        " --no-ri --no-rdoc" \
        " --verbose", env: env
  end

  appbundle 'berkshelf'
  appbundle 'chef-dk'
  appbundle 'chef-vault'
  appbundle 'foodcritic'
  appbundle 'test-kitchen'
end
