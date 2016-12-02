class Api::MySongController < ApplicationController
    
    def create
        @check = "ERROR"
        unless params[:id].nil? || params[:myList_id].nil? || params[:song_id].nil? # || params[:hometown].nil?
          # unless Mylist.find(params[:myList_id]).mylist_songs.where(song_id: params[:song_id]).take.nil?
          unless User.find(params[:id]).mylists.first.mylist_songs.where(song_id: params[:song_id]).take.nil?
            return render json: {"id": nil, "message": "이미 추가된 곡입니다"}
          else
            ms = MylistSong.new
            ms.mylist_id  = User.find(params[:id]).mylists.first.id    # params[:myList_id]
            ms.song_id    = params[:song_id]
            #ms.hometown   = params[:hometown]
            ms.save
            @check = "SUCCESS"
          end
        end
        result = {"id": ms.id, "message": @check}
        render json: result
    end
    
    
    
    def index
        me = User.find(params[:id])
        mySong_vs_blacklistSong(me.id)
        ml = Mylist.find(params[:myList_id])
        if ml.user_id == me.id
          mySongs = ml.mylist_songs
        end
        #result_mylistSong   = mySongs.map{|ms| ms.id}
        # result_song         = mySongs.map{|mysong| Song.find(mysong.song_id).as_json}.map{|id| Song.find(id)}
        result_songs = []
        mySongs.each do |mysong|
          song = Song.find(mysong.song_id).as_json
          song["mySongId"] = mysong.id
          result_songs << song
        end
        # result = {mylistSongId: result_mylistSong, song: result_song}
        
        ids = result_songs.to_a.map{|s| s["id"]}
        ids = pager(params[:page], ids).to_s
        result = detail_songs(ids, [], me.mytoken, true).reverse
        #result = result_songs
        render json: result
            
    end
    
    
end
