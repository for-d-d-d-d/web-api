class SunwooController < ApplicationController
    attr_reader :my_songs, :sample_users, :sing_it, :equal_minimum, :count_of_recom, :favor_percentage, :number_of_sample_user
    attr_accessor :my_songs, :sample_users, :sing_it, :equal_minimum, :count_of_recom, :favor_percentage, :number_of_sample_user
    

    
    public
    
        def initialize(my_id)
            @my_songs = User.find(my_id).my_songs.uniq.map{|s| s.id}.sort
            @sample_users = []
            @sing_it = []
            @equal_minimum = 4 # N 개, desc: 추천받는이와 최소한 몇 개는 같은 곡이 있어야 하는지.
            @count_of_recom = 30  # N 개, desc: 추천받는이가 한 번에 추천받을 곡의 갯수
            @favor_percentage = 30 # N %,  desc: 한 유저의 취향으로 판단 할 수 있는 곡의 비중
            @number_of_sample_user = 5
            
        end
        
        #샘플유저를 랜덤으로 뽑아서 그것들의 mysong들을 저장 후 반환
        def user_sample_picker
            puts "샘플피커문제\n"
            users_mylists = []
            sample_users = []
            sample_users = User.all.sample( @number_of_sample_user)
            sample_users.each do |user|
              users_mylists << user.my_songs.map{|mysong| mysong.id }
            end
            
            @sample_users = users_mylists
        end
    
        
        #song id 를 song으로 바꿔줌
        def from_id_to_songs(ids)
            return ids.map{|id| Song.find(id)}
        end
        
        
        def user_validation(somebody)
            puts "밸리데이션문제"
            difference      = somebody - @my_songs
            how_many_equal  = (somebody - difference).count
            
            rate = (how_many_equal.to_f/somebody.count.to_f) * 100
            if how_many_equal >= @equal_minimum  && rate >= @favor_percentage && rate != 100.to_f
                return difference
            else
                difference=[]
                return false
            end
        end
            
        
        def filler
            puts "필러문제"
            lose_count = 0
            @sample_users.each do |somebody|
                difference = self.user_validation(somebody)
                if difference != false
                    difference.each do |song|
                        @sing_it << song
                        break if @sing_it.uniq.count >= @count_of_recom
                    end
                else
                    lose_count += 1
                    puts "this shit is skipped! #{lose_count}"
            
                end
                @sing_it = @sing_it.uniq
                break if @sing_it.count >= @count_of_recom
            end
        end
        
        # roll : Recommendation Main Feild
        # desc : 결국 추천될 노래는 여기서 수렴
        def self.recommend(my_id)
            
            # 객체 선언했고 샘플유저 뽑음.
            recom = SunwooController.new(my_id)
            i = 0
            loop do 
                puts "엉???!!"
                recom.user_sample_picker
                puts "역시???!!"
                recom.filler
                puts "엥?!!!???!!"
                puts "오!"
                break if recom.sing_it.count >= recom.count_of_recom
                break if i >= 1000
                puts "우!"
                if i % 5 == 0
                    if recom.equal_minimum > 2
                        recom.equal_minimum -= 1
                    end
                    if recom.favor_percentage >= 10
                        recom.favor_percentage -= 1
                    end
                end
                
                i += 1
                puts "앗!!"
            end
            puts "#{recom.sing_it}"
            # READY to send API
            sing_it = recom.from_id_to_songs(recom.sing_it)
            puts "\n(result) result_count :=>\n #{sing_it.count}\n"
            
            return sing_it
        end

end
