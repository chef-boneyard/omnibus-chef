#
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
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

name "generate-package-scripts"

default_version "0.0.1"

build do
  if !windows?
    mkdir project.package_scripts_path

    erb source: "postinst.erb",
        dest: File.join(project.package_scripts_path, "postinst"),
        mode: 0755,
        vars: { install_dir: install_dir }

    erb source: "postrm.erb",
        dest: File.join(project.package_scripts_path, "postrm"),
        mode: 0755,
        vars: { install_dir: install_dir }
  end
end
