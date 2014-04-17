require 'spec_helper'

describe WatchersController do
  let(:app) do
    a = Fabricate(:app)
    Fabricate(:user_watcher, :app => a)
    Fabricate(:user_watcher, :app => a)
    a
  end

  describe 'PUT /apps/:app_id/watchers/:id/assign' do
    context 'with admin user' do
      before(:each) do
        sign_in Fabricate(:admin)
      end

      context 'assigns the watcher' do
        let(:problem) { Fabricate(:problem_with_comments) }
        let(:watcher) { app.watchers.first }
        let(:watcher2) { app.watchers.last }
        before { watcher2.assign! }
        before(:each) do
          put :assign, app_id: app.id, id: watcher.user.id
          watcher.reload
        end

        it 'assigns the watcher' do
          expect(watcher.responsible?).to eq true
        end

        it 'unassigns the current assignee' do
          expect(watcher.responsible?).to eq true
          expect(watcher2.responsible?).to eq false
        end

        it 'redirects to app' do
          expect(response).to redirect_to app_path(app)
        end
      end
    end
  end

  describe "DELETE /apps/:app_id/watchers/:id/destroy" do

    context "with admin user" do
      before(:each) do
        sign_in Fabricate(:admin)
      end

      context "successful watcher deletion" do
        let(:problem) { Fabricate(:problem_with_comments) }
        let(:watcher) { app.watchers.first }

        before(:each) do
          delete :destroy, :app_id => app.id, :id => watcher.user.id.to_s
          problem.reload
        end

        it "should delete the watcher" do
          expect(app.watchers.detect{|w| w.id.to_s == watcher.id }).to be nil
        end

        it "should redirect to index page" do
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
