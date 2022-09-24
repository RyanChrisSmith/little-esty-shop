require 'rails_helper'

RSpec.describe 'Merchants Bulk Discount index' do
  before :each do
    @merchant_1 = Merchant.create!(name: "Bread Pitt")

    @discount_1 = BulkDiscount.create!(percentage_discount: 5, quantity: 10, merchant_id: @merchant_1.id)
    @discount_2 = BulkDiscount.create!(percentage_discount: 10, quantity:  15, merchant_id: @merchant_1.id)
    @discount_3 = BulkDiscount.create!(percentage_discount: 15, quantity:  20, merchant_id: @merchant_1.id)
    @discount_4 = BulkDiscount.create!(percentage_discount: 20, quantity:  30, merchant_id: @merchant_1.id)
  end

  it 'will display all of the current bulk discounts' do
    # expect(current_path).to eq(merchant_bulk_discounts_path)
    visit merchant_bulk_discounts_path(@merchant_1)

    expect(page).to have_content("All discounts")
    # Where I see all of my bulk discounts including their
    # percentage discount and quantity thresholds
    within("#discount-#{@discount_1.id}") do
      expect(page).to have_content(@discount_1.percentage_discount)
      expect(page).to have_content(@discount_1.quantity)
    end

    within("#discount-#{@discount_2.id}") do
      expect(page).to have_content(@discount_2.percentage_discount)
      expect(page).to have_content(@discount_2.quantity)
    end
  end

  it 'will have a link to each individual bulk discount show page' do
    visit merchant_bulk_discounts_path(@merchant_1)

    within("#discount-#{@discount_1.id}") do
      click_link 'Discount Details'
      expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @discount_1))
    end
    # And each bulk discount listed includes a link to its show page
  end

  it 'will have a link to create a new bulk discount' do
    # When I visit my bulk discounts index
    visit merchant_bulk_discounts_path(@merchant_1)
    # Then I see a link to create a new discount
    expect(page).to have_link("Create New Discount")
    # When I click this link
    click_link("Create New Discount")
    # Then I am taken to a new page where I see a form to add a new bulk discount
    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant_1))
    #rest of story in create spec for bulk discounts
  end

  it 'will show the next 3 holidays coming up' do
    # When I visit the discounts index page
    visit merchant_bulk_discounts_path(@merchant_1)
    # I see a section with a header of "Upcoming Holidays"
    expect(page).to have_content("Upcoming Holidays")
    # In this section the name and date of the next 3 upcoming US holidays are listed.
    expect(page).to have_content("Columbus Day - 2022-10-10")
    expect(page).to have_content("Veterans Day - 2022-11-11")
    expect(page).to have_content("Thanksgiving Day - 2022-11-24")
  end
end