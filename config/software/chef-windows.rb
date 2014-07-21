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

name "chef-windows"

dependency "ruby-windows" #includes rubygems
dependency "libyaml-windows"
dependency "openssl-windows"
dependency "ruby-windows-devkit"
dependency "bundler"
dependency "cacerts"

default_version "master"

source :git => "git://github.com/opscode/chef"

relative_path "chef"

always_build (self.project.name == "chef-windows")

build do
  # COMPAT HACK :( - Chef 11 finally has the core Chef code in the root of the
  # project repo. Since the Chef Client pipeline needs to build/test Chef 10.x
  # and 11 releases our software definition need to handle both cases
  # gracefully.
  block do
    build_commands = self.builder.build_commands
    chef_root = File.join(self.project_dir, "chef")
    if File.exists?(chef_root)
      build_commands.each_index do |i|
        cmd = build_commands[i].dup
        if cmd.is_a? Array
          if cmd.last.is_a? Hash
            cmd_opts = cmd.pop.dup
            cmd_opts[:cwd] = chef_root
            cmd << cmd_opts
          else
            cmd << {:cwd => chef_root}
          end
          build_commands[i] = cmd
        end
      end
    end
  end

  # Normally we would symlink the required unix tools.
  # However with the introduction of git-cache to speed up omnibus builds,
  # we can't do that anymore since git on windows doesn't support symlinks.
  # https://groups.google.com/forum/#!topic/msysgit/arTTH5GmHRk
  # Therefore we copy the tools to the necessary places.
  # We need tar for 'knife cookbook site install' to function correctly
  {"tar.exe" => "bsdtar.exe",
    "libarchive-2.dll" => "libarchive-2.dll",
    "libexpat-1.dll" => "libexpat-1.dll",
    "liblzma-1.dll" => "liblzma-1.dll",
    "libbz2-2.dll" => "libbz2-2.dll",
    "libz-1.dll" => "libz-1.dll"
  }.each do |target, to|
    source = File.expand_path(File.join(install_path, "embedded", "mingw", "bin", to)).gsub(/\//, "\\")
    target = File.expand_path(File.join(install_path, "bin", target)).gsub(/\//, "\\")
    command "cp #{source}  #{target}"
  end

  rake "gem"

  gem ["install pkg/chef*mingw32.gem",
       "-n #{install_path}/bin",
       "--no-rdoc --no-ri"].join(" ")

  # Depending on which shell is being used, the path environment variable can
  # be "PATH" or "Path". If *both* are set, only one is honored.
  path_key = ENV.keys.grep(/\Apath\Z/i).first

  bundle "install", :env => { path_key => "#{install_path}\\embedded\\bin;#{install_path}\\embedded\\mingw\\bin;C:\\Windows\\system32;C:\\Windows;C:\\Windows\\System32\\Wbem"}
end
