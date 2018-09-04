class CreateDonations < ActiveRecord::Migration[5.2]
  def change
    create_table :donations do |t|
      t.string :value
      t.string :lobbyist_id
      t.string :senator_id

      t.timestamps
    end
  end
end
