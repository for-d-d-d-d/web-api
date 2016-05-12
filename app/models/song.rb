class Song < ActiveRecord::Base
    belongs_to :album, :singer, :team
end
