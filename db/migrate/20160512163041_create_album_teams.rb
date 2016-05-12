class CreateAlbumTeams < ActiveRecord::Migration
  def change
    create_table :album_teams do |t|

      t.timestamps null: false
    end
  end
end
