class Song < ActiveRecord::Base
    belongs_to :album
    belongs_to :singer
    belongs_to :team
end
