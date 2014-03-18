class Auction < ActiveRecord::Base
  has_many :bids, :dependent => :destroy
  belongs_to :seller, :class_name => "User"

  validates :title, :uniqueness => true
  validates :end_time, :presence => true

  validate :end_time_in_the_future, :on => :update, :unless => :force_submit

  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  attr_accessor :force_submit

  def end_time_in_the_future
    errors.add(:end_time, "can't be in the past") if self.end_time && self.end_time < Time.now
  end

  def self.get_active_auctions
    where("end_time > ?", Time.now)
  end

  def highest_bid
    self.bids.maximum("amount")
  end

  def highest_bid_object
    self.bids.order(:amount => :desc).limit(1).first
  end

  def highest_bidder
    self.highest_bid_object.bidder if highest_bid_object
  end

  def closed?
    self.end_time < Time.now
  end
end
