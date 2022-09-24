class Invoice < ApplicationRecord
  validates_presence_of :status
  enum status: { "in progress" => 0, "cancelled" => 1, "completed" => 2}

  belongs_to :customer
  has_many :invoice_items
  has_many :transactions
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def discounted_revenue
    invoice_items.joins(merchants: :bulk_discounts)
    .where("invoice_items.quantity >= bulk_discounts.quantity")
    .select('invoice_items.*, max(invoice_items.quantity * invoice_items.unit_price * (bulk_discounts.percentage_discount / 100.0)) as total_discount')
    .group('invoice_items.id').sum(&:total_discount)
  end

end
