class Api::InterfaceController < ApplicationController
    ## REST-API Definition
    
    def index
        # super
    end
    def create
        # super
    end
    def new
        # super
    end
    def edit
        # super
    end
    def show
        # super
    end
    def update
        # super
    end
    def destroy
        # super
    end
    
    
    # 첫 화면
    # > 캐러셀
    def main_banner
        contents    = $contents
        banner      = []
        
        contents.each do |content|
            obj     = {}
            obj["background_img"]   = content[0]
            obj["main_title"]       = content[1]
            obj["sub_title"]        = content[2]
            banner << obj
        end
        
        result = []
        banner.each do |b|
            result << {"image": b["background_img"], "title": "#{b["main_title"]}\n#{b["sub_title"]}"} #, "url": SERVER_URL + "/json/recom/1"}
        end
        render json: result
    end
    
    
    # 첫 화면
    # > 인기차트
    # INPUT >   {
    #               (+) column:     제외할 노래정보 (선택사항, 없어도 무관),
    #               (+) page:       조회할 페이지 (cf. offset),
    #               (+) mytoken:    사용자 회원 토큰
    #           }
    def top100
        @song = Song.popular_month
        # @song = Song.all.sample(100) #tj_ok.where("genre2 LIKE ?", "%힙합%")
        # result = @song_top100
        # result = Song.tj_ok.first(30)
        
        column = Song.attribute_names
        unless params[:column].nil? || params[:column].to_s.length == 0
            column = params[:column].to_s.delete('[').delete(']').delete(' ').split(',')
        end
        exclude = Song.attribute_names - column
        
        ids     = @song.map{|song| song.id}
        ids     = UtilController.filtering_blacklistSongs_from_list(ids, User.where(mytoken: params[:mytoken]).take.id)
        ids     = UtilController.pager(params[:page], ids).to_s
        result  = UtilController.detail_songs(ids, exclude, params[:mytoken], true)
        
        render :json => result
    end

    
    # 첫 화면 ( restAPI server(0) android(x) iOS(x) )
    # > 이달의 신곡
    # INPUT >   {
    #               (+) page:       조회할 페이지 (cf. offset),
    #               (+) mytoken:    사용자 회원 토큰
    #           }
    def month_new
        month_new_songs = []
        #Time.zone.now
        #Song.tj_ok.each do |song| #추후 갯수 밑 신곡반영.
        #    if song.created_at.to_s.first(10) == (Time.zone.now.to_s.first(8) + "01")
        #        month_new_songs << song
        #    end
        #end
        month_new_songs = Song.month_new
        
        return render :json => [] if params[:mytoken].nil? || params[:mytoken].length < 1
        ids     = month_new_songs.map{|s| s.id}
        ids     = UtilController.filtering_blacklistSongs_from_list(ids, User.where(mytoken: params[:mytoken]).take.id)
        ids     = UtilController.pager(params[:page], ids).to_s
        result  = UtilController.detail_songs(ids, [], params[:mytoken], true)
        render :json => result
    end
    
    
    # 조건검색 api
    # INPUT   >   mytoken, page
    #             genre
    #             age
    #             gender
    #
    # OUTPUT  >   songs with pager
    def filter_by
        songs = Song.tj_ok
        filtered_genre  = songs.where("genre1 LIKE ?", "%#{params[:genre]}%") unless params[:genre].nil?
        filtered_age    = []
        unless params[:age].nil?
            Album.where("released_date LIKE ?", "%#{params[:age]}%").all.each{|album| filtered_age += album.songs.tj_ok}
        end
        
        filtered_gender = []
        unless params[:gender].nil?
            if params[:gender] == "남성"
                @gender = 1
            elsif params[:gender] == "여성"
                @gender = 2
            elsif params[:gender] == "혼성"
                @gender = 4
            else
                @gender = nil
            end
            (Singer.where(gender: @gender).all + Team.where(gender: @gender).all).each do |artist|
                filtered_gender += artist.songs.tj_ok
            end
        end
        songs2  = (filtered_genre + filtered_age + filtered_gender).uniq
        
        ids     = songs2.map{|s| s.id}
        ids     = UtilController.pager(params[:page], ids)
        result  = UtilController.detail_songs(ids, [], params[:mytoken], true)
        render json: result
    end
    
    
    # 검색 api
    # INPUT   >   mytoken, page,
    #             search_by : "artist" / "title" / "lyrics"
    #             query
    # OUTPUT  >   songs with pager
    def search_by
        if params[:auto_complete] == "true"
            count = 3
        
            artists = Song.where("artist_name LIKE ?", "%#{params[:query]}%").select("artist_name").uniq.map{|s| "|아티스트| " + s.artist_name}.first(count)
            title   = Song.where("title LIKE ?", "%#{params[:query]}%").select("title, artist_name").map{|s| "|제목검색| #{s.title}, #{s.artist_name}"}.uniq.first(count)
            lyrics  = Song.where("lyrics LIKE ?", "%#{params[:query]}%").select("title, artist_name, lyrics").uniq.map{|s| "|가사검색| #{s.title}, #{s.artist_name}, #{s.lyrics.first(20).gsub('<br>',' ').gsub('&amp;','&')}..."}.first(count)
            return render json: [artists: artists, title: title, lyrics: lyrics]
        end
        
        #
        # Validatiors
        return render json: {state: "400 BAD REQUEST", message: "you need to send a parameter : 'mytoken'"} if params[:mytoken].nil?
        return render json: {state: "400 BAD REQUEST", message: "you need to send a parameter : 'search_by' ('artist' or 'title' or 'lyrics')"} if params[:search_by].nil? || params[:search_by] != "artist" && params[:search_by] != "title" && params[:search_by] != "lyrics"
        search_by = params[:search_by]
        return render json: {state: "400 BAD REQUEST", message: "you need to send a parameter : 'query'", toast: "검색어를 입력해주세요"} if params[:query].nil?
        
        mytoken     = params[:mytoken]
        search_by   = params[:search_by]
        if search_by == "artist"
            songs = HomeController.search3_by_artist(params[:query])
        elsif search_by == "title"
            songs = HomeController.search3_by_title(params[:query])
        elsif search_by == "lyrics"
            songs = HomeController.search3_by_lyrics(params[:query])
        end
        
        if songs.count == 0
            return render json: songs
        else
            ids = songs.map{|song| song.id}
        end
        
        ids     = UtilController.filtering_blacklistSongs_from_list(ids, User.where(mytoken: mytoken).take.id) # remove hateSong
        ids     = UtilController.pager(params[:page], ids)  # Pager
        result  = UtilController.detail_songs(ids, [], mytoken, true)
        render json: result
    end
    
    
    # Recommender
    # method : POST, GET
    # Input   > id: 회원 id, page
    # Output  > 추천 Song Data
    def recom
        sing_it = SunwooController.recommend(params[:id])
        #count = ForAnalyze.find(1) # 추천 받을 때 마다 분석정보를 담는 DB에 총추천횟수를 1씩 올려줌.
        #count.count_recomm +=1
        #count.save
        ids     = sing_it.map{|s| s.id}
        ids     = UtilController.filtering_blacklistSongs_from_list(ids, params[:id])
        ids     = UtilController.pager(params[:page], ids).to_s
        result  = UtilController.detail_songs(ids, [], User.find(params[:id]).mytoken, true)
        render json: result
    end
end
