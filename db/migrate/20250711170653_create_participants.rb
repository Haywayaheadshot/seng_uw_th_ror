class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.string :name, null: false
      t.integer :age, null: false
      t.datetime :deleted_at

      t.index :deleted_at, name: 'index_participants_on_deleted_at'
      t.timestamps
    end
  end
end
