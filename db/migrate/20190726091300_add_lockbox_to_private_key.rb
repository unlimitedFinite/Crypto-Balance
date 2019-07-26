class AddLockboxToPrivateKey < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :secret_key_ciphertext, :text
  end
end
