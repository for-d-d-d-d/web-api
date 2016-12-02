class HomeController < ApplicationController
    layout 'home'

    def entering
        @bg_img = [
            "http://www.todayjournal.co.kr/news/photo/201509/2786_6024_2539.JPG",
            "http://www.agendalugano.ch/system/images/files/000/008/293/original/fondo_inicio.jpg?1405683396",
            "http://debrown.com.ar/wp-content/uploads/2014/09/certamen.jpg",
            "http://i00.i.aliimg.com/wsphoto/v1/2018739680_3/Tapete-free-Shipping-Fashionable-Flashing-Lights-Karaoke-Bar-Ktv-Entertainment-Clubs-Stage-Backdrop-Mural-Living-Room.jpg",
            "http://melissadreamsofsushi.com/wp-content/uploads/2013/12/DSC003311.jpg",
            "http://www.panicmanual.com/wp-content/uploads/2013/11/karaoke.jpg",
            "http://groupon.co.id/images/picpromobig/5f0f5e5f33945135b874349cfbed4fb976429.jpg"
        ].sample
        #@bg_img = "http://i.blogs.es/70ab15/karaoke-apps-i1/650_1200.jpg"

        # 로그인 되있으면 main2로 가고 로그인 안되있으면 sign_in으로

        # test 용 entering page 보기
        # view/devise/sessions/new.html.erb 에다가 entering 패이지를 옴기새요

        if user_signed_in?
            redirect_to '/home/main'
        else
            redirect_to '/users/sign_in'
        end
    end

    def main
        @songs = Song.tj_ok.all.first(60)
        # @songs = Song.tj_ok.first #popular_month
        @carousel = Song.tj_ok.first(17)

        # @rankers = DailyTjPopularRank.all

        # @ranker = Array.new
        # @rankers.each do |r|
        #     aa = Song.where(song_tjnum: r.song_num).take
        #     if aa != nil
        #         @ranker << aa
        #     end
        # end
    end
    
    def self.search3(query)
        if query.nil?
            flash[:error] = "검색어를 찾을 수 없습니다."
        else
            if query.length == 0
                flash[:error] = "검색어를 찾을 수 없습니다."
                return
            end

            splited = query.split
            @song_searched_By_artist = Array.new
            @song_searched_By_title = Array.new
            @song_searched_By_lyrics = Array.new

            Song.tj_ok.all.each do |s|
                splited.each do |q|
                    @song_searched_By_artist << s if s.artist.name.include?(q)
                    @song_searched_By_title << s if s.title.include?(q)
                    @song_searched_By_lyrics << s if s.lyrics.include?(q)
                end
            end
            
            @song_searched_By_artist = @song_searched_By_artist.uniq
            @song_searched_By_title = @song_searched_By_title.uniq
            @song_searched_By_lyrics = @song_searched_By_lyrics.uniq
        end
        
        return @song_searched_By_artist, @song_searched_By_title, @song_searched_By_lyrics
    end

    def self.search3_by_artist(query)
        if query.nil?
            flash[:error] = "검색어를 찾을 수 없습니다."
        else
            if query.length == 0
                flash[:error] = "검색어를 찾을 수 없습니다."
                return
            end
            @song_searched_By_artist = Song.no_crash.where("artist_name LIKE ?", "%#{query}%").uniq
        end
        return @song_searched_By_artist
    end

    def self.search3_by_title(query)
        if query.nil?
            flash[:error] = "검색어를 찾을 수 없습니다."
        else
            if query.length == 0
                flash[:error] = "검색어를 찾을 수 없습니다."
                return
            end
            @song_searched_By_title = Song.no_crash.where("title LIKE ?", "%#{query}%").uniq
        end
        return  @song_searched_By_title
    end

    def self.search3_by_lyrics(query)
        if query.nil?
            flash[:error] = "검색어를 찾을 수 없습니다."
        else
            if query.length == 0
                flash[:error] = "검색어를 찾을 수 없습니다."
                return
            end

            splited = query.split
           
            @song_searched_By_lyrics = Array.new
           

            Song.no_crash.all.each do |s|
                splited.each do |q|
                    @song_searched_By_lyrics << s if s.lyrics.include?(q)
                end
            end
            @song_searched_By_lyrics = @song_searched_By_lyrics.uniq
        end
        return  @song_searched_By_lyrics
    end
    
   
    
    def this_song
        @song = []
        song = Song.find(params[:song_id])
        song.attribute_names.each do |x|
            @song << eval("song.#{x}") unless x == "created_at" || x == "updated_at"
        end

        @song << song.artist.name
        @song << song.artist.photo

        @song << song.album.title
        @song << song.album.jacket
        @song << song.album.released_date
        @song << song.album.publisher
        @song << song.album.agency
        arr = []
        i = 0
        song.album.songs.each do |y|
            arr << y.title.split("(").first.strip
            arr << y.artist.name
            arr << y.album.title
            i += 1
        end
        @song << arr
        @song << i

        render json: @song
    end

    def this_song2
        @song = Song.find(params[:song_id])
        @songs = @song.album.songs
        artistName = Array.new
        @songs.each do |s|
            artistName << s.artist.name
        end
        
        render json: {  Song:    @song, 
                        Album:   @song.album, 
                        Artist:  @song.artist,
                        Songs:   @songs,
                        Artists: artistName }
    end

    def rank
    end

    def recommendation
        @action = params[:action]
    end

    def mylist
        # @mylists
        @songs = Song.all
        @song = @songs.where.not(lowkey: nil).all
        @header_BG_img = @song.sample.jacket
    end
    
    
    def youtube
        videos = Yt::Collections::Videos.new
        a = videos.where(q: "[MV] 시간을 달려서").first.id
        render text: a
    end

    
    
    
end
