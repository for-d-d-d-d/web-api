class Team < ActiveRecord::Base
  has_many :songs
  has_and_belongs_to_many :singers
  has_and_belongs_to_many :albums

  def teams
      t = Array.new
      TeamTeam.all.each do |tt|
          t << Team.find(tt.team2_id) if tt.team_id == self.id
          t << Team.find(tt.team_id) if tt.team2_id == self.id
      end
      return t
  end
end
