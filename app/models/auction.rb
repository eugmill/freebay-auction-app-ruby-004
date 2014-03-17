class Auction < ActiveRecord::Base
  has_many :bids, :dependent => :destroy
  belongs_to :seller, :class_name => "User"

  validates :title, :uniqueness => true

  validate :end_time_in_the_future, :on => :update


  def end_time_in_the_future
    errors.add(:end_time, "can't be in the past") if self.end_time && self.end_time < Time.now
  end


end
