class RecommendationController < ApplicationController
    
    FOLD_MINIMUM        = 4     # N 개, desc: 추천받는이와 최소한 몇 개는 같은 곡이 있어야 하는지.
    COUNT_OF_RECOM      = 30    # N 개, desc: 추천받는이가 한 번에 추천받을 곡의 갯수
    FAVOR_PERCENTAGE    = 40    # N %,  desc: 한 유저의 취향으로 판단 할 수 있는 곡의 비중
    
    MY_ID = 1 

    NUMBER_OF_SAMPLE_USER   = 4 # N 명, desc: 한 번에 비교할 샘플 유저의 수
    
    # roll      : initializer
    # to        : this.recommend()
    # desc      : 추천을 위한 resource를 정의
    # input     : my_id             => current_user.id
    # output    : sample_users      => 비교할 대상자들이 각각 담고있는 노래의 id들을 저장
    #             me                => 내가 담고있는 노래의 id들을 저장
    #             sing_it           => 추천될 노래 세트를 초기화
    #             FOLD_MINIMUM      => 최 상단 설정부 참고
    #             COUNT_OF_RECOM    => 최 상단 설정부 참고 
    #             FAVOR_PERCENTAGE  => 최 상단 설정부 참고
    def self.init(my_id)
        # MY_ID = my_id
        sample_users = self.user_sample_picker(NUMBER_OF_SAMPLE_USER)
        me = self.map_id(my_songs(my_id))
        sing_it = []
        
        return sample_users, me, sing_it, FOLD_MINIMUM, COUNT_OF_RECOM, FAVOR_PERCENTAGE
    end
    
    # roll      : sample user pick
    # to        : this.init()
    # desc      : 비교할 대상자를 (임의의) num명을 선정
    # input     : NUMBER_OF_SAMPLE_USER
    # output    : (임의의) num명이 각각 보유한 노래 id
    def self.user_sample_picker(num)
        
      # TEST-stage code
        # user1 = (1..20).to_a
        # user2 = [1,2,3,4,5,6,7,8,9,10]
        # user3 = [1,  3,  5,  7,  9]
        # user4 = [1,2,3,4,5,6,                             95]
        # user5 = [          6,7,8,9,10]
        # user6 = [  2,  4,  6,  8,  10]
        # user7 = [1,2,3,  5,6,7,8,    11,12,90,91,92,93,94]
        # 
        # users = []
        # (1..7).to_a.each do |i|
        #     eval("users << user" + i.to_s)
        # end
        
    #   # AUTO-stage code
    #     users = User.all.map{|user| user.my_songs.map{|song| song.id}}
    #   # 
        
    #     picked_user = users.sample(num)
    #     return picked_user
        users_mylists = []
        sample_users = []
        sample_users = User.all.sample(num)
        
        sample_users.each do |user|
          users_mylists << user.my_songs.map{|mysong| mysong.id }
        end
        
        return users_mylists
    end


    def self.my_songs(id)
        my_songs = User.find(id).my_songs
        return my_songs
    end
    
    def self.map_id(things)
        mapped = things.uniq.map{|s| s.id}.sort
        return mapped
    end
    
    def self.from_id_to_songs(ids)
        songs = []

        # ids.each do |id|
        #     songs << Song.find(id)
        # end

        ids.each{ |id| songs.push(Song.find(id)) }
        return songs
    end
    
    
    def self.user_validation(somebody, me, fold_minimum, favor_percentage)
        difference      = somebody - me
        how_many_equal  = (somebody - difference).count
        
        # 최소한의 같은 곡이 존재하는가
        check_limit = false
        if how_many_equal >= fold_minimum
            check_limit = true
        end
        
        # 최소한의 같은 곡이 대상의 취향으로 간주 할 수 있는 (비율조건)을 만족하는가
        check_favor = false
        rate = (how_many_equal.to_f/somebody.count.to_f) * 100
        if rate >= favor_percentage && rate != 100.to_f
            check_favor = true
        end
        
        # 상단의 모든 조건을 만족하는가
        check = false
        if check_limit == true && check_favor == true
            check = true    # 모두 만족하면 이 사람은 me 에게 추천해줄 자격이 있다.
        else
            difference = [] # 추천해줄 자격이 없으면 추천해줄 내용을 전부 비운다.
        end
        return check, difference
    end
    
    def self.filler(sing_it, sample_users, me, fold_minimum, favor_percentage, count_of_recom)
        i = 0
        lose_count = 0
        sample_users.each do |somebody|
            check, difference = self.user_validation(somebody, me, fold_minimum, favor_percentage)
            
            # puts "\n\nUSER Number #{i}"
            i += 1
            # puts "(user_validation) check :=>\n #{check}\n"
            # puts "(user_validation) difference :=>\n #{difference}\n"
            
            if check == false || difference.count == 0
                lose_count += 1
                puts "this shit is skipped! #{lose_count}"
                next
            end
            
            if check == true
                difference.each do |song|
                    sing_it << song
                    break if sing_it.uniq.count >= count_of_recom
                end
            end
            sing_it.uniq!
            break if sing_it.count >= count_of_recom
        end
        return sing_it, lose_count
    end
    
    # roll : Recommendation Main Feild
    # desc : 결국 추천될 노래는 여기서 수렴
    def self.recommend(my_id)
        
        # GET Initailized Resource
        sample_users, me, sing_it, fold_minimum, count_of_recom, favor_percentage = self.init(my_id)
        
        # DEBUGGER for init()
        # puts "(inits) sample_users :=>\n #{sample_users.count}\n"
        # puts "(inits) me :=>\n #{me}\n"
        # puts "(inits) sing_it :=>\n #{sing_it}\n"
        # puts "(inits) fold_minimum :=>\n #{fold_minimum}\n"
        # puts "(inits) count_of_recom :=>\n #{count_of_recom}\n"
        # puts "(inits) favor_percentage :=>\n #{favor_percentage}\n\n"
        
        # Can Recycle
        i = 0
        loop do
            # SET 'sing_it'
            sing_it, lose_count = self.filler(sing_it, sample_users, me, fold_minimum, favor_percentage, count_of_recom)
            
            # breaker
            break if i >= count_of_recom
            break if sing_it.count >= count_of_recom
            break if lose_count == 0
            
            # READY next loop
            sample_users = self.user_sample_picker(lose_count*5)
            if i % 5 == 0 && fold_minimum > 2
                fold_minimum -= 1
            end
            if favor_percentage >= 10
                favor_percentage -= 1
            end
            
            i += 1
        end
        
        # READY to send API
        sing_it = self.from_id_to_songs(sing_it)
        #puts "\n\n\n(result) lose_count :=>\n #{lose_count}\n"
        puts "\n(result) result_count :=>\n #{sing_it.count}\n"
        
        return sing_it
    end

end
