class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates_presence_of :name 
  validates_presence_of :code 
  validates_presence_of :discount_type 
  validates_presence_of :discount_value 
  validates :active, inclusion: { in: [true, false] }
  validates :discount_value, numericality: { greater_than_or_equal_to: 0 }
  validates :code, uniqueness: { case_sensitive: false }

  def self.merchant_active_coupon_limit?(merchant)
    merchant.coupons.where(active: true).count >= 5
  end
end