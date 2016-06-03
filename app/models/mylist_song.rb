class MylistSong < ActiveRecord::Base
    belongs_to :mylist
    has_one :song

    # def song
    #     return Song.where(id: self.song_id).first
    # end
end
