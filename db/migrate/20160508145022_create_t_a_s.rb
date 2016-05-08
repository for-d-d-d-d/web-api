class CreateTAS < ActiveRecord::Migration
  def change
    create_table :t_a_s do |t|
      t.integer :singer_id
      t.integer :team_id
      t.timestamps null: false
    end
  end
end
