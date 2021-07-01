class CreateBeggars < ActiveRecord::Migration[6.1]
  def change
    create_table :beggars do |t|
      t.string :name, limit: 20, null: false
      t.string :site, limit: 50, null: false
      t.string :parser, null: false
      t.timestamps
    end
  end
end
