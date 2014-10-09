# from omnibus.rb: no apparent way to just slurp these in.

# Enable S3 asset caching
# ------------------------------
use_s3_caching true
s3_access_key  ENV['AWS_ACCESS_KEY_ID']
s3_secret_key  ENV['AWS_SECRET_ACCESS_KEY']
s3_bucket      'opscode-omnibus-cache'

# Customize compiler bits
# ------------------------------
solaris_compiler 'gcc'
build_retries 3
fetcher_read_timeout 120
# -----------------------------------------

ENV['USE_LOCAL_CHEF'] ||= "/home/vagrant/chef"

# base_dir './local'