RSpec.describe Pubid::Core::Identifier do
  subject { described_class.parse(original) }

  describe "#initialize" do
    subject { described_class.new(**params) }

    context "when apply amendments" do
      context "when several amendments" do
        let(:params) { { publisher: "ISO", number: 1234, amendments: [{ version: 1, number: 2000 }, { version: 2, number: 2000 }] } }

        it "asigns amendments" do
          expect(subject.amendments)
            .to eq([Pubid::Core::Amendment.new(version: 1, number: 2000),
                    Pubid::Core::Amendment.new(version: 2, number: 2000)])
        end
      end

      context "when single amendment" do
        let(:params) { { publisher: "ISO", number: 1234, amendments: { version: 1, number: 2016 } } }

        it "assigns amendment" do
          expect(subject.amendments)
            .to eq([Pubid::Core::Amendment.new(version: 1, number: 2016)])
        end
      end
    end

    context "when apply corrigendum" do
      context "when several corrigendums" do
        let(:params) { { publisher: "ISO", number: 1234, corrigendums: [{ version: 1, number: 2000 }, { version: 2, number: 2000 }] } }

        it "asigns corrigendums" do
          expect(subject.corrigendums)
            .to eq([Pubid::Core::Corrigendum.new(version: 1, number: 2000),
                    Pubid::Core::Corrigendum.new(version: 2, number: 2000)])
        end
      end

      context "when single corrigendum" do
        let(:params) { { publisher: "ISO", number: 1234, corrigendums: { version: 1, number: 2016 } } }

        it "assigns corrigendum" do
          expect(subject.corrigendums)
            .to eq([Pubid::Core::Corrigendum.new(version: 1, number: 2016)])
        end
      end
    end
  end

  describe "#to_s" do
    subject { described_class.new(publisher: "ISO", number: 1234).to_s }

    it { is_expected.to eq("ISO 1234") }
  end
end
