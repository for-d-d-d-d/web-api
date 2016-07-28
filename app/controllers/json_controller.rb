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
    input_password = "nil"
    
    unless User.find_by_email(me[:email]).nil?
      user = User.find_by_email(me[:email])
      input_password = me[:password]
      my_account_password = BCrypt::Password.new(user.encrypted_password)
      
      if my_account_password == input_password
        @check = "SUCCESS"
        @id = user.id
      end
    end
    
    message = "#{my_account_password} , #{input_password} , @check = #{@check}, @id = #{@id}"
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
end
