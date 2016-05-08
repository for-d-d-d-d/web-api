class Team < ActiveRecord::Base
    has_many :tases
    
    def self.singers
        singers = Array.new
        self.tases.each do |t|
            s = Singer.where(id: t.singer_id).first
            singers << s unless s.nil?
        end
        return singers
    end
end
