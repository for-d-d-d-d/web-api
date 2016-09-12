require "bcrypt"
require 'open-uri'
class JsonController < ApplicationController
  
  def song
    @song = Song.ok.first(30)
    
    render :json => @song
  end
  
  def top100
    time = Time.zone.now.first(10).to_s
    # time = "2014-02-21"
    is_zero = ""
    is_zero = "0"  if (time.last(5).first(2).to_i - 1).to_s.length == 1
    timeEnd = time.first(10).first(8) + "01"
    time = time.first(4) + "-" + is_zero + (time.last(5).first(2).to_i - 1).to_s + "-01"
    
    @popular_top100 = DailyTjPopularRank.where(symd: time).where(eymd: timeEnd).order(song_rank: :asc)
    @song_top100 = @popular_top100.map{|s| Song.find(s.song_id)}
    
    render :json => @song_top100
  end
  
  def regist
    @check      = "ERROR"
    @mytoken    = nil
    @mylist_id  = nil
    
    user                      = params[:user]
    u = User.new
    u.email                   = user[:email]
    u.gender                  = user[:gender]
    u.name                    = user[:name]
    u.password                = user[:password]
    u.password_confirmation   = user[:password_confirmation]
    
    if User.where(email: user[:email]).count == 0
      if user[:password] == user[:password_confirmation]
        u.mytoken = SecureRandom.hex(16)
        u.save
        
        uml = Mylist.new
        uml.user_id = u.id
        uml.title   = "#{u.name}님의 첫 번째 리스트"
        uml.save
        
        @check      = "SUCCESS"
        @mytoken    = u.mytoken
        @mylist_id  = uml.id
      end
    end
    message = "#{u.password} , #{u.password_confirmation}"
    
    puts message
    render :json => {result: @check, mytoken: @mytoken}
  end
  
  def login
    @check      = "ERROR"
    @id         = "ERROR"
    @mytoken    = nil
    @mylist_id  = nil
    
    me = params[:user]
    #input_password = "nil"
    
    if me[:mytoken].nil?
      unless User.find_by_email(me[:email]).nil?
        user = User.find_by_email(me[:email])
        my_account_password = BCrypt::Password.new(user.encrypted_password)
        if my_account_password == me[:password]
          @check    = "SUCCESS"
          @id       = user.id
          @mytoken  = user.mytoken
        end
      end
    else
      user = User.where(mytoken: me[:mytoken]).take
      @check = "SUCCESS"
      @id = user.id
    end
    @mylist_id = user.mylists.first.id if user.mylists.count != 0
    render :json => {result: @check, id: @id, mytoken: @mytoken, mylist_id: @mylist_id}
  end
  
  def my_account
    
    user = {result: "ERROR", massage: "이런~ 가입부터 해달라고래!", id: nil, name: nil, gender: nil, email: nil}
    if User.where(id: params[:id]).count != 0
      me = User.find(params[:id])
      user = {result: "SUCCESS", id: me.id, name: me.name, gender: me.gender, email: me.email}
    else
      if params[:id] < User.last.id
        user = {result: "ERROR", massage: "다시 가입 해달라고래!", id: nil, name: nil, gender: nil, email: nil}
      end
    end
    
    render :json => user
  end
  
  def user_data ##회원데이터 
    user                      = params[:user]
    u                         = User.find(params[:id])
    u.email                   = user[:email]
    u.gender                  = user[:gender]
    u.name                    = user[:name]
    
    render :json => user
  end
  
  def logout ##따로 API로 정보를 던져줄게 있나??
    check = "ERROR"
    
    render :json => u
  end
  
  def img_resize
    # @example = "http://52.78.127.110/json/img_resize/1?size=100" # song.jacket_small
    @example = "http://web-yhk1038.c9users.io/json/img_resize/1?size=100" # song.jacket_small
    
    @jacket_file_real_url = Song.find(params[:id]).jacket
    @jacket_file_name = @jacket_file_real_url.split('/').last
    @custom_size = params[:size]
    render :layout => false
  end
  
  # 첫 화면
  # > 캐러셀
  def main_carousel 
    @song = Song.ok.all
    @carousel = @song.first(9)
    
    render :json => @carousel
  end
  
  # 첫 화면
  # > 인기차트
  def top_100
    @top100 = Song.ok.all.first(9) #추후에 top100에서 뽑도록 바꿀 것.
    render :json => @top100
  end
  
  # 첫 화면
  # > 이달의 신곡
  def month_new
    result = Song.ok.all.first(9) #추후 갯수 밑 신곡반영.
    render :json => result
  end
  
  # 첫 화면
  # > 조건검색
  def search_by_filter
    searched_by_since   = Song.ok.all
    searched_by_gender  = Song.ok.all
    searched_by_genre   = Song.ok.all
    searched_by_nation  = Song.ok.all
    
    unless params[:since].nil? || params[:since].length == 0
      searched_by_since = []
      since = params[:since]
      since_start = since.first(4).to_i
      since_end   = since.last(4).to_i
      
      since_start.upto(since_end) do |year|
        puts year
        Song.ok.all.each do |song|
          if song.album.released_date.to_s.first(4).to_i == year
            searched_by_since << song
            puts "현재 since 개수 : #{searched_by_since.count}\n"
          end
        end
      end
    end
    
    unless params[:gender].nil? || params[:gender].length == 0
      searched_by_gender = []
      gender = params[:gender]
      
      #searched_by_since.each do ||
    end
    
    unless params[:genre].nil? || params[:genre].length == 0
      searched_by_genre = []
      genre = params[:genre]
      puts "장르는 #{genre}"
      searched_by_since.each do |song|
        puts "반복 잘 되니 #{song.genre1}, #{song.genre2}, #{song.album.genre1}, #{song.album.genre2}"
        if song.genre1 == genre || song.genre2 == genre || song.album.genre1 == genre || song.album.genre2 == genre
          searched_by_genre << song
          puts "현재 genre 개수 : #{searched_by_genre.count}" 
        end
      end
      
      searched_by_genre = searched_by_genre.uniq
    end
    
    unless params[:nation].nil? || params[:nation].length == 0
      #searched_by_genre
    end
    
    result = []
    # result << searched_by_since
    # result << searched_by_gender
    result << searched_by_genre
    # result << searched_by_nation
    render :json => result  
  end
  
  # 검색창(검색결과)
  def search
    artist = []
    title  = []
    lyrics = []
    artist, title, lyrics = HomeController.search3(params[:query])

    result = {"artist": artist, "title": title, "lyrics": lyrics}
    render json: result
  end

  def search_by_artist
    artist = []
    
    artist = HomeController.search3_by_artist(params[:query])

    result = artist
    render json: result

  end

  def search_by_title
    title = []
    
    title = HomeController.search3_by_title(params[:query])

    result = title
    render json: result

  end

  def search_by_lyrics
    lyrics = []
    
    lyrics = HomeController.search3_by_lyrics(params[:query])

    result = lyrics
    render json: result

  end
  
    
  
  
  # myList CRUD > CREATE
  # method : POST
  # Input   > id: 회원 id (+) title: myList 타이틀
  # Output  > id: 생성된 myList id (+) message: SUCCESS or ERROR
  def myList_create
    @check = "ERROR"
    unless params[:id].nil? || params[:title].nil?
      ml = Mylist.new
      ml.user_id  = params[:id]
      ml.title    = params[:title]
      ml.save
      @check = "SUCCESS"
    end
    result = {"id": ml.id, "message": @check}
    render json: result
  end
  
  # myList CRUD > READ
  # method : POST
  # Input   > id: 회원 id
  # Output  > 내 myList.all
  def myList_read
    me = User.find(params[:id])
    result = me.mylists
    render json: result
  end
  
  # myList CRUD > UPDATE
  # method : POST
  # Input   > id: 회원 id (+) myList_id: 수정하려는 myList ID (+) title: 수정하려는 myList 타이틀
  # Output  > id: 변경된 myList id (+) message: SUCCESS or ERROR
  def myList_update
    @check = "ERROR"
    unless params[:id].nil? || params[:myList_id].nil? || params[:title].nil?
      ml = Mylist.find(params[:myList_id])
      if ml.user_id == params[:id]          # => 안전성 검사. 내 계정의 ID와 요청한 myList의 user_id가 같은지 확인.
        ml.title  = params[:title]
        ml.save
        @check = "SUCCESS"
      end
    end
    result = {"id": ml.id, "message": @check}
    render json: result
  end
  
  # myList CRUD > DELETE
  # method : POST
  # Input   > id: 회원 id (+) myList_id: 삭제하려는 myList ID
  # Output  > id: 내 myList.all
  def myList_delete
    me = User.find(params[:id])
    unless params[:myList_id].nil?
      ml = Mylist.find(params[:myList_id])
      if ml.user_id == me.id
        ml.delete
      end
    end
    result = me.mylists
    render json: result
  end
  
  # mySong CRUD > CREATE
  # method : POST
  # Input   > id: 회원 id (+) myList_id: 추가될 myList ID (+) song_id: 추가할 song ID
  # Output  > id: 추가된 mySong ID (+) message: SUCCESS or ERROR
  def mySong_create
    @check = "ERROR"
    unless params[:id].nil? || params[:myList_id].nil? || params[:song_id].nil?
      ms = MylistSong.new
      ms.mylist_id  = params[:myList_id]
      ms.song_id    = params[:song_id]
      ms.save
      @check = "SUCCESS"
    end
    result = {"id": ms.id, "message": @check}
    render json: result
  end
  
  # mySong CRUD > READ
  # method : POST
  # Input   > id: 회원 id (+) myList_id: 읽어들일 myList ID
  # Output  > 내 mySong.all
  def mySong_read ##id외에 노래의 제목과 아티스트같은 내부데이터도 반환해줘야함.
    me = User.find(params[:id])
    ml = Mylist.find(params[:myList_id])
    if ml.user_id == me.id
      mySongs = ml.mylist_songs
    end
    result_mylistSong   = mySongs.map{|ms| ms.id}
    result_song         = mySongs.map{|mysong| mysong.song_id}.map{|id| Song.find(id)}
    result_artist       = result_song.map{|song| song.artist}.map{|artist| artist.name}
    result = {mylistSongId: result_mylistSong, song: result_song, artistName: result_artist}
    puts "#{result}"
    render json: result
  end
  
  # mySong CRUD > UPDATE
  # method : POST
  # Input   > id: 회원 id (+) myList_id: myList ID (+) targetList_id: TARGET list ID (+) mySong_id: 수정하려는 mySong ID
  # Output  > id: 변경된 mySong id (+) message: SUCCESS or ERROR
  def mySong_update
    @check = "ERROR"
    if params[:myList_id] != params[:targetList_id]
      ms = MylistSong.find(params[:mySong_id])
      ms.mylist_id = params[:targetList_id]
      ms.save
      @check = "SUCCESS"
    end
    result = {"id": ms.id, "message": @check}
    render json: result
  end
  
  # mySong CRUD > DELETE
  # method : POST
  # Input   > id: 회원 id (+) mySong_id: 삭제하려는 mySong ID
  # Output  > 내 mySong.all
  def mySong_delete
    me = User.find(params[:id])
    unless params[:mySong_id].nil?
      ms = MylistSong.find(params[:mySong_id])
      ml = ms.mylist
      if ms.mylist.user_id == me.id
        ms.delete
      end
    end
    mySongs = ml.mylist_songs
    result = mySongs
    render json: result
  end
  
  # Recommender
  # method : POST, GET
  # Input   > id: 회원 id
  # Output  > 추천 Song Data
  def recom

    recomC = RecommendationController.new
    sing_it = recomC.recommend(params[:id])
    render json: sing_it
  end
  

  def blacklist_song_create
    @check = "ERROR"
    
    unless params[:id].nil? || params[:song_id].nil?
      bs = BlacklistSong.new
      bs.song_id  = params[:song_id]
      bs.user_id  = params[:id]
      bs.save
      @check = "SUCCESS"
    end
    result = {"id": bs.id, "message": @check}
    render json: result 
  end
  # blacklistsong CRUD > READ
  # method : POST
  # Input   > id: 회원 id 
  # Output  > blacklist_songs: 해당 회원의 차단된 노래들
  
  def blacklist_song_read
    me = User.find(params[:id])
    my_bs = me.blacklist_songs.all
    result = my_bs
    
    render json: result
  end
  
  # blacklistsong CRUD > DELETE
  # method : POST
  # Input   > id: 회원 id, 차단해지 하려는 노래의 blacklist_songs.id
  # Output  > blacklist_songs: 해당 회원의 차단된 노래들
  def blacklist_song_delete
    me = User.find(params[:id]) 
    bs = BlacklistSong.find(params[:blacklist_songs.id])
    unless params[:blacklist_songs.id].nil? || params[:user_id].nil?
      bs.delete
    end
    result = me.blacklist_songs.all
    render json: result
  end
  
  # 개인정보변경(devise문제로 비밀번호 변경은 추후에 추가예정) 
  # method : POST
  # Input   > id: 회원 id 
  # Output  > 수정된 닉네임, 수정된 성별, 수정된 생일
  def modify_userdata
    @check = "ERROR"
    client = params[:user]
                                                          # "paramethers" :  
                                                          #   {
                                                          #     
                                                          #     "user" : {
                                                          #       "id" : "some number",
                                                          #       "modified_name" : "something",
                                                          #       "modified_birthdate" : "something",
                                                          #       "modified_gender" : "something"
                                                          #     "authNum" : ""
                                                          #  
    me = User.find(client[:id])
    me.name = client[:modified_name]
    me.gender = client[:modified_gender]
    me.birthdate = client[:modified_birthdate]
    me.save
    @check = "SUCCESS"
                                                          # user[id]
                                                          # user[modified_name]
                                                          # user[modified_gender]
                                                          # user[modified_birthdate]
                                                          # authNum
    
    
    result = {"message": @check}
     
    render json: result 
  end
  
  def delete_account
    client = params[:user]
    me = User.find(client[:id])
    
    me.delete
    
  end
    
  def db_call
      url = 'http://52.78.146.161/seeds/seeds.rb'
      data = open(url).read
      send_data data, :disposition => 'attachment', :filename => 'seeds.rb'
    
    @file = 'true'
    render json: @file 
  end
end
