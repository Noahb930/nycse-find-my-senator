class CreateSenators < ActiveRecord::Migration[5.2]
  def change
    create_table :senators do |t|
      t.string :name
      t.string :email
      t.string :party
      t.string :beliefs
      t.string :rating
      t.string :img
      t.string :district
      t.string :url

      t.timestamps
    end
  end
end
