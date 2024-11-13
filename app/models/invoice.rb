class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }
  validate :coupon_id_matches_merchant, if: :coupon_present?

  def calculate_total
    acc = 0
    invoice_items.each do |invoice_item|
      invoice_item_total = invoice_item.quantity * invoice_item.unit_price
      acc += invoice_item_total
    end
    acc    
  end

  def calculate_total_after_discount
    if coupon.discount_type == "dollar"
      if (calculate_total - coupon.discount_value) < 0
        0
      else calculate_total - coupon.discount_value
      end
    else coupon.discount_type == "percent"
      calculate_total * (1-(coupon.discount_value / 100))
    end
  end

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