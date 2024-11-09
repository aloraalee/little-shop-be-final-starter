class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = Coupon.find(params[:id])
    serialized_coupon =  CouponSerializer.new(coupon).serializable_hash

    show_coupon_used_count = {
      data: serialized_coupon[:data],
      meta: {
        coupon_used_count: "count goes here" #Coupon.used_count or #coupon.used_count
      }
    }
    render json: show_coupon_used_count
  end
end