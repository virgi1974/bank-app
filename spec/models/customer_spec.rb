require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { should belong_to(:bank) }
  it { should have_many(:accounts) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:idn) }
  it { should validate_uniqueness_of(:idn) }
end
