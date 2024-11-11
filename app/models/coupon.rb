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

  def serialized_with_usage_count
    serialized_coupon = CouponSerializer.new(self).serializable_hash
    {
      data: serialized_coupon[:data],
      meta: {
        coupon_used_count: invoices.count
      }
    }
  end

  def self.merchant_active_coupon_limit?(merchant)
    merchant.coupons.where(active: true).count >= 5
  end

  def self.active?
    coupon_params[:active] == false || coupon_params[:active] == 'false' && coupon.active?
  end

  def self.with_invoice_status
    joins(:invoices).where(invoices: { status: 'packaged' })
  end
end