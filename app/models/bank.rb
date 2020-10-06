class Bank < ApplicationRecord
  validates :name, presence: true
  validates :bank_number, presence: true, uniqueness: :true

  has_many :customers
  has_many :bank_conditions
  has_many :accounts, through: :customers
end
