class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :bidder_id
      t.integer :amount
      t.integer :auction_id

      t.timestamps
    end
  end
end
