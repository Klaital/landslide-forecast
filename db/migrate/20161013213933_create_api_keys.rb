class CreateApiKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :api_keys do |t|
      t.string :service
      t.string :key

      t.timestamps
    end
  end
end
