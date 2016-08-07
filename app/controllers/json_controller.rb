class JsonController < ApplicationController
  
  def song
    @song = Song.ok.all
    
    render :json => @song
  end
  
  def regist
    @check = "ERROR"
    @id    = "ERROR"
    
    user                      = params[:user]
    u = User.new
    u.email                   = user[:email]
    u.gender                  = user[:gender]
    u.name                    = user[:name]
    u.password                = user[:password]
    u.password_confirmation   = user[:password_confirmation]
    
    if User.where(email: user[:email]).count == 0
      if user[:password] == user[:password_confirmation]
        u.save
        @check = "SUCCESS"
        @id = u.id
      end
    end
    message = "#{u.password} , #{u.password_confirmation}"
    
    puts message
    render :json => {result: @check, id: @id}
  end
  
  def login
    @check = "ERROR"
    @id    = "ERROR"
    me = params[:user]
    #input_password = "nil"
    
    unless User.find_by_email(me[:email]).nil?
      
      user = User.find_by_email(me[:email])
      my_account_password = BCrypt::Password.new(user.encrypted_password)
      puts my_account_password
      
      if user.encrypted_password == me[:password]
        @check = "SUCCESS"
        @id = user.id
      end
    end
    
    message = "@check = #{@check}, @id = #{@id}"
    puts message
    render :json => {result: @check, id: @id}
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
  
  def search
    artist = []
    title = []
    lyrics = []
    homeC = HomeController.new
    artist, title, lyrics = homeC.search3(params[:query])
    result = {"artist": artist, "title": title, "lyrics": lyrics}
    render json: result
  end
  
  def recom
    
    #
    # => Initailizer SET
    ##########################
    
    users = []
    me = []
    it_looks_like_your_favorite_song = []
    low_limit = 4   #    N 개
    high_limit = 10 #    N 개
    favor_rate = 50 #    N %
    
    
    #
    # => TEMP USER SET
    ##########################
    
    user1 = ('1'..'20').to_a
    user2 = ['1','2','3','4','5','6','7','8','9','10']
    user3 = ['1',    '3',    '5',    '7',    '9']
    user4 = ['1','2','3','4','5','6','95']
    user5 = [                    '6','7','8','9','10']
    user6 = [    '2',    '4',    '6',    '8',    '10']
    user7 = ['1','2','3',    '5','6','7','8',        '11','12','90','91','92','93','94']
    users = [user1, user2, user3, user4, user5, user6, user7]
    
    
    me    = ['1','2','3',        '6',    '8',        '11','12']
    
    #
    # => RECOMMENDATION !!!
    ##########################
    
    users.each do |someone|
      state = false
      state_limit = false
      state_favor = false
      potential_recom = someone - me
      how_many_equal = (someone - (someone - me)).count
      
      if how_many_equal >= low_limit
        state_limit = true
      end
      # puts "#{how_many_equal}, #{someone.count}, #{how_many_equal.to_f/someone.count.to_f}"
      if (how_many_equal.to_f/someone.count.to_f) * 100 >= favor_rate
        state_favor = true
      end
      #puts state_favor
      
      if state_favor == true && state_limit == true
        potential_recom.each do |song|
          it_looks_like_your_favorite_song << song
          break if it_looks_like_your_favorite_song.uniq.count == high_limit
        end
      end
    end
    it_looks_like_your_favorite_song.uniq!
    
    print "#{it_looks_like_your_favorite_song}\n"
    render json: it_looks_like_your_favorite_song
  end
  
end
