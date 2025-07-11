class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.boolean :admin, default: false, null: false

      t.index :username, unique: true, name: 'index_users_on_username'
      t.timestamps
    end
  end
end
