class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents, id: false do |t|
      t.column :id,       'VARCHAR(36) PRIMARY KEY'
      t.string :user_id,  null: false, limit: 64, index: true
      t.timestamps null: false
    end
  end
end
