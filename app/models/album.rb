class Album < ActiveRecord::Base
    has_many :songs
    has_and_belongs_to_many :singers
    has_and_belongs_to_many :teams

    def artists
        a = Array.new
        self.singers.each do |s|
            a << s
        end
        self.teams.each do |t|
            a << t
        end
        a
    end

    def artist
        return Team.find(self.team_id) unless self.team_id.nil?
        return Singer.find(self.singer_id) unless self.singer_id.nil?
        nil
    end
end
