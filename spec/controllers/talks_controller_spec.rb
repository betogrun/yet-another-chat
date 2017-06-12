require 'rails_helper'

RSpec.describe TalksController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:current_user) { create(:user) }

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  describe "GET #show" do
    render_views

    let(:team) { create(:team) { |team| team.users << guest_user} }
    let(:guest_user) { create(:user) }

    context "when current user is a talk member" do

      let(:message1) { build(:message) }
      let(:message2) { build(:message) }

      let!(:talk) do
        create(:talk, user_one: current_user, user_two: guest_user, team: team) do |talk|
          talk.messages << [message1, message2]
        end
      end

      before(:each) do
        get :show, params: {id: guest_user, team_id: team.id}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the expected params" do
        response_hash = JSON.parse(response.body)

        expect(response_hash["user_one_id"]).to eql(current_user.id)
        expect(response_hash["user_two_id"]).to eql(guest_user.id)
        expect(response_hash["team_id"]).to eql(team.id)
      end

      it "returns the expected amount of messages" do
        response_hash = JSON.parse(response.body)
        expect(response_hash["messages"].count).to eql(2)
      end

      it "returns the right messages" do
        response_hash = JSON.parse(response.body)
        expect(response_hash["messages"][0]["body"]).to eql(message1.body)
        expect(response_hash["messages"][0]["user_id"]).to eql(message1.user.id)
        expect(response_hash["messages"][1]["body"]).to eql(message2.body)
        expect(response_hash["messages"][1]["user_id"]).to eql(message2.user.id)
      end
    end

    context "when current user isn't a talk member" do
      let!(:talk) { create(:talk, user_two: guest_user, team: team) }

      it "returns http forbidden" do
        get :show, params: {id: guest_user, team_id: team.id }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

end
