RSpec.describe Pubid::Core::Transformer do
  context "All parts rule" do
    # context "should return true for '(all parts)'" do
    #   let(:tree) { { all_parts: "(all parts)" } }
    #   it { expect(described_class.new.apply(tree)).to eq all_parts: true }
    # end

    context "should return false if no all parts is presented'" do
      let(:tree) { {} }
      it { expect(described_class.new.apply(tree)).to eq({}) }
    end
  end
end
