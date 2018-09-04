class AddYearToDonation < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :year, :string
  end
end
