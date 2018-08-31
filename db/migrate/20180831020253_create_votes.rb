class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.string :position
      t.string :bill_id
      t.string :senator_id

      t.timestamps
    end
  end
end
