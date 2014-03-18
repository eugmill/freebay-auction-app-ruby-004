class Auction < ActiveRecord::Base
  has_many :bids, :dependent => :destroy
  belongs_to :seller, :class_name => "User"

  validates :title, :uniqueness => true
  validates :end_time, :presence => true

  validate :end_time_in_the_future, :on => :update


  def end_time_in_the_future
    errors.add(:end_time, "can't be in the past") if self.end_time && self.end_time < Time.now
  end

  def self.get_active_auctions
    where("end_time > ?", Time.now)
  end

  def highest_bid
    self.bids.maximum("amount")
  end

 



end
