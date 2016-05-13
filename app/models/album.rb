class Album < ActiveRecord::Base
    has_many :songs
    has_and_belongs_to_many :singers
    has_and_belongs_to_many :albums
end
