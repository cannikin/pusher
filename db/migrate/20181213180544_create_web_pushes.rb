class CreateWebPushes < ActiveRecord::Migration[5.2]
  def change
    create_table :web_push_optins do |t|
      t.string :endpoint
      t.string :p256dh
      t.string :auth

      t.timestamps
    end
  end
end
