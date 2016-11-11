class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

    has_many :mylists
    has_many :blacklist_songs

    def my_songs
        sa = Array.new
        self.mylists.each do |ml|
            ml.mylist_songs.each do |s|
                s = s.song
                sa << s
            end
        end
        # if sa.count == 0
        #     sa = Song.ok.first(12)
        # end
        sa
    end

    def self.from_omniauth(auth)
        where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
            user.email = auth.info.email
            user.password = Devise.friendly_token[0,20]
            user.name = auth.info.name   # assuming the user model has a name
            # user.image = auth.info.image # assuming the user model has an image
        end
    end

    def self.new_with_session(params, session)
        super.tap do |user|
            if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
                user.email = data["email"] if user.email.blank?
            end
        end
    end


   # def self.find_for_facebook_oauth(auth)
    #    user = where(auth.slice(:provider, :uid)).first_or_create do |user|
     #   user.provider = auth.provider
      #  user.uid = auth.uid
       # user.email = auth.info.email
      #  user.password = Devise.friendly_token[0,20]
      #  user.name = auth.info.name   # assuming the user model has a name
      #  user.image = auth.info.image # assuming the user model has an image
      #  # 이 때는 이상하게도 after_create 콜백이 호출되지 않아서 아래와 같은 조치를 했다.
      #  user.add_role :user if user.roles.empty?
      #  user.save   # 최종 반환값은 user 객체이어야 한다.
      #  end
  # end 
   



  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
     user = User.where(:provider => auth.provider, :uid => auth.uid).first
      unless user
          pass = Devise.friendly_token[0,20]
          user = User.new(name:auth.extra.raw_info.name,     
                         provider:auth.provider,
                       uid:auth.uid,
                       email:auth.info.email,
                          password: pass,
                          password_confirmation: pass
                         )                        
                     
         # user.skip_confirmation!
          user.save
                                                                                                                                                                                           end
                                                                                                                                                                                               user
                                                                                                                                                                                                end
























    
    def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
        data = access_token.info
        user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
        if user
            return user
        else
            registered_user = User.where(:email => access_token.info.email).first
            if registered_user
                return registered_user
            else
                user = User.create(name: data["name"],
                provider:access_token.provider,
                email: data["email"],
                uid: access_token.uid ,
                password: Devise.friendly_token[0,20],
                )
            end
        end
    end
end
