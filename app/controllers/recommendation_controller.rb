class RecommendationController < ApplicationController
    
    FOLD_MINIMUM        = 4     # N 개, desc: 추천받는이와 최소한 몇 개는 같은 곡이 있어야 하는지.
    COUNT_OF_RECOM      = 10    # N 개, desc: 추천받는이가 한 번에 추천받을 곡의 갯수
    FAVOR_PERCENTAGE    = 50    # N %,  desc: 한 유저의 취향으로 판단 할 수 있는 곡의 비중
    
    #MY_ID = current_user.id     # AUTO-stage
    MY_ID = 1                   # TEST-stage
    
    NUMBER_OF_SAMPLE_USER   = 3 # N 명, desc: 한 번에 비교할 샘플 유저의 수
    
    def init()
        sample_users = user_sample_picker(NUMBER_OF_SAMPLE_USER)
        me = map_id(my_songs(MY_ID))
        it_looks_like_your_favorite_song = []
        
        return sample_users, me, it_looks_like_your_favorite_song, FOLD_MINIMUM, COUNT_OF_RECOM, FAVOR_PERCENTAGE
    end
    
    def user_sample_picker(num)
        
        ####################################################
        
        
        # TEST-stage code
        ##########################
        user1 = ('1'..'20').to_a
        user2 = ['1','2','3','4','5','6','7','8','9','10']
        user3 = ['1',    '3',    '5',    '7',    '9']
        user4 = ['1','2','3','4','5','6','95']
        user5 = [                    '6','7','8','9','10']
        user6 = [    '2',    '4',    '6',    '8',    '10']
        user7 = ['1','2','3',    '5','6','7','8',        '11','12','90','91','92','93','94']
        
        users = []
        (1..7).to_a.each do |i|
            # users << user1
            # users << user2
            # users << user3
            # users << user4
            # users << user5
            # users << user6
            # users << user7
            eval("users << user" + i.to_s)
        end
        
        # AUTO-stage code
        ##########################
        # users = User.all
        
        
        ####################################################
        picked_user = users.sample(num)
        return picked_user
    end
    
    def my_songs(id)
        my_songs = User.find(id).my_songs
        return my_songs
    end
    
    def map_id(things)
        mapped = things.uniq.map{|s| s.id}.sort
        return mapped
    end
    
    def from_id_to_songs(ids)
        songs = []
        # ids.each do |id|
        #     songs << Song.find(id)
        # end
        ids.each{ |id| songs.push(Song.find(id)) }
        return songs
    end
    
    
    
    
    
    def user_validation(users)
        state           = false
        check_limit     = false
        check_favor     = false
        difference      = somebody - me
        how_many_equal  = (somebody - difference).count
        
        if how_many_equal >= fold_minimum
            check_limit = true
        end
        if (how_many_equal.to_f/somebody.count.to_f) * 100 >= favor_rate
            check_favor = true
        end
        
        if check_limit == true && check_favor == true
            
        else
            
        end
        return users
    end
    
end
