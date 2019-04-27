class AddProfessionToEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :emails, :profession, :string
  end
end
