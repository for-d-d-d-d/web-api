class Api::MySongController < ApplicationController
    
    # => (신규 생성) POST   /api/mylist/:mylist_id/my_song          api/my_song#create
    # STORY   > 마이리스트에 새로운 곡을 추가
    # Input   > (url) mylist_id:  추가될 myList ID
    #           (+)   user_id:    회원 id
    #           (+)   song_id:    추가할 song ID
    # Output  > {
    #               id:       \추가된 mySong id\, 
    #               message:  \SUCCESS or ERROR\
    #           }
    def create
        ## STAGE > function config (with input parameters)
        @check = "ERROR"
        
        # => hurdle 1) check parameters resources
        if params[:user_id].nil? || params[:mylist_id].nil? || params[:song_id].nil? # || params[:hometown].nil?
            need = ""
            need += ", :user_id"    if params[:user_id].nil?    || params[:user_id].length < 1
            need += ", :mylist_id"  if params[:mylist_id].nil?  || params[:mylist_id].length < 1
            need += ", :song_id"    if params[:song_id].nil?    || params[:song_id].length < 1
            return render json: {"id": nil, "message": @check + need}
        end
        # => hurdle 2) validity confirmation ( req USER == mylist's USER )
        if Mylist.find(params[:mylist_id]).user.id != params[:user_id].to_i
            @check = "incorrect mylist with request user"
            return render json: {"id": nil, "message": @check}
        end
        # => hurdle 3) overlap or repeat protection
        unless Mylist.find(params[:myList_id]).mylist_songs.where(song_id: params[:song_id]).take.nil?
            return render json: {"id": nil, "message": "이미 추가된 곡입니다"}
        end
        
        ## STAGE > main features (it must be available situation - after various confirmation)
        ms = MylistSong.new
        ms.mylist_id  = params[:mylist_id]
        ms.song_id    = params[:song_id]
        # ms.hometown   = params[:hometown]
        ms.save
        @check = "SUCCESS"
        
        ## STAGE > out-put publish (setting common result-rules)
        result = {"id": ms.id, "message": @check}
        render json: result
    end
    
    
    # => (유관 조회) GET    /api/mylist/:mylist_id/my_song          api/my_song#index
    # STORY   > 내 마이리스트들중 특정 마이리스트의 수록곡들를 조회
    # Input   > (url) mylist_id:  읽어들일 mylist의 id
    #           (+)   user_id:    회원 id
    #           (+)   page:       page 번호(cf. offset)
    # Output  > (Song-Table hash) my_songs on page
    # Issue   > # id외에 노래의 제목과 아티스트같은 내부데이터도 반환해줘야함.
    def index
        ## STAGE > function config (with input parameters)
        me = User.find(params[:user_id])
        UtilController.mySong_vs_blacklistSong(me.id)
        ml = Mylist.find(params[:myList_id])
        if ml.user_id == me.id
            mySongs = ml.mylist_songs
        end
        
        ## STAGE > main features (include overriding additional keys in out-put Hash)
        # => Before /override
        # result_mylistSong   = mySongs.map{|ms| ms.id}
        # result_song         = mySongs.map{|mysong| Song.find(mysong.song_id).as_json}.map{|id| Song.find(id)}
        
        # => After /override
        result_songs = []
        mySongs.each do |mysong|
            song = Song.find(mysong.song_id).as_json
            song["mySongId"] = mysong.id
            result_songs << song
        end
        
        ## STAGE > out-put publish (setting common info-rules & type)
        ids     = result_songs.to_a.map{|s| s["id"]}
        ids     = UtilController.pager(params[:page], ids).to_s
        result  = UtilController.detail_songs(ids, [], me.mytoken, true).reverse
        render json: result
    end
    
    
    # => (수정 갱신) PUT    /api/mylist/:mylist_id/my_song/:id      api/my_song#update
    # STORY   > 한 마이리스트에서 다른 마이리스트로 수록곡을 이동
    # Input   > (url)   mylist_id:      myList ID
    #           (url)   id:             수정하려는 mySong ID
    #           (+)     target_list_id: TARGET list ID
    # Output  > {
    #               id:         \변경된 mySong id\,
    #               message:    \SUCCESS or ERROR\
    #           }
    def update
        ## STAGE > function config (with input parameters)
        @check = "ERROR"
        
        # => hurdle 1) validity confirmation ( current list != target list )
        if params[:mylist_id] == params[:target_list_id]
            result = {"id": nil, "message": "같은 마이리스트 입니다."}
        end
        
        ## STAGE > main features (include overriding additional keys in out-put Hash)
        ms = MylistSong.find(params[:id]).update(mylist_id: params[:target_list_id])
        @check = "SUCCESS"
        
        ## STAGE > out-put publish (setting common result-rules)
        result = {"id": ms.id, "message": @check}
        render json: result
    end
    
    
    # => (지목 삭제) DELETE /api/mylist/:mylist_id/my_song/:id      api/my_song#destroy
    # STORY   > 마이리스트에서 특정 수록곡을 삭제
    # Input   > (url)   id:         삭제하려는 mySong ID
    #           (url)   mylist_id:  삭제하려는 mysong 이 수록된 list의 id
    #           (+)     user_id:    회원 id
    # Output  > (Song-Table hash) my_songs #onpage
    def destroy
        me = User.find(params[:user_id])
        
        unless params[:id].nil?
          ms = MylistSong.find(params[:id])
          ml = ms.mylist
          if ms.mylist.user_id == me.id
            ms.delete
          end
        end
        
        # => additional tools (you can use this code-block when you need delete certainly. you need additional one parameter 'params[:song_id]')
        # => however it need for getting parameter from android app (WRANING 'It must be modify on android side')
        unless params[:song_id].nil?
            ml = me.mylists.first
            ms = me.mylists.first.mylist_songs.where(song_id: params[:song_id]).take
            ms.delete
        end
        
        mySongs = ml.mylist_songs
        result = mySongs
        render json: result
    end
    
end
