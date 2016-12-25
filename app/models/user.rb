class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise  :database_authenticatable, :registerable,
            :recoverable, :rememberable, :trackable, :validatable,
            :omniauthable, :omniauth_providers => [:facebook]

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

    def self.markingRange(admin_name)
        start = 1
        stop  = self.where("email LIKE?", "%.beta%").count
        count = 20  # 1인당 몇 명
        if admin_name == "손대근"
            start = 80
            stop  = start + count -1
        elsif admin_name == "김용현"
            start = 60 
            stop  = start + count -1
        elsif admin_name == "유선우"
            start = 40
            stop  = start + count -1
        elsif admin_name == "김은솔"
            start = 100
            stop  = start + count -1
        elsif admin_name == "정지은"
            start = 120
            stop  = start + count -1
        end
        puts "\n\n\t\tstart = #{start} / stop = #{stop}\n\n\n"
        return start-1, stop-1
    end

    def self.betaUserDetail(admin_name)
        start, stop = User.markingRange(admin_name)
        start = start.to_i; stop = stop.to_i;
        self.where("email LIKE?", "%.beta%").map{|u| ["EMAIL : "+ u.email, "NAME : "+ u.name, "COUNT : "+ u.my_songs.count.to_s + "개", u.mylists.first.mylist_songs.map{|s| Song.find(s.song_id)}.map{|s| s.title + " / " + s.artist_name}]}[start..stop]
    end

    def self.betaUserBlank(admin_name)
        start, stop = User.markingRange(admin_name)
        start = start.to_i; stop  = stop.to_i;
        self.where("email LIKE?", "%.beta%").map{|u| if u.my_songs.count < 13 then ["EMAIL : "+ u.email, "NAME : "+ u.name, "COUNT : "+ u.my_songs.count.to_s + "개", u.mylists.first.mylist_songs.map{|s| Song.find(s.song_id)}.map{|s| s.title + " / " + s.artist_name}] end}[start..stop]
    end

    def self.from_omniauth(auth)
        where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        # where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
            user.provider = auth.provider
            user.id = auth.id
            unless auth.info.email.nil?
                user.email = auth.info.email
            else
                unless auth.id.nil?
                    user.eamil = ""
                end
            end
            user.password = Devise.friendly_token[0,20]
            user.name = auth.info.name   # assuming the user model has a name
            # user.image = auth.info.image # assuming the user model has an image
        end
    end

    # def self.new_with_session(params, session)
    #   super.tap do |user|
    #       if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
    #           user.email = data["email"] if user.email.blank?
    #       end
    #   end
    # end

    def self.new_with_session(params, session)
        if session["devise.user_attributes"]
            new(session["devise.user_attributes"], without_protecttion: true) do |user|
                user.attributes = params
                user.valid?
            end  
        else
            super
        end 
    end

    # def self.find_for_facebook_oauth(auth)
    #   user = where(auth.slice(:provider, :uid)).first_or_create do |user|
    #       user.provider = auth.provider
    #       user.uid = auth.uid
    #       user.email = auth.info.email
    #       user.password = Devise.friendly_token[0,20]
    #       user.name = auth.info.name   # assuming the user model has a name
    #       user.image = auth.info.image # assuming the user model has an image
    #       # 이 때는 이상하게도 after_create 콜백이 호출되지 않아서 아래와 같은 조치를 했다.
    #       # user.add_role :user if user.roles.empty?
    #       # user   # 최종 반환값은 user 객체이어야 한다.
    #   end
    # end   

    
    # def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    #     data = access_token.info
    #     user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    #     if user
    #         return user
    #     else
    #         registered_user = User.where(:email => access_token.info.email).first
    #         if registered_user
    #             return registered_user
    #         else
    #             user = User.create(name: data["name"],
    #             provider:access_token.provider,
    #             email: data["email"],
    #             uid: access_token.uid ,
    #             password: Devise.friendly_token[0,20],
    #             )
    #         end
    #     end
    # end
end
