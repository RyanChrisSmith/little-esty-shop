require 'rails_helper'

RSpec.describe 'merchant bulk discount show page' do 
  before :each do
    @merchant_1 = Merchant.create!(name: "Bread Pitt")
    
    @discount_1 = BulkDiscount.create!(percentage_discount: 5, quantity: 10, merchant_id: @merchant_1.id)
    @discount_2 = BulkDiscount.create!(percentage_discount: 10, quantity:  15, merchant_id: @merchant_1.id)
    @discount_3 = BulkDiscount.create!(percentage_discount: 15, quantity:  20, merchant_id: @merchant_1.id)
    @discount_4 = BulkDiscount.create!(percentage_discount: 20, quantity:  30, merchant_id: @merchant_1.id)
  end

  it 'can display the percentage discount and quantity threshold for the bulk discount' do 
    # When I visit my bulk discount show page
    visit merchant_bulk_discount_path(@merchant_1, @discount_1)
    # Then I see the bulk discount's quantity threshold and percentage discount
    expect(page).to have_content("Percentage Discount: 5%")
    expect(page).to have_content("Quantity Threshold: 10 items")
  end 



end 