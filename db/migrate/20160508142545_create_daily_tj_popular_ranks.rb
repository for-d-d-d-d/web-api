class CreateDailyTjPopularRanks < ActiveRecord::Migration
  def change
    create_table :daily_tj_popular_ranks do |t|
      t.string :symd
      t.string :eymd
      t.integer :song_rank
      t.integer :song_id
      t.integer :song_num
      t.string :song_title
      t.string :song_singer

      t.timestamps null: false
    end
  end
end
