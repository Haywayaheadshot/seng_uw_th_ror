class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.string :name, null: false
      t.integer :age, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :participants, :deleted_at
  end
end
