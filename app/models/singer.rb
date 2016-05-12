class Singer < ActiveRecord::Base
    has_many :songs
    has_and_belongs_to_many :teams, :albums
end
