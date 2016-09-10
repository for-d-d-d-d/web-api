class Admin2Controller < ApplicationController
    layout "admin"

    class ErrorIssue
        attr_accessor :error_num, :link, :memo, :priority
        def initialize
            @error_num = 0
            @link = ""
            @memo = ""
            @priority = 1
        end
    end

    def admin_login
        render layout: false
    end

    def admin_signin
        unless Administer.where(username: "#{params[:username]}").take.nil?
            unless Administer.where(username: "#{params[:username]}", password: "#{params[:password]}").take.nil?
                redirect_to '/admin/awesome_4d'
            else
                redirect_to :back
            end
        else
            redirect_to :back
        end
    end

    def admin_signup
        a = Administer.new
        a.username  = params[:username]
        a.email     = params[:email]
        a.password  = params[:password]
        a.created_at = Time.parse(Time.zone.now.to_s)
        a.updated_at = Time.parse(Time.zone.now.to_s)
        a.save
        redirect_to '/admin/admin_login'
    end

    def admin_forgotpwd

        redirect_to :back
    end

    def profile_about

    end

    def awesome_4d
        render layout: false
    end

    def index
    end

    def team_list
        @team = Team.all
    end

    def singer_list
        @singer = Singer.all
    end

    def album_list
        @album = Album.all
    end

    def songs_info
        # @song = Song.all
        @song = Song.where(ganre1: "가요")
        @top100 = DailyTjPopularRank.all
        @mod_song = Song.find(params[:mod]) unless params[:mod] == nil
        ### 노래방 번호 또는 지니뮤직 노래번호가 입력되지 않은 노래는
        ### SongController에서 TJ 와 Ginnie 의 노래링크로 저장했으므로
        ### 저장된 링크를 버튼으로 출력하여 이동 후 찾아서 저장하도록 한다.
        @song_miss = Array.new
        @song.each do |song|
            if song.song_tjnum == nil
                @song_miss << song
            end
        end
        # render layout: "../admin_layouts/application.html.erb"
    end

    def songs_info2
        @song = Song.all
        @top100 = DailyTjPopularRank.all
        @mod_song = Song.find(params[:mod]) unless params[:mod] == nil
        ### 노래방 번호 또는 지니뮤직 노래번호가 입력되지 않은 노래는
        ### SongController에서 TJ 와 Ginnie 의 노래링크로 저장했으므로
        ### 저장된 링크를 버튼으로 출력하여 이동 후 찾아서 저장하도록 한다.
        # @song_miss = Array.new
        # @song.each do |song|
        #   if song.song_tjnum.to_s.length > 10 || song.song_num.to_s.length > 10
        #     @song_miss << song
        #   end
        # end
    end

    def gui_vr_info
        @song = Song.all
    end

    def list_range
    end

    def crawler_manager
        # @songs = Song.all
        unless user_signed_in?
            redirect_to '/users/sign_in'
        end
        @songs = Song.first(1)
        @miss_songs = Song.where(song_num: nil).where(jacket: nil)
        
    end
    
    def cannotFind_on_ginnie
        song = Song.find(params[:id])
        song.jacket = "Error::ThisMusickCanNotFind"
        song.save
        redirect_to :back
    end

    def error_manager
        @errors = Array.new
        sum = 0
        @total = Array.new(6, 0)
        # :error_num, :link, :memo, :priority

        Song.all.each do |s|
            if s.title.nil? || s.title.empty?
                e = ErrorIssue.new
                e.memo = s.id.to_s + "번 Song의 title 이(가) nil값 입니다."
                e.error_num = 101
                e.priority = 5
                sum += e.priority
                e.link = "/admin/songs_info?mod=" + s.id.to_s
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if s.artist.nil?
                e = ErrorIssue.new
                e.memo = s.id.to_s + "번 Song의 artist 이(가) nil값 입니다."
                e.error_num = 102
                e.priority = 5
                e.link = ""
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if s.song_num.nil?
                e = ErrorIssue.new
                e.memo = s.id.to_s + "번 Song의 song_num 이(가) nil값 입니다."
                e.error_num = 103
                e.priority = 4
                # e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if s.lowkey.nil? || s.lowkey.empty?
                e = ErrorIssue.new
                e.memo = s.id.to_s + "번 Song의 lowkey 이(가) nil값 입니다."
                e.error_num = 104
                e.priority = 1
                e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if s.highkey.nil? || s.highkey.empty?
                e = ErrorIssue.new
                e.memo = s.id.to_s + "번 Song의 highkey 이(가) nil값 입니다."
                e.error_num = 105
                e.priority = 1
                e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if s.song_tjnum.nil?
                e = ErrorIssue.new
                e.memo = s.id.to_s + "번 Song의 song_tjnum 이(가) nil값 입니다."
                e.error_num = 106
                e.priority = 2
                # e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if s.album.nil?
                e = ErrorIssue.new
                e.memo = s.id.to_s + "번 Song의 album 이(가) nil값 입니다."
                e.error_num = 107
                e.priority = 4
                # e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
        end

        Album.all.each do |a|
            if a.title.nil? || a.title.empty?
                e = ErrorIssue.new
                e.memo = a.id.to_s + "번 Album의 title 이(가) nil값 입니다."
                e.error_num = 201
                e.priority = 5
                # e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if a.artist.nil?
                e = ErrorIssue.new
                e.memo = a.id.to_s + "번 Album의 artist 이(가) nil값 입니다."
                e.error_num = 202
                e.priority = 3.5
                # e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if a.jacket.length <= 10
                e = ErrorIssue.new
                e.memo = a.id.to_s + "번 Album의 jaket 이(가) 잘못된 값 입니다."
                e.error_num = 203
                e.priority = 3.5
                # e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
            if a.publisher.nil? || a.publisher.empty?
                e = ErrorIssue.new
                e.memo = a.id.to_s + "번 Album의 publisher 이(가) nil값 입니다."
                e.error_num = 204
                e.priority = 0.5
                # e.link = "/admin/songs_info?mod=" + s.id.to_s
                sum += e.priority
                @total[e.priority.ceil] += 1
                @errors << e
            end
        end

        # Team, Mylist, MylistSong, User, Singer, Assosiations
        # @all = @total.inject(0){|sum,x| sum + x }
        # @all = @total.inject(0, :+)
        @percent = 0
        @percent = (sum.to_f / @errors.count).round(2) unless @errors.count == 0
    end
end
