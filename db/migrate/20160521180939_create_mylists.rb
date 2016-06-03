class CreateMylists < ActiveRecord::Migration
  def change
    create_table :mylists do |t|
      t.integer :user_id
      t.string :title # Mylist 이름
      t.timestamps null: false
    end
  end
end
