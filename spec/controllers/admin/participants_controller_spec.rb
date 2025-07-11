require 'rails_helper'

RSpec.describe Admin::ParticipantsController, type: :controller do
  let(:participant) { Participant.create!(name: 'John', age: 30) }

  describe 'GET #index' do
    it 'assigns all participants' do
      participant
      get :index
      expect(assigns(:participants)).to eq([participant])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested participant' do
      get :show, params: { id: participant.id }
      expect(assigns(:participant)).to eq(participant)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new participant' do
      get :new
      expect(assigns(:participant)).to be_a_new(Participant)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) { { name: 'Jane Smith', age: 25 } }

      it 'creates a new participant and redirects' do
        expect do
          post :create, params: { participant: valid_params }
        end.to change(Participant, :count).by(1)
        expect(response).to redirect_to(admin_participants_path)
        expect(flash[:notice]).to eq('Participant created successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { name: '', age: -5 } }

      it 'does not create a participant and re-renders new' do
        expect do
          post :create, params: { participant: invalid_params }
        end.not_to change(Participant, :count)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested participant' do
      get :edit, params: { id: participant.id }
      expect(assigns(:participant)).to eq(participant)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:valid_params) { { name: 'Updated John Doe', age: 35 } }

      it 'updates the participant and redirects' do
        patch :update, params: { id: participant.id, participant: valid_params }
        participant.reload
        expect(participant.name).to eq('Updated John Doe')
        expect(participant.age).to eq(35)
        expect(response).to redirect_to(admin_participants_path)
        expect(flash[:notice]).to eq('Participant updated successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { name: '', age: -5 } }

      it 'does not update the participant and re-renders edit' do
        patch :update, params: { id: participant.id, participant: invalid_params }
        participant.reload
        expect(participant.name).not_to eq('')
        expect(participant.age).not_to eq(-5)
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the participant and redirects' do
      participant
      expect do
        delete :destroy, params: { id: participant.id }
      end.to change(Participant, :count).by(-1)
      expect(response).to redirect_to(admin_participants_path)
      expect(flash[:notice]).to eq('Participant deleted successfully.')
    end
  end
end
