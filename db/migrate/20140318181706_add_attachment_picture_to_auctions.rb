class AddAttachmentPictureToAuctions < ActiveRecord::Migration
  def self.up
    change_table :auctions do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :auctions, :picture
  end
end
