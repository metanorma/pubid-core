Pubid::Core.configure do |config|

end
module Pubid::Core
  RSpec.describe Stage do
    let(:config) do
      config = Configuration.new
      config.stages = {}
      config.stages["abbreviations"] = {
        "WD" => %w[20.20 20.60 20.98 20.99],
        "AWI" => %w[20.00 10.99],
        "PRF" => %w[50.00 50.20 50.60 50.92 50.98 50.99],
        "CD" => %w[30.00 30.20 30.60 30.92 30.98 30.99],
      }
      config.stages["codes_description"] = {
        "00.00" => "Proposal for new project received",
        "00.98" => "Proposal for new project abandoned",
        "10.98" => "New project rejected",
        "10.99" => "New project approved",
        "20.00" => "New project registered in TC/SC work programme",
        "20.20" => "Working draft (WD) study initiated",
        "20.60" => "Close of comment period",
        "20.98" => "Project deleted",
        "20.99" => "WD approved for registration as CD",
        "30.00" => "Committee draft (CD) registered",
        "30.20" => "CD study/ballot initiated",
        "30.60" => "Close of voting/ comment period",
        "30.92" => "CD referred back to Working Group",
        "30.98" => "Project deleted",
        "30.99" => "CD approved for registration as DIS",
        "50.00" => "Final text received or FDIS registered for formal approval",
        "50.20" => "Proof sent to secretariat or FDIS ballot initiated: 8 weeks",
        "50.60" => "Close of voting. Proof returned by secretariat",
        "50.92" => "FDIS or proof referred back to TC or SC",
        "50.98" => "Project deleted",
        "50.99" => "FDIS or proof approved for publication",
        "60.00" => "International Standard under publication",
        "60.60" => "International Standard published",
      }
      config.stages["draft_codes"] = %w[00.00 00.20 20.00 20.20 20.60]
      config.stages["canceled_codes"] = %w[00.98 10.98 20.98]
      config.stages["published_codes"] = %w[60.00 60.60]
      config.stages["stage_codes"] = { "approval" => "50" }
      config.stages["substage_codes"] = { "registration" => "00" }
      config.stages["names"] = {
        "WD" => "Working Draft",
        "PWI" => "Preliminary Work Item",
        "NP" => "New Proposal",
        "CD" => "Committee Draft",
        "PRF" => "Proof of a new International Standard",
      }
      config
    end
    context "when abbreviation" do
      subject { described_class.new(config: config, abbr: abbrev) }
      let(:abbrev) { :WD }

      it "returns correct harmonized stage code" do
        expect(subject.harmonized_code).to eq(Pubid::Core::HarmonizedStageCode.new(config.stages["abbreviations"][abbrev.to_s], config: config))
      end

      context "wrong code" do
        let(:abbrev) { :ABC }

        it "raise an error" do
          expect { subject }.to raise_exception(Pubid::Core::Errors::StageInvalidError)
        end
      end
    end

    context "when harmonized stage code" do
      subject { described_class.new(config: config, harmonized_code: harmonized_code) }
      let(:harmonized_code) { harmonized_code_object }
      let(:harmonized_code_object) { Pubid::Core::HarmonizedStageCode.new(config.stages["abbreviations"]["WD"], config: config) }

      it "returns abbreviated code" do
        expect(subject.abbr).to eq("WD")
      end

      context "when harmonized_code is a string" do
        let(:harmonized_code) { "50.00" }

        it "assigns correct harmonized stage code" do
          expect(subject.harmonized_code.stages).to eq([harmonized_code])
        end

        context "when harmonized_code has only stage" do
          let(:harmonized_code) { "50" }

          it "assigns correct harmonized stage code" do
            expect(subject.harmonized_code.stages).to eq(["#{harmonized_code}.00"])
          end
        end

        context "when harmonized_code 60.00" do
          let(:harmonized_code) { "60.00" }

          it "returns abbreviated code" do
            expect(subject.abbr).to eq(nil)
          end
        end

        context "when harmonized_code 20.60" do
          let(:harmonized_code) { "20.60" }

          it "returns abbreviated code" do
            expect(subject.abbr).to eq("WD")
          end
        end

        context "when harmonized_code 10.99" do
          let(:harmonized_code) { "10.99" }

          it "returns abbreviated code" do
            expect(subject.abbr).to eq("AWI")
          end
        end

        context "when harmonized_code 20.00" do
          let(:harmonized_code) { "20.00" }

          it "returns abbreviated code" do
            expect(subject.abbr).to eq("AWI")
          end
        end

        context "when harmonized_code 50.20" do
          let(:harmonized_code) { "50.20" }

          it "returns abbreviated code" do
            expect(subject.abbr).to eq("PRF")
          end
        end

        context "when harmonized_code 60.60" do
          let(:harmonized_code) { "60.60" }

          it "returns abbreviated code" do
            expect(subject.abbr).to eq(nil)
          end
        end
      end
    end

    context "when harmonized code and abbreviation" do
      subject { described_class.new(config: config, harmonized_code: harmonized_code, abbr: abbrev) }
      let(:harmonized_code) { Pubid::Core::HarmonizedStageCode.new("20", "00", config: config) }
      let(:abbrev) { :CD }

      it "returns abbreviated code" do
        expect(subject.abbr).to eq(abbrev.to_s)
      end

      it "returns harmonized code" do
        expect(subject.harmonized_code).to eq(harmonized_code)
      end
    end

    describe "#==" do
      subject do
        first_stage == second_stage
      end

      context "when have the same harmonized_code" do
        let(:first_stage) do
          described_class.new(config: config, harmonized_code: "50.00")
        end
        let(:second_stage) do
          described_class.new(config: config, harmonized_code: "50.00")
        end

        it { is_expected.to be_truthy }
      end

      context "when have the different harmonized_code" do
        let(:first_stage) do
          described_class.new(config: config, harmonized_code: "50.00")
        end
        let(:second_stage) do
          described_class.new(config: config, harmonized_code: "20.00")
        end

        it { is_expected.to be_falsey }
      end
    end

    describe "#name" do
      subject { described_class.new(config: config, abbr: abbrev).name }

      context "when stage CD" do
        let(:abbrev) { :CD }

        it { is_expected.to eq("Committee Draft") }
      end
    end

    describe "#has_stage?" do
      subject { described_class.has_stage?(stage, config: config) }

      context "when existing stage" do
        let(:stage) { "CD" }

        it { is_expected.to be_truthy }
      end

      context "when not existing stage" do
        let(:stage) { "ABC" }

        it { is_expected.to be_falsey }
      end
    end

    describe "#empty_abbr?" do
      subject { described_class.new(config: config, abbr: abbrev).empty_abbr?(with_prf: with_prf) }
      let(:with_prf) { false }

      context "when abbr is nil" do
        let(:abbrev) { nil }

        it { is_expected.to be_truthy }
      end

      context "when PRF stage" do
        let(:abbrev) { :PRF }

        it { is_expected.to be_truthy }

        context "with option with_prf == true" do
          let(:with_prf) { true }

          it { is_expected.to be_falsey }
        end
      end

      context "when CD stage" do
        let(:abbrev) { :CD }

        it { is_expected.to be_falsey }
      end
    end

    describe "#to_s" do
      subject { described_class.new(config: config, abbr: abbrev).to_s(opts) }
      let(:opts) { {} }

      context "when CD" do
        let(:abbrev) { :CD }

        it { is_expected.to eq("CD") }
      end

      context "when PRF" do
        let(:abbrev) { :PRF }

        it { is_expected.to be_empty }

        context "when option with_prf true" do
          let(:opts) { { with_prf: true } }

          it { is_expected.to eq("PRF") }
        end
      end
    end
  end
end
