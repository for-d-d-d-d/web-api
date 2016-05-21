class CreateTeamTeams < ActiveRecord::Migration
  def change
    create_table :team_teams do |t|
      t.integer :team_id
      t.integer :team2_id
      t.timestamps null: false
    end
  end
end
