class CreateIntervalKeys < ActiveRecord::Migration
  def change
    create_table :interval_keys do |t|
      t.string  :key
      t.integer :number
      # t.float   :percent

      t.timestamps null: false
    end
  end
end
