class EncryptApiKey < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_key_ciphertext, :text
    remove_column :users, :api_key
  end
end
