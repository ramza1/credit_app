class CreateNewsLetters < ActiveRecord::Migration
  def change
    create_table :news_letters do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
