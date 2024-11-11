# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
cmd = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $(whoami) -d little_shop_development db/data/little_shop_development.pgdump"
puts "Loading PostgreSQL Data dump into local database with command:"
puts cmd
system(cmd)

# Coupon.create! name:"Buy One Get One 50% off", code:"BOGO50", discount_type:"percent", discount_value:25.00, merchant_id:5
# Coupon.create! name:"Flash Sale", code:"FLASH40NOW", discount_type:"percent", discount_value:40.00, merchant_id:5
# Coupon.create! name:"Sign Up With Your Email", code:"EMAIL20", discount_type:"percent", discount_value:20.00, merchant_id:8
# Coupon.create! name:"Grand Oppening", code:"TEN4EVERY1", discount_type:"dollar", discount_value:10.00, merchant_id:8
# Coupon.create! name: "Summer Clearance", code: "SUMMER25", discount_type: "percent", discount_value: 25.00, merchant_id: 3
# Coupon.create! name: "First Time Customer", code: "WELCOME15", discount_type: "percent", discount_value: 15.00, merchant_id: 7
# Coupon.create! name: "Holiday Special", code: "HOLIDAY50", discount_type: "dollar", discount_value: 50.00, merchant_id: 2
# Coupon.create! name: "Loyalty Reward", code: "LOYAL10", discount_type: "dollar", discount_value: 15.00, merchant_id: 6
# Coupon.create! name: "Free Shipping", code: "SHIPFREE", discount_type: "dollar", discount_value: 7.00, merchant_id: 4

# Invoice.create! customer_id: 3, merchant_id: 8, status: "shipped", coupon_id: 3
# Invoice.create! customer_id: 4, merchant_id: 8, status: "shipped", coupon_id: 3
# Invoice.create! customer_id: 5, merchant_id: 8, status: "shipped", coupon_id: 3

# Invoice.create! customer_id: 6, merchant_id: 8, status: "shipped", coupon_id: 4
# Invoice.create! customer_id: 7, merchant_id: 8, status: "shipped", coupon_id: 4

# Invoice.create! customer_id: 8, merchant_id: 8, status: "packaged", coupon_id: 4
# Invoice.create! customer_id: 9, merchant_id: 8, status: "packaged", coupon_id: 4



# Use this for coupons that cannot be updated to active:false
#Coupon.joins(:invoices).where('invoices.status = packaged')





#Invoice.create! customer_id: 7, merchant_id: 8, status: "shipped", coupon_id: 5 
# This should not have worked because it has a coupon_id that does not match. 
# Merchant 8 only has coupons 3 and 4
# I deleted the instance I created, but I need to make a validation for this. 



# I can probably do something like this from invoice model: 
# def self.valid_status?(status)
#   ["shipped", "returned", "packaged"].include?(status)
# end
