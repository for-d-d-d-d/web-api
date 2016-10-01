class DailyTjPopularRank < ActiveRecord::Base

    def self.take(start, stop)
        
    end
    
    def self.linker_with_Song
        self.all.each do |song|
            matched_song_id = CrawlController.from_tj_match_db(song.song_num)
            if matched_song_id == false
                matched_song_id = nil
            end
            song.song_id            = matched_song_id
            song.save
        end
    end

    def self.month
        time = Time.zone.now.to_s.first(10)
        endTime = time.first(7) + "-01"
        if time.last(5).first(2) == "01" # 1월이 들어오는 경우 연도 하나 줄이고 전달을 12월로 넘김.
            time = (time.first(4).to_i - 1).to_s + "-12-01"
        else                             # 나머지는 걍 1씩 월에서 빼서 전달을 연산함.
            is_zero = ""
            if (time.last(5).first(2).to_i - 1).to_s.length == 1
                is_zero = "0"
            end
            time = time.first(4) + "-" + is_zero + (time.last(5).first(2).to_i - 1).to_s + "-01"
        end        
        result = DailyTjPopularRank.where(symd: time).where(eymd: endTime).where.not(song_id: nil).order(song_rank: :asc)

        return result
    end
end
