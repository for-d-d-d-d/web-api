class CreateSingerTeams < ActiveRecord::Migration
  def change
    create_table :singer_teams do |t|

      t.integer :singer_id
      t.integer :team_id

      t.timestamps null: false
    end
  end
end
