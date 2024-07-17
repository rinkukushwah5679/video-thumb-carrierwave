class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :titel
      t.string :video

      t.timestamps
    end
  end
end
