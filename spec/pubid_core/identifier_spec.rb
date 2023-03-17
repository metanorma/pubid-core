module Pubid::Core
  module TestIdentifier
    class << self
      include Pubid::Core::Identifier
    end
  end

  RSpec.describe TestIdentifier do
    let(:config) do
      config = Pubid::Core::Configuration.new
      config.stages = stages
      config.type_class = Type
      config.default_type = DummyDefaultType
      config.types = [DummyTechnicalReportType]
      config.type_names = { tr: { long: "Technical Report",
                                  short: "TR" } }

      config
    end

    let(:stages) do
      {
        "abbreviations" => { "WD" => %w[20.20 20.60 20.98 20.99] },
        "codes_description" => { "20.20" => "Working draft (WD) study initiated" },
        "stage_codes" => { reparatory: "20" },
        "substage_codes" => { start_of_main_action: "20" },
      }
    end

    before do
      described_class.set_config(config)
    end

    describe "#resolve_identifier" do
      subject { described_class.resolve_identifier({ number: 1, publisher: "ISO", type: type, stage: typed_stage }) }
      let(:type) { nil }
      let(:typed_stage) { nil }

      context "when TR type" do
        let(:type) { :tr }

        it { is_expected.to a_kind_of(DummyTechnicalReportType) }
        it { expect(subject.type[:key]).to eq(:tr) }
      end

      context "when no type or typed stage" do
        it { is_expected.to a_kind_of(DummyDefaultType) }
      end
    end

    context "building entities" do
      context "when build stage" do
        subject { described_class.build_stage(harmonized_code: "20.20") }

        it { is_expected.to be_a(Stage) }
        it { expect(subject.to_s).to eq("WD") }
      end

      context "when build type" do
        subject { described_class.build_type(:tr) }

        it { is_expected.to be_a(Type) }
        it { expect(subject.to_s).to eq("TR") }
      end

      context "when build harmonized stage code" do
        subject { described_class.build_harmonized_stage_code("20.20") }

        it { is_expected.to be_a(HarmonizedStageCode) }
        it { expect(subject.to_s).to eq("20.20") }
      end

      context "when apply different configuration" do
        let(:stages) do
          {
            "abbreviations" => { "CD" => %w[20.20] },
            "codes_description" => { "20.20" => "Working draft (WD) study initiated" },
            "stage_codes" => { reparatory: "20" },
            "substage_codes" => { start_of_main_action: "20" },
          }
        end

        context "when build stage" do
          subject { described_class.build_stage(harmonized_code: "20.20") }

          it { is_expected.to be_a(Stage) }
          it { expect(subject.to_s).to eq("CD") }
        end
      end
    end
  end
end
