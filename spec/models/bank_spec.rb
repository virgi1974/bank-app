require 'rails_helper'

RSpec.describe Bank, type: :model do
  it { should have_many(:customers) }
  it { should have_many(:bank_conditions) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:bank_number) }
end
