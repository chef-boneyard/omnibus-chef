source 'https://rubygems.org'

gem 'omnibus', github: 'opscode/omnibus'
gem 'omnibus-software', github: 'opscode/omnibus-software', branch: 'ma/winzmq'

# This development group is installed by default when you run `bundle install`,
# but if you are using Omnibus in a CI-based infrastructure, you do not need
# the Test Kitchen-based build lab. You can skip these unnecessary dependencies
# by running `bundle install --without development` to speed up build times.
group :development do
  # Use Berkshelf for resolving cookbook dependencies
  gem 'berkshelf', '~> 3.0'

  # Use Test Kitchen with Vagrant for converging the build environment
  gem 'test-kitchen',    '~> 1.4.0.rc.1'
  gem 'kitchen-vagrant', '~> 0.17.0.rc.1'
  gem 'winrm-transport', '~> 1.0'
end
