class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

    # def google_oauth2
    #     @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    #     if @user.persisted?
    #         flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
    #         sign_in_and_redirect @user, :event => :authentication
    #     else
    #         session["devise.google_data"] = request.env["omniauth.auth"]
    #         redirect_to new_user_registration_url
    #     end
    # end

    # def facebook
    #     # You need to implement the method below in your model (e.g. app/models/user.rb)
    #     @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])
    #      # @user = find_for_facebook_oauth(env["omniauth.auth"], current_user)

    #     if @user.persisted?
    #         sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    #         set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    #     else
    #         session["devise.facebook_data"] = request.env["omniauth.auth"]
    #         #redirect_to new_user_registration_url
    #         redirect_to "redirect_to root_path"
    #     end
    # end

    def facebook
        # You need to implement the method below in your model (e.g. app/models/user.rb)
        puts "\n\n\n\n\n\n\n\n\n\n\t\t페북로그인 시도 'def facebook'에 진입함 \n\n\n\n\n\n\n\n\n\n"
        @user = User.from_omniauth(request.env["omniauth.auth"])
        puts "\n\n\n\n\n\n\n\n\n\n\t\t'@user' 를 반환받았음  \n\n\n\n\n\n\n\n\n\n"

        if @user.persisted?
          puts "\n\n\n\n\n\n\n\n\n\n\t\t'@user.persisted is TRUE'에 진입함 \n\t\t#{@user}\n\n\n\n\n\n\n\n\n"
          sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
          set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
        else
          puts "\n\n\n\n\n\n\n\n\n\n\t\t'@user.persisted is FALSE'에 진입함 \n\t\t#{@user}\n\n\n\n\n\n\n\n\n"
          session["devise.facebook_data"] = request.env["omniauth.auth"]
          puts "\n\n\n\n\n\n\n\n\n\n\t\t'session[\"devise.facebook_data\"]'를 반환받았음\n\t\t#{}\n\n\n\n\n\n\n\n\n"
          # redirect_to "/json/main_banner" # new_user_session_path
          #redirect_to new_user_registration_url
          redirect_to user_session_path

        end
    end

    def failure
       puts "\n\n\n\n\n\n\n\n\n\n\t\t'failure'에 진입함 \n\t\t#{}\n\n\n\n\n\n\n\n\n"
       redirect_to root_path
    end

    # You should configure your model like this:
    # devise :omniauthable, omniauth_providers: [:twitter]

    # You should also create an action method in this controller like this:
    # def twitter
    # end

    # More info at:
    # https://github.com/plataformatec/devise#omniauth

    # GET|POST /resource/auth/twitter
    # def passthru
    #   super
    # end

    # GET|POST /users/auth/twitter/callback
    # def failure
    #   super
    # end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end
end
