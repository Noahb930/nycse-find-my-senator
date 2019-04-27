class AddRefToEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :emails, :ref, :string
  end
end
