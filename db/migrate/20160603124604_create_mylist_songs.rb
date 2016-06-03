class CreateMylistSongs < ActiveRecord::Migration
  def change
    create_table :mylist_songs do |t|
      t.integer :mylist_id
      t.integer :song_id
      t.timestamps null: false
    end
  end
end
