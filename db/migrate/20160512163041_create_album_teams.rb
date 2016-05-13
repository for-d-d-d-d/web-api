class CreateAlbumTeams < ActiveRecord::Migration
  def change
    create_table :album_teams do |t|
      t.integer :album_id
      t.integer :team_id
      t.timestamps null: false
    end
  end
end
