#
# Copyright:: Copyright (c) 2014 Opscode, Inc.
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

name "openssl-windows"
default_version "3.2.22-4-msys-1.0.18"

dependency "ruby-windows"

source :url => "https://github.com/jdmundrawala/bash-test/releases/download/bash-#{version}/bash-#{version}-bin.tar.lzma",
       :md5 => "7182920ebb3fd81f80defd550a8380af"

build do
  temp_directory = File.join(cache_dir, "bash-cache")
  FileUtils.mkdir_p(temp_directory)
  # First extract the tar file out of lzma archive.
  command "7z.exe x #{project_file} -o#{temp_directory} -r -y"
  # Now extract the files out of tar archive.
  command "7z.exe x #{File.join(temp_directory, "bash-#{version}-bin.tar")} -o#{temp_directory} -r -y"
  # Copy over the required bins into embedded/bin
  ["bash.exe", "sh.exe", "bashbug"].each do |exe|
    command "cp #{File.join(temp_directory, "bin", exe)} #{File.join(install_dir, "embedded", "bin", exe)}"
  end
end
