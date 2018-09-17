class AddShorthandToBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :shorthand, :string
  end
end
