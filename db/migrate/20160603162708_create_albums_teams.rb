class CreateAlbumsTeams < ActiveRecord::Migration
  def change
    create_table :albums_teams do |t|
        t.integer :album_id
        t.integer :team_id
      t.timestamps null: false
    end
  end
end
