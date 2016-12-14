class Api::BlacklistSongController < ApplicationController
    ## REST-API Definition
    
    # => (신규 생성) POST     /api/blacklist_song                   api/blacklist_song#create
    # STORY   > 블랙리스트에 새로운 곡을 추가
    # Input   > (+)   user_id:    회원 id
    #           (+)   song_id:    추가할 song ID
    # Output  > {
    #               id:       \추가된 BlacklistSong id\, 
    #               message:  \SUCCESS or ERROR\
    #           }
    def create
        @check = "ERROR"
        unless params[:user_id].nil? || params[:song_id].nil?
            if User.find(params[:user_id]).blacklist_songs.where(song_id: params[:song_id]).count != 0
                return render json: {status: @check, message: "이미 차단 설정된 노래입니다"}
            end
            bs = BlacklistSong.new
            bs.song_id  = params[:song_id]
            bs.user_id  = params[:user_id]
            bs.save
            @check = "SUCCESS"
        end
        result = {"id": bs.id, "message": @check}
        render json: result
    end
    
    # => (유관 조회) GET      /api/blacklist_song                   api/blacklist_song#index
    # STORY   > 내 블랙리스트 수록곡들을 조회
    # Input   > (+)   user_id:    회원 id
    #           (+)   page:       page 번호(cf. offset)
    # Output  > (Song-Table hash) blacklist_songs on page
    def index
        me = User.find(params[:user_id])
        my_bs = me.blacklist_songs.all
        songs = []
        my_bs.each do |bs|
            a_song = Song.find(bs.song_id).as_json
            a_song["blacklist_song_id"] = bs.id
            songs << a_song
        end
        ids     = songs.map{|s| s["id"]}
        ids     = UtilController.pager(params[:page], ids).to_s
        result  = UtilController.detail_songs(ids, [], nil, true)
        render json: result
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
    
    # => (지목 삭제) DELETE   /api/blacklist_song/:id               api/blacklist_song#destroy
    # STORY   > 블랙리스트에서 특정 수록곡을 삭제
    # Input   > (url)   id:         삭제하려는 BlacklistSong의 song_id
    #           (+)     user_id:    회원 id
    # Output  > (Song-Table hash) blacklist_songs #onpage
    def destroy
        song_id = params[:id]
        me      = User.find(params[:user_id])
        @status  = "ERROR"
        @message = "INCOMPLETE PARAMETERS : 'song_id' or 'id'"
    
        unless song_id.nil? || params[:user_id].nil?
          my_bl = me.blacklist_songs
          if my_bl.where(song_id: song_id).take.nil?
            @message = "unexist blacklist song"
            return render json: {status: @status, message: @message}
          end
          bs = my_bl.where(song_id: song_id).take
          bs.delete
        else
          return render json: {status: @status, message: @message}
        end
        
        result  = me.blacklist_songs.all
        render json: result
    end
    
end
