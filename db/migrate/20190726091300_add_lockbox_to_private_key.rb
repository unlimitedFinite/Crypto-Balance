class AddLockboxToPrivateKey < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :privkey_ciphertext, :text
  end
end
