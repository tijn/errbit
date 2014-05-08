require 'spec_helper'

describe PriorityFiltersController do
  it_requires_authentication
  it_requires_admin_privileges

  let(:admin) { Fabricate(:admin) }
  let(:filter) { Fabricate(:priority_filter, :where => 'test') }
  before { sign_in admin}

  describe 'GET #index' do
    it 'populates an array with all filters' do
      get :index
      expect(controller.priority_filters).to match_array PriorityFilter.all
    end
  end

  describe 'GET #show' do
    before { get :show, :id => filter.id }

    it 'assigns the requested filter to @priority_filter' do
      expect(controller.priority_filter).to eq filter
    end

    it 'renders the :show template' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'assigns a new Filter to @filter' do
      expect(controller.priority_filter).to be_a_new PriorityFilter
    end

    it 'renders the :new template' do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before { get :edit, :id => filter.id }

    it 'assigns the filter to @filter' do
      expect(controller.priority_filter).to eq filter
    end

    it 'renders the :edit template' do
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:attributes) { Fabricate.attributes_for :priority_filter, :where => 'test' }

      it 'saves the new filter in the database' do
        expect {
          post :create, :priority_filter => attributes
        }.to change(PriorityFilter, :count).by(1)
      end

      it 'creates association with application when specified' do
        attributes[:app_id] = Fabricate(:app).id
        expect {
          post :create, :priority_filter => attributes
        }.to change(PriorityFilter, :count).by(1)
      end

      it 'redirecs to filter#show' do
        post :create, :priority_filter => attributes
        expect(response).to redirect_to priority_filter_path(controller.priority_filter)
      end
    end

    context 'with invalid attributes' do
      let(:attributes) { Fabricate.attributes_for(:empty_filter, :message => '') }
      it 'does not save the new product in the database' do
        expect {
          post :create, :priority_filter => attributes
        }.to_not change(PriorityFilter, :count)
      end

      it 're-renders the :new template' do
        post :create, :priority_filter => attributes
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      before do
        attributes = Fabricate.attributes_for(:priority_filter, :where => 'hello world')
        put :update, :id => filter.id, :priority_filter => attributes
        filter.reload
      end

      it 'locates the requested filter' do
        expect(controller.priority_filter).to eq filter
      end

      it 'updates the filter in the database' do
        expect(filter.where).to eq 'hello world'
      end

      it 'redirects to the filter' do
        expect(response).to redirect_to priority_filter_url(filter)
      end
    end

    context 'with invalid attributes' do
      before do
        attributes = Fabricate.attributes_for(:empty_filter, :message => '')
        put :update, :id => filter.id, :priority_filter => attributes
        filter.reload
      end

      it 'does not change the filter\'s attributes' do
        expect(filter.where).to_not eq 'hello world'
      end

      it 're-renders the :edit template' do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:filter) { Fabricate(:priority_filter, :where => 'test') }

    it 'deletes the filter' do
      expect {
        delete :destroy, :id => filter.id
      }.to change(PriorityFilter, :count).by(-1)
    end

    it 'redirects to filters#index' do
      delete :destroy, :id => filter.id
      expect(response).to redirect_to priority_filters_url
    end
  end
end
