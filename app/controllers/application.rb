# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
   session :session_key => '_screen_session_id'
   before_filter CASClient::Frameworks::Rails::Filter

   def logout
      cookies.delete :auth_token
      session.delete
      redirect_to "https://ctrc.itmat.upenn.edu/auth/logout"
   end
end

