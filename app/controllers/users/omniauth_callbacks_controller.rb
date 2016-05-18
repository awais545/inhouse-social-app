class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable
  
  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        auth = request.env['omniauth.auth']

        if current_user.present?
          current_user.set_authentications(auth)
          redirect_to root_path
        else
          authenticate = Authentication.is_authenticated?(auth)
          if authenticate.present?
            user = authenticate.user
            remember_me(user) if cookies[:omniauth_remember_me]
            sign_in_and_redirect user
          else
            @user = User.omniauth(auth)
            @user.set_authentications(auth) if @user.present?
            remember_me(@user) if cookies[:omniauth_remember_me]
            sign_in_and_redirect @user, event: :authentication  #this will throw if @user is not activated
            set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
          end
        end
      end
    }
  end

  [:twitter, :facebook, :instagram].each do |provider|
    provides_callback_for provider
  end
end
  