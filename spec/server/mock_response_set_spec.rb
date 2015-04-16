require 'spec_helper'
require 'mock_response_set'
describe Mirage::MockResponseSet do

  it 'extends Hash' do
    expect(subject).to be_a(Hash)
  end
  describe '#fuzzy_find' do

    let(:expected_greeting){'hello'}
    let(:greeting_key){'/greeting'}

    subject do
      described_class.new.tap do |subject|
        subject[greeting_key] = expected_greeting
      end
    end

    context 'key is not a regex' do
      context 'input is the same' do
        it 'returns the stored value' do
          expect(subject.fuzzy_find(greeting_key)).to eq(expected_greeting)
        end
      end

      context 'input is different' do
        it 'returns nil' do
          expect(subject.fuzzy_find('/salutation')).to eq(nil)
        end

      end

    end

    context 'key is a regular expression' do
      subject do
        described_class.new.tap do |subject|
          subject[%r{.*ting}] = expected_greeting
        end
      end

      context 'input is matches regex' do
        it 'returns the stored value' do
          expect(subject.fuzzy_find(greeting_key)).to eq(expected_greeting)
        end
      end

      context 'input does not match regex' do
        it 'returns nil' do
          subject[%r{.*ting}] = expected_greeting
          expect(subject.fuzzy_find('/salutation')).to eq(nil)
        end

      end
    end
  end
end