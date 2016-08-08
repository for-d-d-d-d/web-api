class CreateBlacklistSongs < ActiveRecord::Migration
  def change
    create_table :blacklist_songs do |t|

      t.timestamps null: false
    end
  end
end
