require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount show page' do 
  before :each do
    @merchant_1 = Merchant.create!(name: "Bread Pitt")
    
    @discount_1 = BulkDiscount.create!(percentage_discount: 5, quantity: 10, merchant_id: @merchant_1.id)
    @discount_2 = BulkDiscount.create!(percentage_discount: 10, quantity:  15, merchant_id: @merchant_1.id)
    @discount_3 = BulkDiscount.create!(percentage_discount: 15, quantity:  20, merchant_id: @merchant_1.id)
    @discount_4 = BulkDiscount.create!(percentage_discount: 20, quantity:  30, merchant_id: @merchant_1.id)
    visit merchant_bulk_discount_path(@merchant_1, @discount_1)
  end   

  it 'can edit the bulk discount' do 
    # Then I see a link to edit the bulk discount
    expect(page).to have_content("Edit Discount")
    # When I click this link
    click_link("Edit Discount")
    # Then I am taken to a new page with a form to edit the discount
    expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant_1, @discount_1))
  end

  it 'has a form to edit with prepoluated fields' do 
    visit edit_merchant_bulk_discount_path(@merchant_1, @discount_1)
    # And I see that the discounts current attributes are pre-poluated in the form
    expect(page).to have_field("Percentage Discount", with: 5)
    expect(page).to have_field("Quantity Threshold", with: 10)
    # When I change any/all of the information and click submit
    fill_in 'Percentage Discount', with: 35
    fill_in 'Quantity Threshold', with: 50
    click_on "Submit Bulk Discount Updates"
    # Then I am redirected to the bulk discount's show page
    expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @discount_1))
    # And I see that the discount's attributes have been updated
    expect(page).to have_content("Percentage Discount: 35%")
    expect(page).to have_content("Quantity Threshold: 50 items")
    expect(page).to_not have_content("Percentage Discount: 5%")
    expect(page).to_not have_content("Quantity Threshold: 10 items")
  end 
    

end 