require 'rails_helper'

RSpec.describe TeamUsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:current_user) { create(:user) }
  let(:guest_user) { create(:user) }

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  describe "GET #crete" do
    context "when user is the team owner" do
      let(:team) { create(:team, user: current_user) }

      it "returns http success" do
        post :create, params: { team_user: { user_id: guest_user.id, team_id: team.id } }
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not the team owner" do
      let(:team) { create(:team) }

      it "returns http forbidden" do
        post :create, params: { team_user: { user_id: guest_user.id, team_id: team.id } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #destroy" do
    context "when user is the team owner" do
      let(:team) { create(:team, user: current_user) { |team| team.users << guest_user } }

      it "returns http success" do
        delete :destroy, params: { id: guest_user.id, team_id: team.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not the team owner" do
      let(:team) { create(:team) { |team| team.users << guest_user } }

      it "returns http forbidden" do
        delete :destroy, params: { id: guest_user.id, team_id: team.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

end
