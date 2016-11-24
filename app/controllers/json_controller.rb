require "bcrypt"
require 'open-uri'
class JsonController < ApplicationController

  SERVER_URL = "http://52.78.160.188"

  def main_banner
    # size = 500
    # unless params[:size].nil?
    #   size = params[:size]
    # end
    # img_url = SERVER_URL + "/json/img_resize?size=#{size}&url=#{origin_img_link}"
    
    contents = $contents

    banner  = []
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

  def song
    
    #@song = Song.tj_ok.all
    @song = Song.popular_month
    
    #
    # [pager]
    unless params[:page].nil?
        @song = pager(params[:page], @song)
        if @song.nil?
            return render json: [{}]
        end
    end

    #
    # [ready 'id' array of songs for input 'detail_song()' function]
    ids = @song.map{|song| song.id}.to_s
    unless params[:ids].nil?
      ids = params[:ids].to_s.delete('[').delete(']').delete(' ')
    end
    
    #
    # [ready 'column'. It is attributes that is permitted to contain in returned json result.]
    # [when the 'column' is nil or empty, then 'column' defines all of attributes.)]
    column = Song.attribute_names
    unless params[:column].nil? || params[:column].to_s.length == 0
       column = params[:column].to_s.delete('[').delete(']').delete(' ').split(',')
    end
    exclude = Song.attribute_names - column

    #
    # [ready 'mylist_count'. In this block, it recognizes wheter the client wants to recieve the data of mylist_count or not.]
    mylist_count = false
    if params[:mylist_count] != nil && params[:mylist_count] == "true"
        mylist_count = true
    end

    songs = detail_songs(ids, exclude, params[:mytoken], mylist_count)

    render :json => songs
  end
  
  def top100
    @song = Song.popular_month
    # @song = Song.all.sample(100) #tj_ok.where("genre2 LIKE ?", "%힙합%")
    # result = @song_top100
    # result = Song.tj_ok.first(30)

    #page = 1
    #unless params[:page].nil?
    #   page = params[:page].to_i
    #   page = 1 if page == 0
    #   if page > 4
    #     return render json: [{}]
    #   end
    #end
    #@song = Song.tj_ok.first(100 * page).last(100)
    #@song = pager(params[:page], @song)

    column = Song.attribute_names
    unless params[:column].nil? || params[:column].to_s.length == 0
      column = params[:column].to_s.delete('[').delete(']').delete(' ').split(',')
    end

    ids = @song.map{|song| song.id}
    ids = filtering_blacklistSongs_from_list(ids, User.where(mytoken: params[:mytoken]).take.id)
    ids = pager(params[:page], ids).to_s

    exclude = Song.attribute_names - column
    result = detail_songs(ids, exclude, params[:mytoken], true)

    render :json => result
  end
  
  # function
  def check_email(email)
    @email_format = Regexp.new(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/)
    @email_format.match(email.to_s.strip)    
  end

  # USER : CREATE
  def regist
    @check      = "ERROR"
    @status     = "400 BAD REQUEST"
    @massage    = nil
    @mytoken    = nil
    @mylist_id  = nil
    
    unless params[:user].nil?
      user                      = params[:user]
    else
      @massage = "회원 정보를 입력해주세요"
      return render json: {result: @check, status: @status, massage: @massage}
    end
    
    u = User.new
    req_user_info = ["email", "password", "password_confirmation"]
    req_user_info.each do |attribute|
      x = nil
      eval("x = user[:#{attribute}]")
      if x.nil?
        @massage = "#{attribute}을(를) 입력해주세요"
        return render json: {result: @check, status: @status, massage: @massage}
      else
        eval( "u.#{attribute} = user[:#{attribute}]")
        u.name = ""
        u.gender = 0
      end
    end
    if check_email(u.email) != nil                             # 1.이메일 형식 체크
      if User.where(email: user[:email]).count == 0            # 2.기존 회원인지 여부 체크
        if user[:password].to_s.length >= 6                    # 3.비번 자릿수 체크
          if user[:password] == user[:password_confirmation]   # 4.비번 == 비번확인 체크
            u.mytoken = SecureRandom.hex(16)
            u.save
            
            uml = Mylist.new
            uml.user_id = u.id
            uml.title   = "#{u.name}님의 첫 번째 리스트"
            uml.save
            
            @check      = "SUCCESS"
            @mytoken    = u.mytoken
            @mylist_id  = uml.id
            @my_id      = u.id 
          else
            @massage = "Incorrect Confirmation! Please Check your context, password confirmation"
            return render json: {result: @check, status: @status, massage: @massage}
          end
        else # 3.비번 자릿수가 맞지 않을 때
          @massage = "Oops! Too Short Password :( .. (at least 6 characters)"
          return render json: {result: @check, status: @status, massage: @massage}
        end
      else # 2.기존 회원 중에 같은 이메일이 존재할 때
        @massage = "Oops! This Email is Already Exist! (#{user[:email]})"
        return render json: {result: @check, status: @status, massage: @massage}
      end
    else # 1.이메일 형식에 맞지 않을 때
      @massage = "Oops! Please Check your Email Format! (ex. blah@blah.blah)"
      return render json: {result: @check, status: @status, massage: @massage}
    end
    message = "#{u.password} , #{u.password_confirmation}"
    
    puts message
    render :json => {result: @check, mytoken: @mytoken, myid: @my_id, mylist_id: @mylist_id}
  end
  
  # USER   : ENTER account with minimal info
  # method : POST
  # INPUT       > parameters : {
  #                       user : {
  #                           mytoken         : (마이토큰) / 토큰이 있는 경우, 자동로그인 pass
  #                             or 
  #                           email           : (이메일로그인) / 토큰이 없는경우, 수동 로그인
  #                           password        : (비밀번호)
  #                       }
  #               }
  # OUTPUT      > 성공시 {
  #                 result      : (성공여부),
  #                 mytoken     : (내 토큰정보),
  #                 id          : (내 회원 고유번호),
  #                 mylist_id   : (마이리스트 고유번호)
  #               },
  #               실패시 {
  #                 result      : (성공여부),
  #                 status      : (에러상태),
  #                 massage     : (에러사유)
  #               }
  # ERROR case
  #     1. input parameter가 없을 때
  #     2. 수동 로그인 > 이메일이 없을 때
  #     3. 수동 로그인 > 이메일이 형식에 맞지않을 때
  #     4. 수동 로그인 > 비밀번호가 입력되지 않았을 때
  #     5. 수동 로그인 > 비밀번호가 올바르지 않을 때
  #     6. 자동 로그인 > 존재하지 않는 토큰이 입력되었을 때
  def login
    @check      = "ERROR"
    @status     = "400 BAD REQUEST"
    @massage    = nil

    @id         = "ERROR"
    @mytoken    = nil
    @mylist_id  = nil
    
    unless params[:user].nil?
      me = params[:user]
    else                                        # 차단1. 회원정보가 전혀 입력되지 않음
      @massage = "회원 정보를 입력해주세요"
      return render json: {result: @check, status: @status, message: @massage}
    end
    
    if me[:mytoken].nil?    # 로그인시 토큰이 없다(== 토큰만료. 자동로그인 불가. >> 재로그인)
      if me[:email].nil?                        # 차단2. user[email]이 입력되지 않음
        @massage = "email을 입력해주세요"
        return render json: {result: @check, status: @status, message: @massage}
      elsif check_email(me[:email]) == nil      # 차단3. email이 형식에 맞지 않음
        @massage = "Oops! Please Check your Email Format! (ex. blah@blah.blah)"
        return render json: {result: @check, status: @status, message: @massage}
      elsif me[:password].nil?                  # 차단4. password가 입력되지 않음
        @massage = "password을(를) 입력해주세요"
        return render json: {result: @check, status: @status, message: @massage}
      end
      
      unless User.find_by_email(me[:email]).nil?
        user = User.find_by_email(me[:email])
        my_account_password = BCrypt::Password.new(user.encrypted_password)
        if my_account_password == me[:password]
          @check    = "SUCCESS"
          @id       = user.id
          @mytoken  = user.mytoken
        else                                    # 차단5. password가 맞지 않음
          @massage = "Incorrect Password! Please Check your password!"
          return render json: {result: @check, status: @status, message: @massage}
        end
      else                                      # 차단6. 가입되지 않은 email
        @massage = "Oops! Please Check your Email! It's not registed account email :("
        return render json: {result: @check, status: @status, message: @massage}
      end
    else                    # 토큰 있는 로그인(== 자동로그인.)
      user = User.where(mytoken: me[:mytoken]).take
      if user.nil?                              # 차단7. 저장되지 않은 토큰으로 로그인 시도.
        @massage = "잘못된 로그인 시도입니다. 다시 로그인해주세요"
        return render json: {result: @check, status: @status, message: @massage}
      end
      @check = "SUCCESS"
      @id = user.id
    end
    @mylist_id = user.mylists.first.id if user.mylists.count != 0
    render :json => {result: @check, mytoken: @mytoken, id: @id, mylist_id: @mylist_id}
  end
  
  # USER   : READ accout more detail
  # method : POST
  # INPUT   > parameters : {
  #             mytoken             : (회원 토큰) 
  #                         or
  #             id                  : (회원 id)
  #           }
  # OUTPUT  > {
  #             result              : (성공여부),
  #             message             : (참고 메세지),
  #             name                : (회원이름),
  #             gender              : (성별),
  #             email               : (가입 이메일),
  #             profile_img_origin  : (프사 원본주소),
  #             profile_img_400     : (프사 썸네일주소),
  #             mylist_id           : (내 마이리스트 id)
  #           }
  def my_account
    user = {result: "ERROR", message: "이런~ 가입부터 해달라고래!", name: nil, gender: nil, email: nil}
    if params[:mytoken] != nil
      me = User.where(mytoken: params[:mytoken]).take
    elsif params[:id] != nil
      me = User.find(params[:id])
    end
    if me != nil
      gender = 0 # "없음"
      if me.gender == 1
        gender = 1 # "남성"
      elsif me.gender == 2
        gender = 2 # "여성"
      elsif me.gender == 3
        gender = 3 # "무관"
      end
      
      # [no-name_profile-img : 나중에 S3로 연동해야 함]
      size = 150
      # origin_img_link = "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/logover3-300x300.png"
      # img_url = SERVER_URL + "/json/img_resize?size=#{size}&url=#{origin_img_link}"
      img_origin_url = "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/logover3.png"
      img_400_url = "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/logover3-1-e1475689170577.png"
      
      user = {
                 result: "SUCCESS", 
                 message: "#{me.name}님의 회원정보", 
                 name: me.name, 
                 gender: gender, 
                 email: me.email, 
                 profile_img_origin: img_origin_url, 
                 profile_img_400: img_400_url,
                 mylist_id: me.mylists.first.id
             }
    else
      user = {result: "ERROR", message: "다시 가입 해달라고래!", name: nil, gender: nil, email: nil}
    end
    
    render :json => user
  end

  # USER   : UPDATE accout
  # method : PUT
  # INPUT   > parameters : {
  #                 mytoken
  #                 mod
  #                 user: { 
  #                     name
  #                     gender
  #                 },
  #                 password(x => current_password)
  #                 password_confirm(x => new_password_confirm)
  #                 new_password
  #             }
  # OUTPUT  > {
  #             result          : (성공여부),
  #             message         : (참고메세지),
  #             name            : (-변경된- 이름),
  #             gender          : (-변경된- 성별),
  #             email           : (이메일-변경불가-),
  #             mytoken         : (토큰)
  #           }
  def user_modify
    error = {result: "ERROR", message: "this is default error message", name: nil, gender: nil, email: nil, mytoken: nil}

    if params[:mytoken].nil?
        error[:message] = "please login first"
        return render json: error
    end

    user = User.where(mytoken: params[:mytoken]).take unless params[:mytoken].nil?

    if user.nil?
        error[:message] = "incorrect token, please check your 'mytoken', Did you singed up?"
        return render json: error
    end
    
    if params[:user].nil?
        error[:message] = "you may loose your parameters 'user[something]'"
        return render json: error
    end
    
    unless params[:new_password].nil? || params[:new_password_confirm].nil?
        if params[:new_password] == params[:new_password_confirm]
            if params[:current_password] == BCrypt::Password.new(user.encrypted_password)
                user.password = params[:new_paaword]
                user.save
            else
                error[:message] = "현재 비밀번호가 일치하지 않습니다"
                return render json: error
            end
        else
            error[:message] = "새 비밀번호가 확인과 일치하지 않습니다"
            return render json: error
        end
    end

    user.update(params.require(:user).permit(:name, :gender)) unless params[:user].nil?

    #arr = ['name','email']
    #arr.each do |a|
    #    eval("user.#{a} = params[:#{a}] unless params[:#{a}].nil?")
    #end
    #user.save

    render :json => {result: "SUCCESS", message: "your account successfuly updated!", name: user.name, gender: user.gender, email: user.email, mytoken: user.mytoken}
  end
  
  def img_resize
    # @example = "http://52.78.127.110/json/img_resize/1?size=100" # song.jacket_small
    # @example = "http://web-yhk1038.c9users.io/json/img_resize/1?size=100" # song.jacket_small

    unless params[:id].nil?
      url = Song.find(params[:id]).jacket
    end

    unless params[:url].nil?
      url = params[:url]
    end

    @jacket_file_real_url = url
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
    month_new_songs = []
    Time.zone.now
    Song.tj_ok.each do |song| #추후 갯수 밑 신곡반영.
        if song.created_at.to_s.first(10) == (Time.zone.now.to_s.first(8) + "01")
            month_new_songs << song
        end
    end

    return render :json => [] if params[:mytoken].nil? || params[:mytoken].length < 1
    ids = month_new_songs.map{|s| s.id}
    ids = filtering_blacklistSongs_from_list(ids, User.where(mytoken: params[:mytoken]).take.id)
    ids = pager(params[:page], ids).to_s
    result = detail_songs(ids, [], params[:mytoken], true)
    render :json => result
  end
  
  # 첫 화면
  # > 조건검색
  def search_by_filter
    whole_song = Song.tj_ok.map{|song| song.id}.uniq
    mytoken = params[:mytoken] 
    searched_by_since   = whole_song
    searched_by_gender  = whole_song
    searched_by_genre   = whole_song
    searched_by_nation  = whole_song
    
    unless params[:since].nil? || params[:since].length == 0
      searched_by_since = []
      since = params[:since]    # since = 2000 ~ 2005
      since_start = since.first(4).to_i
      since_end   = since.last(4).to_i
      
      album_ids = Album.where(:released_date => since_start..since_end).all.map{|album| album.id}
      searched_by_since = Song.where(album_id: album_ids).tj_ok
      searched_by_since = searched_by_since.map{|song| song.id}.uniq.sort
    end
    
    unless params[:gender].nil? || params[:gender].length == 0      
      gender = params[:gender]
      
      if gender == "남성"
        searched_by_gender = []
        gender = 1
      elsif gender == "여성"
        searched_by_gender = []
        gender = 2
      elsif gender == "혼성"
        searched_by_gender = []
        gender = 4
      end

      artists = []
      if gender.class == Fixnum
        singer_ids = Singer.where("gender LIKE ?", gender).all.map{|singer| singer.id}
        team_ids = Team.where("gender LIKE ?", gender).all.map{|team| team.id}
        searched_by_gender = Song.where(singer_id: singer_ids) + Song.where(team_id: team_ids)
        searched_by_gender = searched_by_gender.map{|song| song.id}.uniq.sort
      end
    end
    
    unless params[:genre].nil? || params[:genre].length == 0
      searched_by_genre = []
      genre = params[:genre]

      searched_by_genre = Song.tj_ok.where("genre1 LIKE ?", "%#{genre}%") + Song.tj_ok.where("genre2 LIKE ?", "%#{genre}%")
      searched_by_genre = searched_by_genre.map{|song| song.id}
      searched_by_genre = searched_by_genre.uniq
    end
    
    unless params[:nation].nil? || params[:nation].length == 0
      searched_by_nation = searched_by_nation
    end
    
    column = Song.attribute_names
    unless params[:column].nil? || params[:column].to_s.length == 0
      column = params[:column].to_s.delete('[').delete(']').delete(' ').split(',')
    end
    exclude = Song.attribute_names - column
    result_ids = searched_by_since & searched_by_gender & searched_by_genre & searched_by_nation
    result = detail_songs(result_ids, exclude, mytoken, true)
    render :json => result  
  end
  
  # 검색창(검색결과)
  def search_nomal
    artist = []
    title  = []
    lyrics = []
    artist, title, lyrics = HomeController.search3(params[:query])

    result = {"artist": artist, "title": title, "lyrics": lyrics}
    render json: result
  end

  #
  # UTIL > pager
  def pager(page, arr)
    limit   = 30
    if page == "-1"|| page == nil
        page = 0
    else
        page    = page.to_i
        page    = page unless page.nil?
        page    = 1 if page == 0
    end

    if page == 0
        arr = arr
    else
        arr = arr[(limit * (page - 1))..((limit * page)-1)]
    end
    return arr
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
    
    #
    # remove hateSong
    ids = filtering_blacklistSongs_from_list(ids, User.where(mytoken: mytoken).take.id)

    #
    # Pager
    ids = pager(params[:page], ids)

    result = detail_songs(ids, [], mytoken, true)
    render json: result

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
    songs2 = (filtered_genre + filtered_age + filtered_gender).uniq
    ids = songs2.map{|s| s.id}
    ids = pager(params[:page], ids)

    render json: detail_songs(ids, [], params[:mytoken], true)
  end

  # myList CRUD > CREATE
  # method : POST
  # Input   > id: 회원 id (+) title: myList 타이틀
  # Output  > id: 생성된 myList id (+) message: SUCCESS or ERROR
  def myList_create
    @check = "ERROR"
    unless params[:id].nil? || params[:title].nil?
      if User.find(params[:id]).nil?
        return render json: {"check": @check, "id": "NULL", "status": "400 BAD REQUEST", "message": "사용자를 찾을 수 없습니다"}
      end
      ml = Mylist.new
      ml.user_id  = params[:id]
      ml.title    = params[:title]
      ml.save
      @check = "SUCCESS"
    else
      return render json: {"check": @check, "id": "NULL", "status": "400 BAD REQUEST", "message":     "사용자를 찾을 수 없습니다"}
    end
    result = {"id": ml.id, "check": @check}
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
  
  def mySong_vs_blacklistSong(me_id)
    me = User.find(me_id)
    mySongs = me.mylists.first.mylist_songs
    blSongs = me.blacklist_songs
    blSongs.each do |bl|
        same_mySong = mySongs.where(song_id: bl.song_id).take
        if same_mySong.nil?
            next
        else
            if same_mySong.created_at.to_s < bl.created_at.to_s
                same_mySong.delete
            else
                bl.delete
            end
        end
    end
    return true
  end

  def filtering_blacklistSongs_from_list(ids, myid)
    me = User.find(myid)
    bl_ids = me.blacklist_songs.map{|s| s.song_id}
    ids = ids - bl_ids
    return ids
  end

  # mySong CRUD > CREATE
  # method : POST
  # Input   > id: 회원 id (+) myList_id: 추가될 myList ID (+) song_id: 추가할 song ID
  # Output  > id: 추가된 mySong ID (+) message: SUCCESS or ERROR
  def mySong_create
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

  def mySong_read_1 ##id외에 노래의 제목과 아티스트같은 내부데이터도 반환해줘야함.
    me = User.find(params[:id])
    mySong_vs_blacklistSong(me.id)
    ml = Mylist.find(params[:myList_id])
    if ml.user_id == me.id
      mySongs = ml.mylist_songs
    end
    result_mylistSong   = mySongs.map{|ms| ms.id}
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
    unless params[:song_id].nil?
        ml = me.mylists.first
        ms = me.mylists.first.mylist_songs.where(song_id: params[:song_id]).take
        ms.delete
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
    sing_it = RecommendationController.recommend(params[:id])
    #count = ForAnalyze.find(1) # 추천 받을 때 마다 분석정보를 담는 DB에 총추천횟수를 1씩 올려줌.
    #count.count_recomm +=1
    #count.save
    ids = sing_it.map{|s| s.id}
    ids = filtering_blacklistSongs_from_list(ids, params[:id])
    ids = pager(params[:page], ids).to_s
    result = detail_songs(ids, [], User.find(params[:id]).mytoken, true)
    render json: result
  end
    

  def blacklist_song_create
    @check = "ERROR"
    
    unless params[:id].nil? || params[:song_id].nil?
        if User.find(params[:id]).blacklist_songs.where(song_id: params[:song_id]).count != 0
            return render json: {status: @check, message: "이미 차단 설정된 노래입니다"}
        end
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
    songs = []
    my_bs.each do |bs|
        a_song = Song.find(bs.song_id).as_json
        a_song["blacklist_song_id"] = bs.id
        songs << a_song
    end
    ids = songs.map{|s| s["id"]}
    ids = pager(params[:page], ids).to_s
    result = detail_songs(ids, [], nil, true)

    render json: result
  end
  
  # blacklistsong CRUD > DELETE
  # method : POST
  # Input   > id: 회원 id, 차단해지 하려는 노래의 blacklist_song_id
  # Output  > blacklist_songs: 해당 회원의 차단된 노래들
  def blacklist_song_delete
    @status = "ERROR"
    @message = "INCOMPLETE PARAMETERS : 'song_id' or 'id'"

    unless params[:song_id].nil? || params[:id].nil?
      my_bl = BlacklistSong.where(user_id: params[:id])
      if my_bl.where(song_id: params[:song_id]).take.nil?
        @message = "unexist blacklist song"
        return render json: {status: @status, message: @message}
      end
      bs = my_bl.where(song_id: params[:song_id]).take
      bs.delete
    else
      return render json: {status: @status, message: @message}
    end
    
    me = User.find(params[:id])
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

  # fn() INFO
  # description : 문자열 형태로 전달되는 각종 ID값들의 배열을 배열로 변환하는 함수.
  # 1. id값으로 매핑된 문자열만 입력값으로 허용.
  # 2. 매핑된 문자열을 배열 형태로 변환.
  # 3. id값은 반드시 임의의 숫자형태일 것.
  # 4. ex) 가능한 입력형식
  #             "[1,2,3]" / "1,2,3" / "[1, 2, 3]"
  #        불가능한 입력형식
  #             "['1','2','3']" / '["1","2","3"]' / "[\"1\",\"2\",\"3\"]"
  # 5. 권장사항
  #     - int형 element들을 담은 배열을 그대로 문자열로 변환한 형태가 최적의 입력형태.
  def mapped_string_translater_to_array(string)
        str0 = string.delete(' ')
        arr0 = str0.split('')
        arr0.shift      if arr0.first == '['
        arr0.pop        if arr0.last  == ']'
        str1 = arr0.join
        arr1 = str1.split(',')
        arr2 = arr1.map{|el| el.to_i}   # 임시 제외 => .map{|el| nil if el == 0}.compact
        result = arr2
        
        return result
  end

  # fn() INFO
  # description : 노래 레코드에 대한 상세정보를 선택적으로 반환하는 함수. 
  # why         : 매번 레코드 정보를 전부 리턴하는 낭비를 방지
  # INPUT       : ids : SongTable의 주key인 id값들을 요소로하는 배열을 문자열 형태로 입력. 
  #               exclude : 레코드 속성중에 제거하고자 하는 불필요한 속성들. Array형태로 입력. 
  #               mytoken : 사용자 토큰(str)
  #               mylist_count : true or false
  # - case      : ids : "[1,2,3]" / "1,2,3" / "[1, 2, 3]" 세가지 형태가 가능하며, 첫 번째 형태를 권장.
  #               exclude : {
  #                     "없을때" : (arrayType) [],
  #                     "1개 이상 존재" : (arrayType) ["", "", ... , ""]
  #                     }
  # OUTPUT      : fn() returns records with hashType for the SongTable.
  def detail_songs(ids, exclude, mytoken, mylist_count)
        ids = ids.to_s if ids.class != String
        song_ids = mapped_string_translater_to_array(ids)
        songs = song_ids.map{|song_id| Song.find(song_id)}
        
        default = ["created_at","updated_at","youtube","lowkey","highkey","jacket","jacket_middle","jacket_small","song_num"]
        will_exclude = default + exclude unless exclude == "nil" || exclude == nil || exclude.class != Array
        will_exclude = will_exclude.uniq
        
        attributes = []
        Song.attribute_names.each do |an|
            attributes << an unless will_exclude.include?(an)
        end

        result = []
        songs.each do |song|
            arr = []
            attributes.each do |att|
                eval("arr << [att, song.#{att}]")
                if att == "jacket"
                    if song.jacket.nil?
                        
                    elsif song.jacket == "Error::ThisMusickCanNotFind"
                    end
                end
            end

            if song.song_num.nil?
                arr << ["song_num", 0]
            else
                arr << ["song_num", song.song_num]
            end
            if song.jacket.nil?
                arr << ["jacket", $noReadyJacket_600]
                arr << ["jacket_middle", $noReadyJacket_200]
                arr << ["jacket_small", $noReadyJacket_100]
            elsif song.jacket == "Error::ThisMusickCanNotFind"
                arr << ["jacket", $noReadyJacket_600]
                arr << ["jacket_middle", $noReadyJacket_200]
                arr << ["jacket_small", $noReadyJacket_100]
            else
                arr << ["jacket", song.jacket]
                arr << ["jacket_middle", song.jacket_middle]
                arr << ["jacket_small", song.jacket_small]
            end
            
            if song.album.nil?
                arr << ["release", "세팅 대기중인 곡입니다"]
            else
                release = song.album.released_date.split('')
                release.pop
                release = release.join
                arr << ["release", release]
            end

            is_my_favorite = false
            unless mytoken.nil?
                me = User.where(mytoken: mytoken).take
                mySongs = me.my_songs.map{|ms| ms.id}
                is_my_favorite = true if mySongs.include?(song.id)
                maybe_mysong = me.mylists.first.mylist_songs.where(song_id: song.id).take
            end
            arr << ["is_my_favorite", is_my_favorite]
            
            if mylist_count == true
                ml_count = MylistSong.where(song_id: song.id).map{|ms| ms.mylist.user}.uniq.count
                arr << ["mylist_count", ml_count]
            end
            result << [song.id, arr.to_h]
        end
        result = result.to_h.to_a.each{|s| s.shift}.flatten

        return result
  end

  def temp(arr)
        #arr.each do 
        return arr
  end
end
