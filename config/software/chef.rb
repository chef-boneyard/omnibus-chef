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

name "chef"


dependency "bundler"

if windows?
  dependency "ruby-windows" #includes rubygems
  dependency "libyaml-windows"
  dependency "openssl-windows"
  dependency "ruby-windows-devkit"
  dependency "cacerts"
else
  dependency "ruby"
  dependency "rubygems"
  dependency "libffi"
end

default_version "master"

source :git => "git://github.com/opscode/chef"

relative_path "chef"

if windows?
  always_build (self.project.name == "chef-windows")
end


build do
  if not windows?
    env = with_standard_compiler_flags(with_embedded_path)
  end

  block do
    if File.exist?("#{project_dir}/chef")
      # We are on Chef 10 and need to adjust the relative path. In Chef 10, the
      # Chef Client and Chef Server were in the same repo (like Rails), but in
      # Chef 11, the server has been moved to its own project.
      software.relative_path('chef/chef')
    end
  end

  # big split between windows and non windows installs happens here
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
      source = "#{install_dir}/embedded/mingw/bin/#{to}"
      target = "#{install_dir}/bin/#{target}"
      copy(source, target)
    end

    rake "gem"

    gem "install pkg/chef*mingw32.gem" \
        " --bindir '#{install_dir}/bin'" \
        " --no-ri --no-rdoc" \
        " --verbose"

    # Depending on which shell is being used, the path environment variable can
    # be "PATH" or "Path". If *both* are set, only one is honored.
    path_key = ENV.keys.grep(/\Apath\Z/i).first

    bundle "install", env: {
      path_key => [
        windows_safe_path(install_dir, 'embedded', 'bin'),
        windows_safe_path(install_dir, 'embedded', 'mingw', 'bin'),
        windows_safe_path('C:/Windows/system32'),
        windows_safe_path('C:/Windows'),
        windows_safe_path('C:/Windows/System32/Wbem'),
      ].join(File::PATH_SEPARATOR)
    }
  else
    # The way we install chef is different between chefdk and chef projects
    # due to the fact that chefdk project has appbundler enabled.
    # Two differences are:
    #   1-) Order of bundle install & rake gem
    #   2-) "-n #{install_dir}/bin" option for gem install
    # We don't expect any side effects from (1) other than not creating
    # link to erubis binary (which is not needed other than ruby 1.8.7 due to
    # change that switched the template syntax checking to native ruby code.
    # Not having (2) does not create symlinks for binaries under
    # #{install_dir}/bin which gets created by appbundler later on.
    if %w{ chef angrychef chef-container }.include?(project.name)
      # install chef first so that ohai gets installed into /opt/chef/bin/ohai
      rake "gem", env: env

      delete "pkg/chef-*-x86-mingw32.gem"

      gem "install pkg/chef-*.gem" \
          " --bindir '#{install_dir}/bin'" \
          " --no-ri --no-rdoc", env: env

      # install the whole bundle, so that we get dev gems (like rspec) and can
      # later test in CI against all the exact gems that we ship (we will run
      # rspec unbundled in the test phase).
      bundle "install --without server docgen", env: env
    else
      # install the whole bundle first
      bundle "install --without server docgen", env: env

      rake "gem", env: env

      delete "pkg/chef-*-x86-mingw32.gem"

      # Don't use -n #{install_dir}/bin. Appbundler will take care of them later
      gem "install pkg/chef-*.gem " \
          " --no-ri --no-rdoc", env: env
    end

    auxiliary_gems = {}
    auxiliary_gems['ruby-shadow'] = '>= 0.0.0' unless Ohai['platform'] == 'aix'

    auxiliary_gems.each do |name, version|
      gem "install #{name}" \
          " --version '#{version}'" \
          " --no-ri --no-rdoc" \
          " --verbose", env: env
    end

    # Clean up
    delete("#{install_dir}/embedded/docs")
    delete("#{install_dir}/embedded/share/man")
    delete("#{install_dir}/embedded/share/doc")
    delete("#{install_dir}/embedded/share/gtk-doc")
    delete("#{install_dir}/embedded/ssl/man")
    delete("#{install_dir}/embedded/man")
    delete("#{install_dir}/embedded/info")
  end
end
