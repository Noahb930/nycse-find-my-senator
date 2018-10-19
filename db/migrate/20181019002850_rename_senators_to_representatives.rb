class RenameSenatorsToRepresentatives < ActiveRecord::Migration[5.2]
  def change
    rename_table :senators, :representatives

    rename_column :votes, :senator_id, :representative_id
    rename_column :donations, :senator_id, :representative_id

    add_column :bills, :location, :string
    add_column :representatives, :profession, :string
  end
end
