class Singer < ActiveRecord::Base
    has_many :tases
    
    def self.teams
        teams = Array.new
        self.tases.each do |s|
            t = Team.where(id: s.team_id).first
            teams << t unless t.nil?
        end
        return teams
    end
end
