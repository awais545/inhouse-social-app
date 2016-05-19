class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :user_id
      t.string :access_token
      t.string :secret
      t.string :provider
      t.string :category
      t.string :name
      t.string :facebook_page_id

      t.timestamps null: false
    end
  end
end
