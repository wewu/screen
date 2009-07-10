# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_screen_session", :secret  => "7267b4cf8d2e3d969efe00d0508e57170bd61e466617a3ddf97aa0ae44a5" }
  #config.action_controller.relative_url_root = '/screen'
end


# Include your application configuration below

ActiveRecord::Base.pluralize_table_names = false

CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => "https://ctrc.itmat.upenn.edu/auth"
#   :cas_base_url => "https://bioinf.itmat.upenn.edu/sso"
)

