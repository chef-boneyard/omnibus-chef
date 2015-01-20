#
# Copyright 2014 SendGrid.
#

name "sgdk"
default_version "master"
source git: "https://github.com/sendgrid/sgdk.git"

build do
  copy "#{project_dir}", "#{install_dir}/embedded"
  command "chmod 666 #{install_dir}/embedded/#{name}/Berksfile.lock"
end
