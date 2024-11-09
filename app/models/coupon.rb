class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates_presence_of :name, :code, :discount_type, :discount_value, :active, :merchant_id
  validates :discount_value, numericality: {greater_then_or_equal_to: 0}
  validates :code, uniqueness: { case_sensitive: false }
  # validate :merchant_active_coupon_limit

  private

  def merchant_active_coupon_limit
    if merchant.coupons.where(active: true).count >= 5 && active?
      errors.add(:base, "This merchant has reached the 5 active coupon limit")
    end
  end

end