class CreateAuctions < ActiveRecord::Migration
  def change
    create_table :auctions do |t|
      t.integer :seller_id
      t.string :title
      t.text :description
      t.datetime :end_time

      t.timestamps
    end
  end
end
