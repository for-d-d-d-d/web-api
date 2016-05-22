class CreateMylists < ActiveRecord::Migration
  def change
    create_table :mylists do |t|
      t.integer :user_id
      t.integer :song_id
      t.timestamps null: false
    end
  end
end
