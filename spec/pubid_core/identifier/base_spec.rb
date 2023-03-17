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

      it { is_expected.to eq({ a: [2, 1] }) }
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
end
