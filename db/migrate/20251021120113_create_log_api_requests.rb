class CreateLogApiRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :log_api_requests do |t|
      t.string :api_key
      t.string :path
      t.string :method
      t.string :ip
      t.integer :timestamp

      t.timestamps
    end
  end
end
