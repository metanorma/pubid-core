require 'forwardable'

module Pubid::Core
  RSpec.describe Type do
    let(:config) do
      config = Pubid::Core::Configuration.new
      config.type_class = Type
      config.default_type = DummyDefaultType
      config.type_names = { default: { long: "Default Type", short: "DEF" },
                            tr: { long: "Technical Report", short: "TR" },
                            ts: { long: "Technical Specification", short: "TS" } }
      config
    end

    let(:default_type) { :default }

    context "when don't have type" do
      subject { described_class.new(config: config) }

      it "assigns default type" do
        expect(subject.type).to eq(:default)
      end
    end

    context "when using symbol" do
      subject { described_class.new(type, config: config) }
      let(:type) { :tr }

      it "returns corresponding string" do
        expect(subject.to_s).to eq("TR")
      end

      it "returns long name" do
        expect(subject.to_s(:long)).to eq("Technical Report")
      end

      context "when using wrong type" do
        let(:type) { :wrong_type }

        it { expect { subject }.to raise_exception(Errors::WrongTypeError) }
      end
    end

    context "when using string" do
      subject { described_class.parse(type_string, config: config) }
      let(:type_string) { "TR" }

      it "returns corresponding symbol" do
        expect(subject.type).to eq(:tr)
      end

      context "when cannot parse type string" do
        let(:type_string) { "WRONG_TYPE" }

        it { expect { subject }.to raise_exception(Errors::ParseTypeError) }
      end
    end

    describe "#==" do
      subject { described_class.new(type, config: config) == another }
      let(:type) { :tr }

      context "when compare with same type" do
        let(:another) { described_class.new(type, config: config) }

        it { is_expected.to be_truthy }
      end

      context "when compare with same type symbol" do
        let(:another) { type }

        it { is_expected.to be_truthy }
      end

      context "when another type" do
        let(:another) { described_class.new(:ts, config: config) }

        it { is_expected.to be_falsey }
      end

      context "when another type is symbol" do
        let(:another) { :ts }

        it { is_expected.to be_falsey }
      end
    end
  end
end
