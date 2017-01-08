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
        
        time = Time.zone.now.to_s.first(10)
        #loop do
        #    if time.last(5).first(2) == "01" # 1월이 들어오는 경우 연도 하나 줄이고 전달을 12월로 넘김.
        #        time = (time.first(4).to_i - 1).to_s + "-12-01"
        #    else # 나머지는 걍 1씩 월에서 빼서 전달을 연산함.
        #        is_zero = ""
        #        if (time.last(5).first(2).to_i - 1).to_s.length == 1 
        #            is_zero = "0" 
        #        end
        #        time = time.first(4) + "-" + is_zero + (time.last(5).first(2).to_i - 1).to_s + "-01"
        #    end
        #    popular_songs = DailyTjPopularRank.where(symd: time).where.not(song_id: nil).order(song_rank: :asc).all
        #    popular_songs.each do |p_song|
        #        song = Song.find(p_song.song_id)
        #        next if song.song_num != nil # 이미 추가된 노래 빼고 나머지
        #        next if song.jacket == "Error::ThisMusickCanNotFind"   # 꽤꼬리 표시 노래 빼고 나머지
        #        @p_songs << p_song
        #        @popular_songs << song
        #    end
        #    @popular_songs = @popular_songs.uniq
        #    break if @popular_songs.count >= 100
        #    break if time.first(4) < "1950"
        #end
        
        now_month = Time.zone.now.month
        @popular_songs = []
        3.times do |j|
            year = 2016 - j
            if year == 2016
                now_month.times do |i|
                    month = now_month - i
                    DailyTjPopularRank.where(symd: "#{year}-0#{month}-01").each do |song| 
                        if Song.find(song.song_id).song_num == nil
                            @popular_songs << [song, "#{year}-0#{month}-01", Song.find(song.song_id) ]
                        end
                    end
                end
            else
                3.times do |i|
                    month = 12 - i
                    DailyTjPopularRank.where(symd: "#{year}-#{month}-01").each do |song| 
                        if Song.find(song.song_id).song_num == nil
                            @popular_songs << [song, "#{year}-#{month}-01", Song.find(song.song_id) ]
                        end
                    end
                end
                9.times do |i|
                    month = 9 - i
                    DailyTjPopularRank.where(symd: "#{year}-0#{month}-01").each do |song| 
                        if Song.find(song.song_id).song_num == nil
                            @popular_songs << [song, "#{year}-0#{month}-01", Song.find(song.song_id) ]
                        end
                    end
                end
            end
        end
        miss_songs = []
        Song.where(song_num: nil).where(jacket: nil).each do |song|
            if song.created_at.to_s.first(10) == "2016-12-01"
                miss_songs << song
            end
        end
        @miss_songs = miss_songs         # Song.where(song_num: nil).where(jacket: nil)
        @popular_songs = @popular_songs.first(15)
        # @songs = @miss_songs.first(0)
    end
    
    def ajax_search
        
        songs1 = Song.need_crawl.where("artist_name LIKE ?", "%#{params[:query]}%")
        songs2 = Song.need_crawl.where("title LIKE ?", "%#{params[:query]}%")
        songs3 = Song.need_crawl.where("lyrics LIKE ?", "%#{params[:query]}%")
        
        @songs = (songs1 + songs2 + songs3).uniq
        
        render json: {  Songs: @songs }
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

    def betaUser
        complete = nil
        complete = params[:complete_beta_user] unless params[:complete_beta_user].nil?

        admin_name = params[:admin_name]
        if params[:admin_name].nil? || params[:admin_name].length.zero?
            admin_name = "all"
        end

        @results = User.betaUserDetail(admin_name) unless complete == "false"
        @results = User.betaUserBlank(admin_name)  if complete == "false"
    end
    
    
    
    
    
    
    
    # 환영합니다 메세지 & 시작하기 버튼
    def research
        is_admin = false
        is_admin = true if params[:is_admin].to_s == "true"
        
        # @results = 
        render layout: 'research'
    end
    
    # 시작하기 누르면 더미 유저 생성 ~> 패쓰 (검색 대기 화면으로)
    def create_dummy_user
        sex     = params[:sex]
        birth   = params[:birth]
        accept  = params[:accept]
        
        # => fix parameters info for match User Table scheme
        if sex == "male"
            sex = 1
        elsif sex == "female"
            sex = 2
        elsif sex == "other"
            sex = 3
        else
            sex = 0
        end
        
        birth = "" if birth.nil? || birth.length.zero?
        
        
        # => rescent dummy user calculation
        lastDummyUser   = User.where("email LIKE?", "%dummy@%").last   # lastDummyUser.email = "dummy@101.user"
        
        newUserNum      = "1" if lastDummyUser.nil?
        newUserNum      = (lastDummyUser.email.gsub('dummy@','').gsub('.user','').to_i + 1).to_s  unless lastDummyUser.nil?
        
        # => create user
        user = User.new
        user.email      = "dummy@" + newUserNum + ".user"
        user.gender     = sex
        user.name       = birth.to_s
        if accept == "checked"
            user.password   = "111111"
            user.mytoken    = SecureRandom.hex(16)
            user.save
            Mylist.create!([{
                user_id: user.id,
                title: user.email + " 님의 첫 번째 리스트"
            }])
            
            session[:user]  = user
            redirect_to "/we/admin2/info2/#{user.id}"
        else
            redirect_to :back
        end
    end
    
    SONGS_PER_PAGE = 20 # 한 회 로딩에 보여줄 노래 개수
    
    # 검색 대기 (+결과) 화면 <~ Ajax통신으로 비동기 처리.
    def info2
        redirect_to '/we/admin2/login' if params[:id].nil?
        
        # => @current_user의 자료형 맞춰주기 위한 블록 (+ session reset)
        session.delete(:user)
        @current_user = User.where(id: params[:id]).take
        session[:user] = @current_user
        
        # => @current_user가 존재하는 경우에만 통과.
        if @current_user
            spp = SONGS_PER_PAGE
            page = 1
            @songs = Song.popular_month[(page - 1)*spp..page*spp].each{|song| song.tag_my_favorite(@current_user)}
            @count = @current_user.mylists.first.mylist_songs.count
            render layout: false
        else
            redirect_to '/we/admin2/login'
        end
    end
    
    def login
        #
        #
        render layout: false
    end
    
    # 고래방 길들이기 > ajax task group
    # ==================================
    #
    # => ajax method
    def get_ids
        result = false
        return render json: result if session[:user].nil?
        
        user = session[:user]
        user = User.find(user["id"])
        
        case request.method_symbol
        when :get
            song_id = params[:id] #.gsub('[','').gsub(']','').split(',').map{|s| s.to_i}
            
            ms = MylistSong.new
            ms.mylist_id = user.mylists.first.id
            ms.song_id   = song_id
            ms.save
        when :delete
            song_id = params[:id]
            
            ms = MylistSong.where(song_id: song_id, mylist_id: user.mylists.first.id).take
            if ms
                ms.delete
            end
        end
        
        count = user.mylists.first.mylist_songs.count
        return render json: count
    end
    
    # => ajax method
    def next_page
        result = false
        return render json: result if session[:user].nil?
        
        user = session[:user]
        user = User.find(user["id"])
        
        spp     = SONGS_PER_PAGE
        page    = params[:page].to_i
        songs   = Song.popular_month[(page - 1)*spp..page*spp]&.each{|song| song.checkJacket2.tag_my_favorite(user)}
        
        return render json: songs
    end
end
