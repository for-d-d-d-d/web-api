class Api::UserController < ApplicationController
    ## REST-API Definition
    
    # => (로그인) POST        /api/user/login                       api/user#login
    # STORY   > 수동 로그인 및 토큰 발행
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
    #     5. 자동 로그인 > 탈퇴한 회원의 로그인
    #     6. 수동 로그인 > 비밀번호가 올바르지 않을 때
    #     7. 자동 로그인 > 가입되지 않은 email
    #     8. 자동 로그인 > 탈퇴한 회원의 로그인
    #     9. 자동 로그인 > 저장되지 않은 토큰으로 로그인 시도
    def login
        @check      = "ERROR"
        @status     = "400 BAD REQUEST"
        @massage    = nil
    
        @id         = "ERROR"
        @mytoken    = nil
        @mylist_id  = nil
        
        unless params[:user].nil?
            me = params[:user]
        else                                                                # 차단1. 회원정보가 전혀 입력되지 않음
            @massage = "회원 정보를 입력해주세요"
            return render json: {result: @check, status: @status, message: @massage}
        end
        
        if me[:mytoken].nil?    # 로그인시 토큰이 없다(== 토큰만료. 자동로그인 불가. >> 재로그인)
            if me[:email].nil?                                              # 차단2. user[email]이 입력되지 않음
                @massage = "email을 입력해주세요"
                return render json: {result: @check, status: @status, message: @massage}
            elsif UtilController.check_email(me[:email]) == nil             # 차단3. email이 형식에 맞지 않음
                @massage = "Oops! Please Check your Email Format! (ex. blah@blah.blah)"
                return render json: {result: @check, status: @status, message: @massage}
            elsif me[:password].nil?                                        # 차단4. password가 입력되지 않음
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
                    if @mytoken == "20000"                                  # 차단5. 탈퇴한 회원의 로그인
                        @massage = "앗, 탈퇴하신적이 있으신가요? 다시 가입해주세요~"
                        return render json: {result: @check, status: @status, message: @massage}
                    end
                else                                                        # 차단6. password가 맞지 않음
                    @massage = "Incorrect Password! Please Check your password!"
                    return render json: {result: @check, status: @status, message: @massage}
                end
            else                                                            # 차단7. 가입되지 않은 email
                @massage = "Oops! Please Check your Email! It's not registed account email :("
                return render json: {result: @check, status: @status, message: @massage}
            end
        else                    # 토큰 있는 로그인(== 자동로그인.)
            if me[:mytoken] == "20000"                                      # 차단8. 탈퇴한 회원의 로그인
                @massage = "앗, 탈퇴하신적이 있으신가요? 다시 가입해주세요~"
                return render json: {result: @check, status: @status, message: @massage}
            end
            
            user = User.where(mytoken: me[:mytoken]).take
            if user.nil?                                                    # 차단9. 저장되지 않은 토큰으로 로그인 시도.
                @massage = "잘못된 로그인 시도입니다. 다시 로그인해주세요"
                return render json: {result: @check, status: @status, message: @massage}
            end
            @check = "SUCCESS"
            @id = user.id
        end
        @mylist_id = user.mylists.first.id if user.mylists.count != 0
        render :json => {result: @check, mytoken: @mytoken, id: @id, mylist_id: @mylist_id}
    end
    
    
    
    # => (신규 생성) POST     /api/user                             api/user#create
    # STORY   > 회원가입
    # Input   > (+) user[email]:                    이메일
    #           (+) user[name]:                     이름
    #           (+) user[gender]:                   성별
    #           (+) user[password]:                 비밀번호
    #           (+) user[password_confirmation]:    비번확인
    # Output  > {
    #               result:     \SUCCESS or ERROR\, 
    #               mytoken:    \회원 식별 mytoken\,
    #               myid:       \회원 고유 record id\,
    #               mylist_id:  \개인 기본 mylist id\
    #           }
    def create
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
            u.name      = ""
            u.gender    = 0
          end
        end
        if UtilController.check_email(u.email) != nil              # 1.이메일 형식 체크
          if User.where(email: user[:email]).count == 0            # 2.기존 회원인지 여부 체크
            if user[:password].to_s.length >= 6                    # 3.비번 자릿수 체크
              if user[:password] == user[:password_confirmation]   # 4.비번 == 비번확인 체크
                u.mytoken   = SecureRandom.hex(16)
                u.save!
                
                uml = Mylist.new({
                                user_id:    u.id,
                                title:      "#{u.name}님의 첫 번째 리스트"
                            })
                uml.save!
                @check, @mytoken, @mylist_id, @my_id = "SUCCESS", u.mytoken, uml.id, u.id
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
    
    
    
    # => (정보 조회) GET      /api/user/:id                         api/user#show
    # STORY   > 다목적성 자기계정 조회
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
    def show
        user = {result: "ERROR", message: "이런~ 가입부터 해달라고래!", name: nil, gender: nil, email: nil}
        
        if (10**(params[:id].length)).class == Bignum
            me = User.where(mytoken: params[:id]).take
        elsif (10**(params[:id].length)).class == Fixnum
            me = User.where(id: params[:id]).take
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
            # size = 150
            # origin_img_link = "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/logover3-300x300.png"
            # img_url = SERVER_URL + "/json/img_resize?size=#{size}&url=#{origin_img_link}"
            img_origin_url = "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/logover3.png"
            img_400_url = "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/logover3-1-e1475689170577.png"
            
            user =  {
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
    
    
    
    # => (정보 수정) PUT      /api/user/:id(.:format)               api/user#update
    # STORY   > 계정 수정정보 저장
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
    def update
        error = {result: "ERROR", message: "this is default error message", name: nil, gender: nil, email: nil, mytoken: nil}
        
        mytoken = params[:id]
        if mytoken.nil?
            error[:message] = "please login first"
            return render json: error
        end
    
        user = User.where(mytoken: mytoken).take unless mytoken.nil?
    
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
    
    
    
    # => (정보 조회) DELETE   /api/user/:id                         api/user#destroy
    # STORY   > 회원탈퇴
    # INPUT   > (url) id: user_id,
    #           (+)   mytoken: mytoken
    def destroy
        me = User.where(id: params[:id])
        if me.nil? || me.mytoken != params[:mytoken]
            return render json: {result: "ERROR", message: "incorrect user (token with id)"}
        end
        
        unless me.nil?
            me.update(mytoken: "20000")
            # me.blacklist_songs.each { |bs| bs.delete }
            # me.mylists.mylist_songs.each { |ms| ms.delete }
            # me.mylists.each { |ml| ml.delete }
            # me.delete
            message = "그동안 고래방을 이용해주셔서 감사합니다.."
        end
        return render json: {result: "SUCCESS", message: message}
    end
    
    
    
    def index
        # super
    end
    def new
        # super
    end
    def edit
        # super
    end
    
end
