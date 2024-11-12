class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }
  validate :coupon_id_matches_merchant, if: :coupon_present?

private

  def coupon_id_matches_merchant
    unless merchant_id == coupon.merchant_id
    errors.add(:base, "This merchant does not have this coupon")
    end
  end

  def coupon_present?
    coupon.present?
  end
end