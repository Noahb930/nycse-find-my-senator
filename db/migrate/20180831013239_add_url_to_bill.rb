class AddUrlToBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :url, :string
  end
end
