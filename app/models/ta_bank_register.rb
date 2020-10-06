class TaBankRegister < ApplicationRecord
  validates :name, presence: true, uniqueness: :true
  validates :bank_number, presence: true, uniqueness: :true
  validates :host, presence: true, uniqueness: :true
end
