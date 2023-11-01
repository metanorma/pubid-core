module Pubid::Core
  RSpec.describe HarmonizedStageCode do
    subject { described_class.new(stage, substage, config: DummyTestIdentifier.config) }
    let(:stage) { nil }
    let(:substage) { nil }

    context "when symbol code" do
      let(:stage) { :preparatory }
      let(:substage) { :start_of_main_action }

      it "converts to digit code" do
        expect(subject.to_s).to eq("20.20")
      end

      context "when wrong symbol code" do
        let(:stage) { :wrong_stage }
        let(:substage) { :wrong_substage }

        it "raises error" do
          expect { subject.to_s }.to raise_exception(Errors::HarmonizedStageCodeInvalidError)
        end
      end
    end

    context "when digit code" do
      let(:stage) { "20" }
      let(:substage) { "20" }

      it "returns digit code" do
        expect(subject.to_s).to eq("20.20")
      end

      context "invalid codes" do
        invalid_codes = %w[
          00.92 00.93
          10.93
          20.92 20.93
          30.93
          50.93
          60.20 60.92 60.93 60.98 60.99
          90.00 90.98
          95.00 95.93 95.98
        ]

        invalid_codes.each do |code_string|
          it "invalid stage code #{code_string} should raise an error" do
            expect { described_class.new(*code_string.split("."), config: DummyTestIdentifier.config) }.to raise_exception(Errors::HarmonizedStageCodeInvalidError)
          end
        end
      end
    end

    context "when stage is a string" do
      let(:stage) { "20.20" }

      it "resolves it as stage and substage" do
        expect(subject.to_s).to eq("20.20")
      end

      it "returns stage and substage separately" do
        expect(subject.stage).to eq("20")
        expect(subject.substage).to eq("20")
      end
    end

    context "when have fuzzy stages" do
      let(:stage) { %w[20.00 20.20] }

      it "returns true when compare with stage included in fuzzy stage" do
        expect(subject == HarmonizedStageCode.new("20.20", config: DummyTestIdentifier.config)).to be_truthy
      end

      it "returns true for #fuzzy?" do
        expect(subject.fuzzy?).to be_truthy
      end

      context "when only one stage" do
        let(:stage) { "20.20" }

        it "returns false for #fuzzy?" do
          expect(subject.fuzzy?).to be_falsey
        end
      end

      context "fuzzy stages in the range from 00 to 50" do
        let(:stage) { %w[20.00 20.20 20.60] }

        it "returns draft instead of numbers" do
          expect(subject.to_s).to eq("draft")
        end

        context "when include cancelled stages" do
          let(:stage) { %w[20.00 20.20 20.60 20.98] }

          it "returns draft when try to convert to single stage code" do
            expect(subject.to_s).to eq("draft")
          end
        end
      end

      context "several canceled stages" do
        let(:stage) { %w[10.98 20.98] }

        it "returns draft instead of numbers" do
          expect(subject.to_s).to eq("draft")
        end
      end

      context "several published stages" do
        let(:stage) { %w[60.00 60.60] }

        it "returns published instead of numbers" do
          expect(subject.to_s).to eq("published")
        end
      end
    end
  end
end
