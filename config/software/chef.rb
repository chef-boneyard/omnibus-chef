#
# Copyright:: Copyright (c) 2012-2014 Chef Software, Inc.
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

dependency "ruby"
dependency "rubygems"
dependency "libffi"
dependency "bundler"

default_version "master"

source :git => "git://github.com/opscode/chef"

relative_path "chef"

env = with_embedded_path()
env = with_standard_compiler_flags(env)

build do
  block do
    if File.exist?("#{project_dir}/chef")
      # We are on Chef 10 and need to adjust the relative path. In Chef 10, the
      # Chef Client and Chef Server were in the same repo (like Rails), but in
      # Chef 11, the server has been moved to its own project.
      software.relative_path('chef/chef')
    end
  end

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
  if %w(chef angrychef chef-container).include?(project.name)
    # install chef first so that ohai gets installed into /opt/chef/bin/ohai
    rake "gem", :env => env

    command "rm -f pkg/chef-*-x86-mingw32.gem"

    gem ["install pkg/chef-*.gem",
      "-n #{install_dir}/bin",
      "--no-rdoc --no-ri"].join(" "), :env => env

    # install the whole bundle, so that we get dev gems (like rspec) and can later test in CI
    # against all the exact gems that we ship (we will run rspec unbundled in the test phase).
    bundle "install --without server docgen", :env => env
  else
    # install the whole bundle first
    bundle "install --without server docgen", :env => env

    rake "gem", :env => env

    command "rm -f pkg/chef-*-x86-mingw32.gem"

    # Don't use -n #{install_dir}/bin. Appbundler will take care of them later
    gem ["install pkg/chef-*.gem",
      "--no-rdoc --no-ri"].join(" "), :env => env
  end

  auxiliary_gems = []
  auxiliary_gems << "ruby-shadow" unless platform == "aix"

  gem ["install",
       auxiliary_gems.join(" "),
       "--no-rdoc --no-ri"].join(" "), :env => env

  #
  # TODO: the "clean up" section below was cargo-culted from the
  # clojure version of omnibus that depended on the build order of the
  # tasks and not dependencies. if we really need to clean stuff up,
  # we should probably stick the clean up steps somewhere else
  #

  # clean up
  ["docs",
   "share/man",
   "share/doc",
   "share/gtk-doc",
   "ssl/man",
   "man",
   "info"].each do |dir|
    command "rm -rf #{install_dir}/embedded/#{dir}"
  end
end
