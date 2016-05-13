class CreateSingers < ActiveRecord::Migration
  def change
    create_table :singers do |t|
      t.string :name
      t.string :photo
      t.integer :artist_num

      t.timestamps null: false
    end
  end
end
