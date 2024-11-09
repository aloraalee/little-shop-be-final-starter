class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
    serialized_coupon =  CouponSerializer.new(coupon).serializable_hash

    show_coupon_used_count = {
      data: serialized_coupon[:data],
      meta: {
        coupon_used_count: coupon.invoices.count
      }
    }
    render json: show_coupon_used_count
  end

  def create
    coupon = Coupon.create!(coupon_params)
    render json: CouponSerializer.new(coupon), status: :created
  end

  private

  def coupon_params
    params.permit(:name, :code, :discount_type, :discount_value, :merchant_id)
  end
end