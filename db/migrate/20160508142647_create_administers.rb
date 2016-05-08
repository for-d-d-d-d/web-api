class CreateAdministers < ActiveRecord::Migration
  def change
    create_table :administers do |t|
      t.string :username
      t.string :email
      t.string :password

      t.timestamps null: false
    end
  end
end
