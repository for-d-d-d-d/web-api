class CreateSingerTeams < ActiveRecord::Migration
  def change
    create_table :singer_teams do |t|

      t.timestamps null: false
    end
  end
end
