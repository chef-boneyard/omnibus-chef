#
# Copyright 2014 SendGrid.
#

name "esboot"
default_version "master"

source git: "https://github.com/sendgrid/esboot.git"

dependency "ruby"
dependency "rubygems"

dependency "bundler"
dependency "nokogiri"
dependency "chef"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # we need thor installed into omnibus ruby
  gem ['install thor',
       '-n #{install_dir}/bin',
       '--no-rdoc',
       '--no-ri'
  ].join(" "), env: env

  # Copy code from esboot into omnibus
  copy "#{project_dir}", "#{install_dir}/embedded"

  # symlink bootstrap-workstation entry point into /opt/chef/bin
  #link "#{install_dir}/embedded/#{name}/bin/#{name}", "#{install_dir}/bin"

end
