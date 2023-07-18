RSpec.describe Pubid::Core::Identifier::Base do
  subject { described_class.parse(original) }

  describe "#initialize" do
    subject { described_class.new(**params) }

    context "when apply amendments" do
      context "when several amendments" do
        let(:params) do
          { publisher: "ISO",
            number: 1234,
            amendments: [Pubid::Core::Amendment.new(number: 1, year: 2000),
                         Pubid::Core::Amendment.new(number: 2, year: 2000)] }
        end

        it "asigns amendments" do
          expect(subject.amendments)
            .to eq([Pubid::Core::Amendment.new(number: 1, year: 2000),
                    Pubid::Core::Amendment.new(number: 2, year: 2000)])
        end
      end

      context "when amendments as hash of parameters" do
        let(:params) do
          { publisher: "ISO",
            number: 1234,
            amendments: [{ number: 1, year: 2000 }, { number: 2, year: 2000 }] }
        end

        it "asigns amendments" do
          expect(subject.amendments)
            .to eq([Pubid::Core::Amendment.new(number: 1, year: 2000),
                    Pubid::Core::Amendment.new(number: 2, year: 2000)])
        end

        context "when only number" do
          let(:params) do
            { publisher: "ISO",
              number: 1234,
              amendments: [{ number: 1 }] }
          end

          it "asigns amendments" do
            expect(subject.amendments)
              .to eq([Pubid::Core::Amendment.new(number: 1)])
          end
        end
      end
    end

    context "when apply corrigendum" do
      context "when several corrigendums" do
        let(:params) do
          { publisher: "ISO", number: 1234, corrigendums:
            [Pubid::Core::Corrigendum.new(number: 1, year: 2000),
             Pubid::Core::Corrigendum.new(number: 2, year: 2000)]
          }
        end

        it "asigns corrigendums" do
          expect(subject.corrigendums)
            .to eq([Pubid::Core::Corrigendum.new(number: 1, year: 2000),
                    Pubid::Core::Corrigendum.new(number: 2, year: 2000)])
        end
      end

      context "when corrigendums as hash of parameters" do
        let(:params) do
          { publisher: "ISO",
            number: 1234,
            corrigendums: [{ number: 1, year: 2000 }, { number: 2, year: 2000 }] }
        end

        it "asigns corrigendums" do
          expect(subject.corrigendums)
            .to eq([Pubid::Core::Corrigendum.new(number: 1, year: 2000),
                    Pubid::Core::Corrigendum.new(number: 2, year: 2000)])
        end
      end
    end
  end

  describe "#parse" do
    subject { described_class.parse(**params) }

    context "when apply amendments" do
      context "when several amendments" do
        let(:params) { { publisher: "ISO", number: 1234, amendments: [{ number: 1, year: 2000 }, { number: 2, year: 2000 }] } }

        it "asigns amendments" do
          expect(subject.amendments)
            .to eq([Pubid::Core::Amendment.new(number: 1, year: 2000),
                    Pubid::Core::Amendment.new(number: 2, year: 2000)])
        end
      end

    end
  end

  describe "#array_to_hash" do
    subject { described_class.array_to_hash(input) }
    let(:input) { [{ a: 1 }, { b: 2 }] }

    it "merges all hashes" do
      is_expected.to eq({ a: 1, b: 2 })
    end

    context "when same key repeating" do
      let(:input) { [{ a: 1 }, { a: 2 }] }

      it { is_expected.to eq({ a: [1, 2] }) }
    end
  end

  describe "#transform" do
    subject { described_class.transform(parsed_data) }

    context "when have corrigendum" do
      let(:parsed_data) { { publisher: "ISO", number: 1234, corrigendums: [{ number: 1, year: 2016 }] } }

      it "transform parsed data" do
        expect(subject.corrigendums).to eq([Pubid::Core::Corrigendum.new(number: 1, year: 2016)])
      end

      context "when only one corrigendum" do
        let(:parsed_data) { { publisher: "ISO", number: 1234, corrigendums: { :number=>"1", :year=>"2016" } } }

        it "transform parsed data" do
          expect(subject.corrigendums).to eq([Pubid::Core::Corrigendum.new(number: 1, year: 2016)])
        end
      end
    end

    context "when have amendment" do
      let(:parsed_data) { { publisher: "ISO", number: 1234, amendments: [{ number: 1, year: 2016 }] } }

      it "transform parsed data" do
        expect(subject.amendments).to eq([Pubid::Core::Amendment.new(number: 1, year: 2016)])
      end

      context "when only one amendment" do
        let(:parsed_data) { { publisher: "ISO", number: 1234, amendments: { :number=>"1", :year=>"2016" } } }

        it "transform parsed data" do
          expect(subject.amendments).to eq([Pubid::Core::Amendment.new(number: 1, year: 2016)])
        end
      end
    end
  end

  describe "#==" do
    subject { described_class.new(publisher: "ISO", number: 1) }

    context "when equal identifiers" do
      it { expect(subject).to eq(described_class.new(publisher: "ISO", number: 1)) }
    end

    context "when different identifiers" do
      it { expect(subject).not_to eq(described_class.new(publisher: "ISO", number: 2)) }
    end
  end

  describe "#resolve_typed_stage" do
    context "when harmonized code is matching" do
      let(:harmonized_code) { TestIdentifier.build_harmonized_stage_code("40.00")}

      it { expect(TR.resolve_typed_stage(harmonized_code)).to eq(:dtr) }
    end

    context "when harmonized code is not matching" do
      let(:harmonized_code) { TestIdentifier.build_harmonized_stage_code("20.20")}

      it { expect(TR.resolve_typed_stage(harmonized_code)).to eq(nil) }
    end
  end

  describe "#find_typed_stage" do
    context "typed stage is symbol" do
      let(:typed_stage) { :dtr }

      it do
        expect(TR.find_typed_stage(typed_stage)).to eq(
          [:dtr, TestIdentifier.build_stage(harmonized_code: %w[40.00])])
      end
    end

    context "typed stage is abbreviation" do
      let(:typed_stage) { "DTR" }

      it do
        expect(TR.find_typed_stage(typed_stage)).to eq(
          [:dtr, TestIdentifier.build_stage(harmonized_code: %w[40.00])])
      end
    end
  end

  describe "#has_type?" do
    let(:type) { "TR" }

    it { expect(TR.has_type?(type)).to be_truthy }
    it { expect(IS.has_type?(type)).to be_falsey }
  end

  describe "has_typed_stage?" do
    it { expect(TR.has_typed_stage?("DTR")).to be_truthy }
    it { expect(TR.has_typed_stage?("DTS")).to be_falsey }
  end
end

class TR < Pubid::Core::Identifier::Base
  TYPED_STAGES = {
    dtr: {
      abbr: "DTR",
      name: "Draft Technical Report",
      harmonized_stages: %w[40.00],
    },
  }.freeze

  def self.type
    { key: :tr, title: "Technical Report", short: "TR" }
  end

  def self.get_identifier
    TestIdentifier
  end
end

class IS < Pubid::Core::Identifier::Base
  def self.type
    { key: :is, title: "International Standard", short: "IS" }
  end
end

module TestIdentifier
  class << self
    include Pubid::Core::Identifier
  end
end

stages = {
  "abbreviations" => { "WD" => %w[20.20 20.60 20.98 20.99] },
  "codes_description" => { "20.20" => "Working draft (WD) study initiated",
                           "40.00" => "DIS registered" },
  "stage_codes" => { reparatory: "20" },
  "substage_codes" => { start_of_main_action: "20" },
}

config = Pubid::Core::Configuration.new
config.stages = stages
# config.type_class = Type
config.default_type = IS
config.types = [IS, TR]
config.type_names = { tr: { long: "Technical Report",
                            short: "TR" } }

TestIdentifier.set_config(config)
