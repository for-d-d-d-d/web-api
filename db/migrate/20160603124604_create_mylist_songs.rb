class CreateMylistSongs < ActiveRecord::Migration
  def change
    create_table :mylist_songs do |t|
      t.integer :mylist_id
      t.integer :song_id
      # t.string  :hometown  #어느 페이지를 통해 마이리스트에 추가되었는지 저장하는 변수
      t.timestamps null: false
    end
  end
end
