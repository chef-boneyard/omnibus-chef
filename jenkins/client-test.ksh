#!/bin/ksh
#
# ksh variation of client-test, eventually client-test will be updated to handle aix.
#
set -e
set -x

function is_aix {
  uname | grep "^AIX"
}

PREFIX="/usr"

# copy off the timestamp for fingerprinting before we blow it away later
mv $BUILD_NUMBER/build_timestamp $WORKSPACE/
cd $BUILD_NUMBER

# remove the chef package / clobber the files
if is_aix;
then
    sudo installp -u chef || true
else
    echo "This is AIX specific script. Please use the client-test for non-aix platforms."
    exit 1
fi

sudo rm -rf /opt/chef/*

# ensure symlinks are gone, so that failures to recreate them get caught
sudo rm -f $PREFIX/bin/chef-client || true
sudo rm -f $PREFIX/bin/chef-solo || true
sudo rm -f $PREFIX/bin/chef-apply || true
sudo rm -f $PREFIX/bin/chef-shell || true
sudo rm -f $PREFIX/bin/knife || true
sudo rm -f $PREFIX/bin/shef || true
sudo rm -f $PREFIX/bin/ohai || true

# install the new package
if is_aix;
then
    sudo installp -aYF -d pkg/chef*.bff chef
fi

# sanity check that we're getting symlinks from the pre-install script
if [ ! -e "/usr/bin/chef-client" ]; then
  echo "/usr/bin/chef-client symlink was not installed by pre-install script!"
  exit 1
fi

if [ ! -e "/usr/bin/knife" ]; then
  echo "/usr/bin/knife symlink was not installed by pre-install script!"
  exit 1
fi

if [ ! -e "/usr/bin/chef-solo" ]; then
  echo "/usr/bin/chef-solo symlink was not installed by pre-install script!"
  exit 1
fi

if [ ! -e "/usr/bin/ohai" ]; then
  echo "/usr/bin/ohai symlink was not installed by pre-install script!"
  exit 1
fi

# we test using the specs packaged in the gem
cd /opt/chef/embedded/lib/ruby/gems/1.9.1/gems/chef-[0-9]*

# test against the rspec and gems in the omnibus build
export PATH=/opt/chef/bin:/opt/chef/embedded/bin:$PATH

# we do not bundle exec here in order to test against gems in the omnibus build
sudo env PATH=$PATH TERM=xterm rspec -r rspec_junit_formatter -f RspecJunitFormatter -o $WORKSPACE/test.xml -f documentation spec

# clean up the workspace to save disk space
cd $WORKSPACE
rm -rf $BUILD_NUMBER
