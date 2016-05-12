class CreateAlbumSingers < ActiveRecord::Migration
  def change
    create_table :album_singers do |t|

      t.timestamps null: false
    end
  end
end
