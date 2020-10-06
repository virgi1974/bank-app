require 'rails_helper'

RSpec.describe TaBankRegister, type: :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:bank_number) }
    it { should validate_uniqueness_of(:bank_number) }
    it { should validate_presence_of(:host) }
    it { should validate_uniqueness_of(:host) }
  end
end
