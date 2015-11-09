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
  dependency "openssl-windows" # FROM chef
  dependency "ruby-windows-devkit"
  dependency "ruby-windows-devkit-bash"
  dependency "cacerts"
else
  dependency "ruby"
  dependency "libffi"
  dependency "libarchive"
end

dependency "rubygems"
dependency "bundler"
dependency "nokogiri"
dependency "dep-selector-libgecode"
dependency "appbundler"
dependency "openssl-customization"
dependency "chefdk-env-customization" if windows?

build do
  env = with_standard_compiler_flags(with_embedded_path).merge(
    # Rubocop pulls in nokogiri 1.5.11, so needs PKG_CONFIG_PATH and
    # NOKOGIRI_USE_SYSTEM_LIBRARIES until rubocop stops doing that
    "PKG_CONFIG_PATH" => "#{install_dir}/embedded/lib/pkgconfig",
    "NOKOGIRI_USE_SYSTEM_LIBRARIES" => "true",
  )

  #
  # FROM chef: copy tar and some other windows DLLs
  #
  if windows?
    # Normally we would symlink the required unix tools.
    # However with the introduction of git-cache to speed up omnibus builds,
    # we can't do that anymore since git on windows doesn't support symlinks.
    # https://groups.google.com/forum/#!topic/msysgit/arTTH5GmHRk
    # Therefore we copy the tools to the necessary places.
    # We need tar for 'knife cookbook site install' to function correctly
    {
      'tar.exe'          => 'bsdtar.exe',
      'libarchive-2.dll' => 'libarchive-2.dll',
      'libexpat-1.dll'   => 'libexpat-1.dll',
      'liblzma-1.dll'    => 'liblzma-1.dll',
      'libbz2-2.dll'     => 'libbz2-2.dll',
      'libz-1.dll'       => 'libz-1.dll',
    }.each do |target, to|
      copy "#{install_dir}/embedded/mingw/bin/#{to}", "#{install_dir}/bin/#{target}"
    end
  end

  #
  # Install the chef-dk and its attendant gems.
  #
  bundle "install --gemfile omnibus.gemfile", env: env
  gem "build chef-dk.gemspec", env: env
  gem "install chef-dk*.gem --no-ri --no-rdoc --verbose", env: env

  # FROM chef
  # Always deploy the powershell modules in the correct place.
  block do
    #
    # FROM chef: install ruby-shadow
    #
    unless aix? || windows?
      gem "install ruby-shadow --no-ri --no-rdoc --verbose", env: env
    end

    #
    # Go through all gems installed via git, and install them directly so that we
    # can get rid of the git checkouts
    #
    Dir[ "#{install_dir}/embedded/lib/ruby/gems/*/bundler/gems/*" ].each do |gem_path|
      next if File.basename(gem_path) == "extensions"
      gem_name = File.basename(gem_path).rpartition("-")[0]
      gemspec_path = "#{gem_path}/#{gem_name}.gemspec"
      if windows?
        if File.exist?("#{gem_path}/#{gem_name}-windows.gemspec")
          gemspec_path = "#{gem_path}/#{gem_name}-windows.gemspec"
        elsif File.exist?("#{gem_path}/#{gem_name}-universal-mingw32.gemspec")
          gemspec_path = "#{gem_path}/#{gem_name}-universal-mingw32.gemspec"
        end
      end
      gem "build #{gemspec_path}", cwd: gem_path, env: env
      gem "install --no-ri --no-rdoc " \
          "--local --ignore-dependencies *.gem", cwd: gem_path, env: env
    end

    #
    # Appbundle all the things
    #
    # To do this, we go into each app, call bundle install --local to lock it to
    # the ChefDK's dependencies.
    #
    # TODO add insspec. But beware, it wants rubocop 0.32 (might not truly be a hard
    # requirement, but it's in the Gemfile).
    #
    %w(chef berkshelf chef-dk chef-vault test-kitchen
       foodcritic test-kitchen chefspec fauxhai rubocop
       knife-spork winrm-transport).each do |gem_name|
      appbundle "chef-dk/omnibus.gemfile.lock", name: gem_name, env: env
    end

    # FROM chef
    # Clean up
    delete "#{install_dir}/embedded/docs"
    delete "#{install_dir}/embedded/share/man"
    delete "#{install_dir}/embedded/share/doc"
    delete "#{install_dir}/embedded/share/gtk-doc"
    delete "#{install_dir}/embedded/ssl/man"
    delete "#{install_dir}/embedded/man"
    delete "#{install_dir}/embedded/info"
    delete "#{install_dir}/embedded/lib/ruby/gems/*/cache"
    delete "#{install_dir}/embedded/lib/ruby/gems/*/bundler/gems"

    # Copy over the powershell modules
    if windows?
      block do
        mkdir "#{install_dir}/modules/chef"
        copy "#{gem_path('chef-[0-9]*')}/distro/powershell/chef/*", "#{install_dir}/modules/chef"
      end
    end
  end
end
