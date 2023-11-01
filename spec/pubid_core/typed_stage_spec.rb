module Pubid::Core
  RSpec.describe TypedStage do
    context "when abbreviation" do
      subject { described_class.new(config: DummyTestIdentifier.config, abbr: abbrev) }
      let(:abbrev) { :dtr }

      it "returns correct harmonized stage code" do
        expect(subject.harmonized_code).to eq(
          Pubid::Core::HarmonizedStageCode.new(["40.00"],
                                               config: DummyTestIdentifier.config))
      end

      context "wrong code" do
        let(:abbrev) { :ABC }

        it "raise an error" do
          expect { subject }.to raise_exception(Pubid::Core::Errors::TypedStageInvalidError)
        end
      end

      context "#to_s" do
        it "returns string representation" do
          expect(subject.to_s).to eq("DTR")
        end
      end
    end
  end
end
