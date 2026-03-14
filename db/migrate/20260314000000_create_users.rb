class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :users, id: :uuid do |t|
      t.string :firebase_uid, null: false
      t.string :email, null: false
      t.string :name
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :firebase_uid, unique: true
    add_index :users, :email, unique: true
  end
end
