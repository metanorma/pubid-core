module Pubid::Core
  class TestEntity < Entity
    attr_accessor :type, :number

    def initialize(type:,number:)
      @number, @type = number, type
    end
  end

  RSpec.describe TestEntity do
    describe "#==" do
      subject do
        first_entity == second_entity
      end

      let(:first_entity) do
        described_class.new(number: 1, type: 2)
      end
      let(:second_entity) do
        described_class.new(number: 1, type: 2)
      end

      context "when have equal entity parameters" do
        it { is_expected.to be_truthy }
      end

      context "when different parameters" do
        let(:second_entity) do
          described_class.new(number: 1, type: 3)
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
