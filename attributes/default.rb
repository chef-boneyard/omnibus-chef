BASE         = "/home/vagrant"
OMNICHEF_DIR = "#{BASE}/omnibus-chef"
PKG_DIR      = "#{OMNICHEF_DIR}/pkg"
SRC_DIR      = "#{BASE}/chef"
ENV['PATH']  = "/usr/local/bin:/home/vagrant/.gem/ruby/2.1.2/bin:/opt/rubies/ruby-2.1.2/lib/ruby/gems/2.1.0/bin:/opt/rubies/ruby-2.1.2/bin:/opt/chef/embedded/bin:/opt/chef/embedded/bin:#{ENV['PATH']}"

default['client-test']['omnichef_dir'] = OMNICHEF_DIR
default['client-test']['pkg_dir'] = PKG_DIR
default['client-test']['src_dir'] = SRC_DIR
