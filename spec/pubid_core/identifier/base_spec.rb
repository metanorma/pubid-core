module Pubid::Core
  class BaseTestIdentifier < Identifier::Base
    def self.get_identifier
      DummyTestIdentifier
    end
  end

  RSpec.describe BaseTestIdentifier do
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

      context "different years" do
        let(:first) { described_class.new(publisher: "ISO", number: 1, year: 1999) }
        let(:second) { described_class.new(publisher: "ISO", number: 1) }

        it { expect(first).not_to eq(second) }

        context "when excluding year" do
          it { expect(first.exclude(:year)).to eq(second) }
        end
      end
    end

    describe "#resolve_typed_stage" do
      context "when harmonized code is matching" do
        let(:harmonized_code) { DummyTestIdentifier.build_harmonized_stage_code("40.00")}

        it { expect(DummyTechnicalReportType.resolve_typed_stage(harmonized_code)).to eq(:dtr) }
      end

      context "when harmonized code is not matching" do
        let(:harmonized_code) { DummyTestIdentifier.build_harmonized_stage_code("20.20")}

        it { expect(DummyTechnicalReportType.resolve_typed_stage(harmonized_code)).to eq(nil) }
      end
    end

    describe "#find_typed_stage" do
      context "typed stage is symbol" do
        let(:typed_stage) { :dtr }

        it do
          expect(DummyTechnicalReportType.find_typed_stage(typed_stage)).to eq(
            # [:dtr, TestIdentifier.build_stage(harmonized_code: %w[40.00])])
            DummyTestIdentifier.build_typed_stage(abbr: :dtr, harmonized_code: %w[40.00]))
        end
      end

      context "typed stage is abbreviation" do
        let(:typed_stage) { "DTR" }

        it do
          expect(DummyTechnicalReportType.find_typed_stage(typed_stage)).to eq(
            DummyTestIdentifier.build_typed_stage(harmonized_code: %w[40.00], abbr: :dtr))
        end
      end
    end

    describe "#has_type?" do
      let(:type) { "TR" }

      it { expect(DummyTechnicalReportType.has_type?(type)).to be_truthy }
      it { expect(DummyInternationalStandardType.has_type?(type)).to be_falsey }
    end

    describe "has_typed_stage?" do
      it { expect(DummyTechnicalReportType.has_typed_stage?("DTR")).to be_truthy }
      it { expect(DummyTechnicalReportType.has_typed_stage?("DTS")).to be_falsey }
    end

    describe "#typed_stage_abbrev" do
      context "when no stage" do
        subject { DummyTestIdentifier.create(type: :tr, number: 1, publisher: "ISO").typed_stage_abbrev }

        it { expect(subject).to eq("TR") }
      end

      context "when stage" do
        subject { DummyTestIdentifier.create(type: :tr, number: 1, publisher: "ISO", stage: "WD").typed_stage_abbrev }

        it { expect(subject).to eq("WD TR") }
      end

      context "when typed stage" do
        subject { DummyTestIdentifier.create(type: :tr, number: 1, publisher: "ISO", stage: :dtr).typed_stage_abbrev }

        it { expect(subject).to eq("DTR") }
      end
    end

    describe "#typed_stage_name" do
      subject { DummyTestIdentifier.create(type: :tr, number: 1, publisher: "ISO").typed_stage_name }

      it { expect(subject).to eq("Technical Report") }
    end

    describe "#resolve_stage" do
      subject { DummyTechnicalReportType.new(publisher: "ISO", number: 1).resolve_stage(stage) }

      context "when stage is a Stage class" do
        context "stage have abbreviation" do
          let(:stage) { DummyTestIdentifier.build_stage(abbr: "WD") }

          it "returns only stage" do
            expect(subject).to eq(stage)
          end
        end

        context "stage have harmonized code but don't have abbreviation" do
          let(:stage) { DummyTestIdentifier.build_stage(harmonized_code: "40.00") }

          it "returns stage with resolved typed stage" do
            expect(subject).to eq(DummyTestIdentifier.build_stage(harmonized_code: %w[40.00], typed_stage: :dtr))
          end
        end
      end

      context "stage is a typed stage" do
        let(:stage) { "DTR" }

        it "returns typed stage and according abbreviation" do
          expect(subject).to eq(DummyTestIdentifier.build_typed_stage(harmonized_code: %w[40.00], abbr: :dtr))
        end
      end

      context "stage is a String" do
        let(:stage) { "WD" }

        it "returns stage" do
          expect(subject).to eq(DummyTestIdentifier.build_stage(abbr: "WD"))
        end
      end

      context "stage is harmonized code" do
        let(:stage) { "40.00" }

        it "returns stage and according typed stage abbreviation" do
          expect(subject).to eq(DummyTestIdentifier.build_stage(harmonized_code: %w[40.00], typed_stage: :dtr))
        end

        context "harmonized code for stage" do
          let(:stage) { "20.20" }

          it "returns stage" do
            expect(subject).to eq(DummyTestIdentifier.build_stage(abbr: "WD"))
          end
        end
      end

      context "wrong stage" do
        let(:stage) { "WRONG_STAGE" }

        it "raises an error" do
          expect { subject }.to raise_exception(Pubid::Core::Errors::StageInvalidError)
        end
      end
    end

    describe "#to_h" do
      subject { DummyTestIdentifier.create(**params).to_h }

      let(:params) { { type: "tr", number: 1, publisher: "ISO" } }

      it { expect(subject).to eq(params) }

      context "with typed_stage" do
        let(:params) { { type: "tr", number: 1, publisher: "ISO", stage: :dtr } }

        it { expect(subject).to eq(params) }
      end

      context "with stage" do
        let(:params) { { type: "tr", number: 1, publisher: "ISO", stage: "WD" } }

        it { expect(subject).to eq(params) }
      end

      context "with amendments" do
        let(:params) { { type: "tr", number: 1, publisher: "ISO", amendments: [{ number: 1, year: 2000 }, { number: 2, year: 2000 }] } }

        it { expect(subject).to eq(params) }
      end
    end
  end
end
