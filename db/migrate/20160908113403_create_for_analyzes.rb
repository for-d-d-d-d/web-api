class CreateForAnalyzes < ActiveRecord::Migration
  def change
    create_table :for_analyzes do |t|
    	
  		t.integer :count_recomm           	
      t.timestamps null: false
    end
  end
end
