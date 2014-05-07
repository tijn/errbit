require 'spec_helper'

describe Filter do
  context "attributes" do
    it { should have_fields(:message, :error_class, :url, :where) }
  end

  let!(:filter) { Fabricate.build(:empty_filter, :message => '') }
  let(:notice) { Fabricate.build(:notice, error_class: 'FooError') }
  before do
    allow(notice).to receive(:url).and_return('http://example.com/apple-touch-icon.png')
    allow(notice).to receive(:where).and_return('application#index')
  end

  context 'validation' do
    it 'is valid with one criterium' do
      filter.where = 'test'
      expect(filter.valid?).to eq true
    end

    it 'is invalid with no criterium' do
      expect(filter.valid?).to eq false
    end
  end

  context 'message' do
    it 'matches "Too Much Bar"' do
      filter.message = 'Too Much Bar'
      expect(filter.matches notice).to include true
    end

    it 'matches not "abc123"' do
      filter.message = 'abc123'
      expect(filter.matches notice).to_not include true
    end

    it 'matches "^FooError" as regex' do
      filter.message = '^FooError'
      expect(filter.matches notice).to include true
    end

    it 'matches "FooError:(.*?)Bar" as regex' do
      filter.message = 'FooError:(.*?)Bar'
      expect(filter.matches notice).to include true
    end
  end

  context 'error_class' do
    it 'matches "FooError"' do
      filter.error_class = 'FooError'
      expect(filter.matches notice).to include true
    end

    it 'matches "Error" in part' do
      filter.error_class = 'Error'
      expect(filter.matches notice).to include true
    end

    it 'matches not "abc123"' do
      filter.error_class = 'abc123'
      expect(filter.matches notice).to_not include true
    end

    it 'matches "Foo(Bar|Error)" as regex' do
      filter.error_class = 'Foo(Bar|Error)'
      expect(filter.matches notice).to include true
    end
  end

  context 'url' do
    it 'matches "http://example.com"' do
      filter.url = 'http://example.com'
      expect(filter.matches notice).to include true
    end

    it 'matches "example" in part' do
      filter.url = 'example'
      expect(filter.matches notice).to include true
    end

    it 'matches not "abc123"' do
      filter.url = 'abc123'
      expect(filter.matches notice).to_not include true
    end

    it 'matches "http://example\.com/(.*?)\.png" as regex' do
      filter.url = 'http://example\.com/(.*?)\.png'
      expect(filter.matches notice).to include true
    end
  end

  context 'where' do
    it 'matches "application#index"' do
      filter.where = 'application#index'
      expect(filter.matches notice).to include true
    end

    it 'matches "#index" in part' do
      filter.where = '#index'
      expect(filter.matches notice).to include true
    end

    it 'matches not "abc123"' do
      filter.where = 'abc123'
      expect(filter.matches notice).to_not include true
    end

    it 'matches "application#(test|index)" as regex' do
      filter.where = 'application#(test|index)'
      expect(filter.matches notice).to include true
    end
  end

  context 'multiple criteria' do
    it 'matches none' do
      filter.where = 'application#help'
      filter.error_class = 'FooBar'
      result = filter.matches(notice).compact
      expect(result).to eq [false, false]
    end

    it 'matches one matches' do
      filter.where = 'application#index'
      filter.error_class = 'FooBar'
      result = filter.matches(notice).compact
      expect(result).to eq [false, true]
    end

    it 'all criteria matches' do
      filter.where = 'application#index'
      filter.error_class = 'FooError'
      result = filter.matches(notice).compact
      expect(result).to eq [true, true]
    end
  end

  context 'can belong to an application' do
    let(:filter) { Fabricate(:filter) }
    it 'has reference to an application' do
      app = Fabricate(:app)
      filter.app = app
      expect(filter.app).to eq app
    end

    it 'can be global by not specifying an application' do
      filter.app = nil
      expect(filter.app).to eq nil
      expect(filter.valid?).to eq true
    end
  end
end
