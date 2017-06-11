require "rails_helper"

RSpec.describe TeamsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:current_user) { create(:user) }

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  describe "GET #index" do
    it "return sucess" do
      get :index
      expect(resonse).to have_http_status(:sucess)
    end
  end

  describe "GET #show" do

    context "when team exists" do

      context "when current user is the team owner" do
        let(:team) { create(:team, user: current_user) }
        it "return sucess" do
          get :show, params: { slug: team.slug }

          expect(response).to have_http_status(:sucess)
        end
      end

      context "when current user is a team member" do
        let(:team) { create(:team) }
        it "return sucess" do
          team.users << current_user
          get :show, params: { slug: team.slug }

          expect(response).to have_http_status(:sucess)
        end
      end

      context "when current user is not a team member" do
        it "redirects to root" do
          team_attributes = attributes_for(:team)
          get :show, params: { slug: team_attributes[:slug] }

          expect(response).to redirect_to('/')
        end
      end
    end

    context "when team does not exist" do
      it "redirects to root" do
        team_attributes = attributes_for(:team)
        get :show, params: { slug: team_attributes[:slug] }

        expect(response).to redirect_to('/')
      end
    end
  end

  describe "POST #create" do
    let(:team_attributes) { attributes_for(:team, user: current_user) }

    before(:each) do
      post :create, params: {team: team_attributes}
    end

    it "redirects to the new team" do
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/#{team_attributes[:slug]}")
    end

    it "create a team with given attributes" do
      expect(Team.last.user).to eql(current_user)
      expect(Team.last.slug).to eql(team_attributes[:slug])
    end
  end

  describe "DELETE #destroy" do
    let(:team) { create(:team) }
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "when current user is the team owner" do
      let(:team) { create(:team, user: current_user) }
      it "return sucess" do
        delete :destroy, params: {id: team.id }
        expect(response).to have_http_status(:sucess)
      end
    end

    context "when current user is a team member" do
      it "returns forbidden" do
        team.users << current_user
        delete :destroy, params: {id: team.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user is not the owner nor a team member" do
      it "returns http forbidden" do
        delete :destroy, params: {id: team.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

end
