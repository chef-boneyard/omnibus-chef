#
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
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

# This software makes sure that SSL_CERT_FILE environment variable is pointed
# to the bundled CA certificates that ship with omnibus. With this, Chef
# tools can be used with https URLs out of the box.
name "ruby-customization"

source path: "#{project.files_path}/#{name}"

dependency "ruby"

build do
  if aix?
    block "Modify mkmf" do
      # gets directories for RbConfig::CONFIG and sanitizes them.
      def get_sanitized_rbconfig(config)
        ruby = "#{install_dir}/embedded/bin/ruby"

        config_dir = Bundler.with_clean_env do
          command_output = %x|#{ruby} -rrbconfig -e "puts RbConfig::CONFIG['#{config}']"|.strip
        end

        if config_dir.nil? || config_dir.empty?
          raise "could not determine embedded ruby's RbConfig::CONFIG['#{config}']"
        end

        config_dir
      end

      embedded_ruby_site_dir = get_sanitized_rbconfig('sitelibdir')
      embedded_ruby_lib_dir  = get_sanitized_rbconfig('rubylibdir')

      source_mkmf_hack = File.join(project_dir, "aix", "mkmf.patch")
      output = %x|/opt/freeware/bin/patch -d #{embedded_ruby_lib_dir} -p1 -i #{source_mkmf_hack}"|
	puts " OUTPUT : " +  output
    end
  end
end
