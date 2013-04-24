class AddResponseFieldsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :response_code, :string
    add_column :orders, :response_description, :string
  end
end
