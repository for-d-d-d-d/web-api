class CreateAlbumSingers < ActiveRecord::Migration
  def change
    create_table :album_singers do |t|
      t.integer :singer_id
      t.integer :album_id
      t.timestamps null: false
    end
  end
end
