class AddStanceToVote < ActiveRecord::Migration[5.2]
  def change
    add_column :votes, :stance, :string
  end
end
