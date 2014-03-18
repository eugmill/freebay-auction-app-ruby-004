class User < ActiveRecord::Base
  has_many :listings, :class_name => "Auction", :foreign_key => "seller_id"
  has_many :bids, foreign_key: "bidder_id"

  has_secure_password

  validates :name, :uniqueness => true

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  def to_s
    self.name
  end

end
