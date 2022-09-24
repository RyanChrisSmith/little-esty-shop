require 'rails_helper'

RSpec.describe 'Merchant Invoice Show' do
  before :each do
    @merchant_1 = Merchant.create!(name: "Bread Pitt")

    @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
    @customer_2 = Customer.create!(first_name: "Shannon", last_name: "Dougherty")
    @customer_3 = Customer.create!(first_name: "Puff", last_name: "Daddy")

    @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
    @invoice_2 = Invoice.create!(status: 2, customer_id: @customer_2.id)
    @invoice_3 = Invoice.create!(status: 2, customer_id: @customer_3.id)

    @item_1 = Item.create!(name: "Sourdough", description: "leavened, wild yeast", unit_price: 400, merchant_id: @merchant_1.id)
    @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 900, merchant_id: @merchant_1.id)
    @item_3 = Item.create!(name: "Brioche", description: "Rich, rolled", unit_price: 1100, merchant_id: @merchant_1.id)

    @invoice_item_1 = InvoiceItem.create!(quantity: 4, unit_price: 850, status: 0, item_id: @item_1.id, invoice_id: @invoice_1.id)
    @invoice_item_2 = InvoiceItem.create!(quantity: 2, unit_price: 1300, status: 1, item_id: @item_2.id, invoice_id: @invoice_2.id)
    @invoice_item_3 = InvoiceItem.create!(quantity: 3, unit_price: 999, status: 2, item_id: @item_3.id, invoice_id: @invoice_3.id)
  end

  it 'shows information related to that invoice including id, status, and created_at' do
    visit "/merchants/#{@merchant_1.id}/invoices/#{@invoice_1.id}"
    expect(page).to have_content("Invoice ID: #{@invoice_1.id}")
    expect(page).to have_content("completed")
    expect(page).to have_content("Invoice created at: Friday, September, 16, 2022")
    expect(page).to have_content("Meat Loaf")
  end

  it "shows all my items on the invoice including item name, quantity ordered, price item sold for, and invoice item status" do
    visit "/merchants/#{@merchant_1.id}/invoices/#{@invoice_1.id}"
    expect(page).to have_content("Items on invoice:")
    expect(page).to have_content("Item name: Sourdough")
    expect(page).to have_content("Quantity: 4")
    expect(page).to have_content("Sold at: 850")
    expect(page).to have_content("Status: pending")
  end

  it "total revenue that will be generated from all of items on invoice" do
    visit "/merchants/#{@merchant_1.id}/invoices/#{@invoice_1.id}"
    expect(page).to have_content("Total Revenue without bulk discounts: $34.00")
  end

  it "updates item status" do
    visit "/merchants/#{@merchant_1.id}/invoices/#{@invoice_1.id}"
    expect(page).to have_select('status', selected: "pending")
    select('shipped', from: 'status')
    click_on 'Update Item Status'
    expect(page).to have_select('status', selected: "shipped")
  end

  describe 'revenue with and without discounts' do
    it 'can show total revenue without discounts' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @merchant_2 = Merchant.create!(name: "Carrie Breadshaw")
      @item_1 = Item.create!(name: "Sourdough", description: "leavened, wild yeast", unit_price: 400, merchant_id: @merchant_1.id)
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_2.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 12, unit_price: 100, status: 2, item_id: @item_1.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 1, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_3 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 2, item_id: @item_4.id, invoice_id: @invoice_1.id)
      @discount_a = BulkDiscount.create!(percentage_discount: 20, quantity: 10, merchant_id: @merchant_1.id)
      @discount_b = BulkDiscount.create!(percentage_discount: 30, quantity: 15, merchant_id: @merchant_1.id)
      # When I visit my merchant invoice show page
      visit merchant_invoice_path(@merchant_1, @invoice_1)
      # Then I see the total revenue for my merchant from this invoice (not including discounts)
      expect(page).to have_content("Total Revenue without bulk discounts: $42.00")
    end

    it 'can show revenue with discounts' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @merchant_2 = Merchant.create!(name: "Carrie Breadshaw")
      @item_1 = Item.create!(name: "Sourdough", description: "leavened, wild yeast", unit_price: 400, merchant_id: @merchant_1.id)
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_2.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 12, unit_price: 100, status: 2, item_id: @item_1.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 1, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_3 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 2, item_id: @item_4.id, invoice_id: @invoice_1.id)
      @discount_a = BulkDiscount.create!(percentage_discount: 20, quantity: 10, merchant_id: @merchant_1.id)
      @discount_b = BulkDiscount.create!(percentage_discount: 30, quantity: 15, merchant_id: @merchant_1.id)
      visit merchant_invoice_path(@merchant_1, @invoice_1)
      # And I see the total discounted revenue for my merchant from this invoice which includes bulk discounts in the calculation
      expect(page).to have_content("Total Revenue with bulk discounts: $35.10")
    end
  end
end
