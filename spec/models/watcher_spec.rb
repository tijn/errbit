require 'spec_helper'

describe Watcher do

  context 'validations' do
    it 'requires an email address or an associated user' do
      watcher = Fabricate.build(:watcher, :email => nil, :user => nil)
      expect(watcher).to_not be_valid
      expect(watcher.errors[:base]).to include("You must specify either a user or an email address")

      watcher.email = 'watcher@example.com'
      expect(watcher).to be_valid

      watcher.email = nil
      expect(watcher).to_not be_valid

      watcher.user = Fabricate(:user)
      watcher.watcher_type = 'user'
      expect(watcher).to be_valid
    end
  end

  context 'responsibility' do
    let(:watcher) { Fabricate(:watcher, email: 'watcher@has.no.mail') }
    let(:watcher2) { Fabricate(:watcher, email: 'watcher2@has.no.mail') }
    let(:app) { Fabricate(:app) }

    before do
      app.watchers << watcher
      app.watchers << watcher2
    end

    it 'is set to false by default' do
      expect(watcher.responsible?).to eq false
    end

    it 'allows only one to be responsible' do
      watcher.assign!
      expect(watcher.responsible?).to eq true
      expect(watcher2.responsible?).to eq false
      watcher2.assign!
      expect(watcher.responsible?).to eq false
      expect(watcher2.responsible?).to eq true
    end

    it 'switches automatically between responsible person' do
      watcher2.assign!
      expect(watcher.responsible?).to eq false
      expect(watcher2.responsible?).to eq true
      watcher.assign!
      expect(watcher.responsible?).to eq true
      expect(watcher2.responsible?).to eq false
    end
  end

  context 'address' do
    it "returns the user's email address if there is a user" do
      user = Fabricate(:user, :email => 'foo@bar.com')
      watcher = Fabricate(:user_watcher, :user => user)
      expect(watcher.address).to eq 'foo@bar.com'
    end

    it "returns the email if there is no user" do
      watcher = Fabricate(:watcher, :email => 'widgets@acme.com')
      expect(watcher.address).to eq 'widgets@acme.com'
    end
  end

end

