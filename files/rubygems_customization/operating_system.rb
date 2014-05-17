## Rubygems Customization ##
# Customize rubygems install behavior and locations to keep user gems isolated
# from the stuff we bundle with omnibus and any other ruby installations on the
# system.

module Gem

  ##
  # Override user_dir to live inside of ~/.chefdk

  def self.user_dir
    parts = [Gem.user_home, '.chefdk', 'gem', ruby_engine]
    parts << RbConfig::CONFIG['ruby_version'] unless RbConfig::CONFIG['ruby_version'].empty?
    File.join parts
  end

end

class Gem::Installer

  #
  # override the gem installer to default to user mode installation for non-root users
  #

  old_initialize = instance_method(:initialize)
  define_method(:initialize) do |gem, options|
    options ||= {}
    unless Process.euid == 0
      options[:user_install] = true
    end
    old_initialize.bind(self).(gem, options)
  end
end

