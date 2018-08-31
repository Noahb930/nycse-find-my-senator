class CreateBills < ActiveRecord::Migration[5.2]
  def change
    create_table :bills do |t|
      t.string :number
      t.string :status
      t.string :session
      t.string :summary

      t.timestamps
    end
  end
end
