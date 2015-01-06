#
# Author:: Ty Alexander (ty.alexander@sendgrid.com)
# Project Definition:: sgdk
#
# Copyright (C) 2014 SendGrid
# All rights reserved - Do Not Redistribute
#

name "sgdk"
friendly_name "SendGrid Development Kit"
maintainer "SendGrid Engineering Services"
homepage "https://github.com/sendgrid/sgdk"

build_iteration 1
build_version do
  source :git, from_dependency: 'sgdk'
  output_format :semver
end

install_dir "#{default_root}/#{name}"

# As of 27 October 2014, the newest CA cert bundle does not work with AWS's
# root cert. See:
# * https://github.com/opscode/chef-dk/issues/199
# * https://blog.mozilla.org/security/2014/09/08/phasing-out-certificates-with-1024-bit-rsa-keys/
# * https://forums.aws.amazon.com/thread.jspa?threadID=164095
# * https://github.com/opscode/omnibus-supermarket/commit/89197026af2931de82cfdc13d92ca2230cced3b6
#
# For now we resolve it by using an older version of the cert. This only works
# if you have this version of the CA bundle stored via S3 caching (which Chef
# Software does).
override :cacerts, version: '2014.08.20'

override :berkshelf,      version: "v3.2.1"
override :bundler,        version: "1.7.5"
override :chef,           version: "11.18.0.rc.1"

# TODO: Can we bump default versions in omnibus-software?
override :libedit,        version: "20130712-3.1"
override :libtool,        version: "2.4.2"
override :libxml2,        version: "2.9.1"
override :libxslt,        version: "1.1.28"

override :ruby,           version: "2.1.4"
######
# Ruby 2.1.3 is currently not working on windows due to:
# https://github.com/ffi/ffi/issues/375
# Enable below once above issue is fixed.
# override :'ruby-windows', version: "2.1.3"
# override :'ruby-windows-devkit', version: "4.7.2-20130224-1151"
override :'ruby-windows', version: "2.0.0-p451"
######
override :rubygems,       version: "2.4.4"
override :'test-kitchen', version: "v121-dep-fix"
override :yajl,           version: "1.2.1"
override :zlib,           version: "1.2.8"

dependency "preparation"
dependency "sgdk"
dependency "chefdk"
dependency "chef-provisioning"
dependency "chef-provisioning-fog"
dependency "chef-provisioning-vagrant"
dependency "chef-provisioning-azure"
dependency "chef-provisioning-aws"
dependency "rubygems-customization"
dependency "shebang-cleanup"
dependency "version-manifest"

package :pkg do
  identifier "com.sendgrid.pkg.sgdk"
end

compress :dmg
