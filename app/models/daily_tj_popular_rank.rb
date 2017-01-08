class DailyTjPopularRank < ActiveRecord::Base

#
# [Methods]
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
        now = Time.current.to_date
        now = now.beginning_of_month                # 이번달 시작일
        
        # => [정정 조건] 해를 넘긴 경우 지난달은 이전년도 마지막달.
        before_year     = now.year
        before_month    = now.month - 1
        if before_month.zero?
            before_year  = now.year - 1
            before_month = 12
        end
        
        # => 기간 설정.
        start_date  = Date.new(before_year, before_month).to_s   # 지난달 시작일
        end_date    = now.to_s                                   # 이번달 시작일
        
        result = self.where(symd: start_date).where.not(song_id: nil).order(song_rank: :asc)
        
        
        # time = Time.zone.now.to_s.first(10)
        # endTime = time.first(7) + "-01"
        # if time.last(5).first(2) == "01" # 1월이 들어오는 경우 연도 하나 줄이고 전달을 12월로 넘김.
        #     time = (time.first(4).to_i - 1).to_s + "-12-01"
        # else                             # 나머지는 걍 1씩 월에서 빼서 전달을 연산함.
        #     is_zero = ""
        #     if (time.last(5).first(2).to_i - 1).to_s.length == 1
        #         is_zero = "0"
        #     end
        #     time = time.first(4) + "-" + is_zero + (time.last(5).first(2).to_i - 1).to_s + "-01"
        # end        
        # result = DailyTjPopularRank.where(symd: time).where.not(song_id: nil).order(song_rank: :asc) #.where(eymd: endTime).where.not(song_id: nil).order(song_rank: :asc)

        return result
    end
    
#
# [Utilities]
    #
    # => (When)     If error raised with this situation <"it couldn't find Song.find(self.song_id)">
    # => (Cause)    SongTable were changed, but 'song_id' columns in records of ThisTable are not changed yet.
    def self.rematch_with_changed_song_table_records
        i = 0
        @dtpr_error     = []
        @correct        = []
        @error_unexist  = []
        @error_wrong    = []
        @recovered      = []
        @missed         = []
        whole_count = DailyTjPopularRank.count
        
        # scan for whole records of this table.
        self.all.each do |dtpr|
            i += 1
            is_unexist  = false
            is_wrong    = false
            is_correct  = false
            # validate1. unexist value in 'song_id'.
            if Song.where(id: dtpr.song_id).take.nil?
                @error_unexist << dtpr
                is_unexist = true
            else
                
                # validate2. wrong value in 'song_id' with real song_id seek from 'song_num'.(it is 'song_tjnum' of SongTable's attributes)
                if dtpr.song_id != Song.where(song_tjnum: dtpr.song_num).take.id
                    @error_wrong << dtpr
                    is_wrong = true
                else
                    @correct << dtpr
                    is_correct = true
                end
                
            end
            puts "\n\n\t\tin 'MAKE ERROR ARRAY'... #{((i/whole_count)*100).round(3)}% (ALL : #{whole_count})"
            puts "\t\tNOW Progress Count    : #{i}/#{whole_count}\n\n"
            puts "\t\tunexist   : #{@error_unexist.count} #{'(+1)' if is_unexist}"
            puts "\t\twrong     : #{@error_wrong.count} #{'(+1)' if is_wrong}"
            puts "\t\tcorrect   : #{@correct.count} #{'(+1)' if is_correct}"
        end
        
        @dtpr_error = @error_unexist + @error_wrong

        puts "\n\n\n\n\n\n\n\n\n\n\t\t>>>>>>> D T P R ! <<<<<<<\n\n\n\n\n\n\n\n\n\n\n"
        
        # recovering error records.
        error_count = @dtpr_error.count
        j = 0
        @dtpr_error.each do |de|
            j += 1
            is_recovered    = false
            is_missed       = false
            song = Song.where(song_tjnum: de.song_num).take
            unless song.nil?
                de.song_id = song.id
                de.save
                @recovered << de
                is_recovered = true
            else
                @missed << de
                is_missed = true
            end
            puts "\n\n"
            puts "\t\tin 'RECOVERING'...    : #{((j/error_count)*100).round(3)}% (ALL : #{error_count})"
            puts "\t\tNOW Progress Count    : #{j}/#{error_count}\n\n"
            puts "\t\tRecovered     : #{@recovered.count} #{'(+1)' if is_recovered}"
            puts "\t\tmissed        : #{@missed.count} #{'(+1)' if is_missed}"
        end
        puts "\n\n=====================================\n=====================================\n\n"
        puts "\t\t>>>>> FINISHED!   (ALL : #{error_count})"
        puts "\t\tError         : #{error_count}"
        puts "\t\tRecovered     : #{@recovered.count}"
        puts "\t\tmissed        : #{@missed.count}"
        puts "\t\tProgressed    : #{(j/error_count).round(2)}"
    end
end
