class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates_presence_of :name 
  validates_presence_of :code 
  validates_presence_of :discount_type 
  validates_presence_of :discount_value 
  validates_presence_of :active
  validates_presence_of :merchant_id
  validates :discount_value, numericality: { greater_than_or_equal_to: 0 }
  validates :code, uniqueness: { case_sensitive: false }
  # validate :merchant_active_coupon_limit

  private

  def merchant_active_coupon_limit
    if merchant.coupons.where(active: true).count >= 5 && active?
      errors.add(:base, "This merchant has reached the 5 active coupon limit")
    end
  end

end