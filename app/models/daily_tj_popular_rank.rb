class DailyTjPopularRank < ActiveRecord::Base

    # def self.take(start, stop)
        
    # end
    
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
end
