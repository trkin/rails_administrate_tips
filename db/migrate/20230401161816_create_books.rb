class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :categories_array, array: true, default: []
      t.text :body

      t.timestamps
    end
  end
end
