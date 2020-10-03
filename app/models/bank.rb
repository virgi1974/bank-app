class Bank < ApplicationRecord
  validates :name, presence: true
  validates :bank_number, presence: true

  has_many :customers
  has_many :bank_conditions
  has_many :accounts, through: :customers
end
