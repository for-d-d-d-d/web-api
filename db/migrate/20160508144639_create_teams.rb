class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :photo
      t.integer :gender # 1:남, 2:여, 4:혼성
      t.string :typee
      t.integer :artist_num

      t.timestamps null: false
    end
  end
end
