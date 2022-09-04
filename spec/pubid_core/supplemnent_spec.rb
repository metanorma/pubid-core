RSpec.describe Pubid::Core::Supplement do
  describe "#==" do
    subject do
      first_supplement == second_supplement
    end

    let(:first_supplement) do
      described_class.new(number: 1, year: first_supplement_year)
    end
    let(:second_supplement) do
      described_class.new(number: 1, year: second_supplement_year)
    end
    let(:first_supplement_year) { nil }
    let(:second_supplement_year) { nil }

    context "when have equal supplement version and year" do
      let(:first_supplement_year) { 2000 }
      let(:second_supplement_year) { 2000 }

      it { is_expected.to be_truthy }
    end

    context "when query don't have a year" do
      let(:second_supplement_year) { 2000 }

      it { is_expected.to be_truthy }
    end

    context "when years is different" do
      let(:first_supplement_year) { 2001 }
      let(:second_supplement_year) { 2000 }

      it { is_expected.to be_falsey }
    end
  end

  describe "#=>" do
    subject do
      first_supplement > second_supplement
    end

    let(:first_supplement) do
      described_class.new(number: first_supplement_version, year: first_supplement_year)
    end

    let(:second_supplement) do
      described_class.new(number: second_supplement_version, year: second_supplement_year)
    end

    let(:first_supplement_year) { nil }
    let(:second_supplement_year) { nil }
    let(:first_supplement_version) { nil }
    let(:second_supplement_version) { nil }

    context "when the first supplement year is newer" do
      let(:first_supplement_year) { 2001 }
      let(:second_supplement_year) { 2000 }

      it { is_expected.to be_truthy }
    end

    context "when the first supplement year is older" do
      let(:first_supplement_year) { 2000 }
      let(:second_supplement_year) { 2001 }

      it { is_expected.to be_falsey }
    end

    context "when the first supplement version is higher" do
      let(:first_supplement_version) { 2 }
      let(:second_supplement_version) { 1 }

      it { is_expected.to be_truthy }
    end

    context "when the first supplement version is lower" do
      let(:first_supplement_version) { 1 }
      let(:second_supplement_version) { 2 }

      it { is_expected.to be_falsey }
    end

    # context "when the first supplement don't have version" do
    #   let(:second_supplement_version) { 1 }
    #
    #   it { is_expected.to be_truthy }
    # end
  end

  describe "rendering" do
    subject do
      described_class.new(number: 1, year: supplement_year)
    end

    let(:supplement_year) { 2000 }

    let(:pubid_number) { "1:2000" }
    let(:urn_number) { ":2000:v1" }

    it { expect(subject.render_pubid_number).to eq(pubid_number) }
    it { expect(subject.render_urn_number).to eq(urn_number) }
  end
end
