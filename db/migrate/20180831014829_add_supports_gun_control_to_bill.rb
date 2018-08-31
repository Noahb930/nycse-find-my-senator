class AddSupportsGunControlToBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :supports_gun_control, :string
  end
end
