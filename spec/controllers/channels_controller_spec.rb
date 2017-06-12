require 'rails_helper'

RSpec.describe ChannelsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:current_user) { create(:user) }

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  describe "POST #create" do
    render_views

    context "when current user is a team member" do
      let(:team) { create(:team) { |team| team.users << current_user } }
      let(:channel_attributes) { attributes_for(:channel, team: team, user: current_user)}

      before(:each) do
        post :create, params: {channel: channel_attributes.merge(team_id: team.id)}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "is created with expected params" do
        expect(Channel.last.slug).to eql(channel_attributes[:slug])
        expect(Channel.last.user).to eql(current_user)
        expect(Channel.last.team).to eql(team)
      end

      it "return right values to channel" do
        response_hash = JSON.parse(response.body)

        expect(response_hash["user_id"]).to eql(current_user.id)
        expect(response_hash["slug"]).to eql(channel_attributes[:slug])
        expect(response_hash["team_id"]).to eql(team.id)
      end
    end

    context "when current user is not a team member" do
      let(:team) { create(:team) }
      let(:channel_attributes) { attributes_for(:channel, team: team) }

      before(:each) do
        post :create, params: {channel: channel_attributes.merge(team_id: team.id) }
      end

      it "returns http forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

  describe "GET #show" do
    render_views

    context "when user is a team member" do
      let(:team) { create(:team, user: current_user) }
      let(:message1) { build(:message) }
      let(:message2) { build(:message) }
      let(:channel) do
         create(:channel, team: team) do |channel|
           channel.messages << [message1, message2]
         end
      end

      before(:each) do
        get :show, params: { id: channel.id }
      end

      it "returns http sucess" do
        expect(response).to have_http_status(:success)
      end

      it "returns the expected amount of messages" do
        response_hash = JSON.parse(response.body)
        expect(response_hash["messages"].count).to eql(2)
      end

      it "return the expected messages" do
        response_hash = JSON.parse(response.body)
        expect(response_hash["messages"][0]["body"]).to eql(message1.body)
        expect(response_hash["messages"][0]["user_id"]).to eql(message1.user.id)
        expect(response_hash["messages"][1]["body"]).to eql(message2.body)
        expect(response_hash["messages"][1]["user_id"]).to eql(message2.user.id)
      end
    end

    context "when user is not a team member" do
      let(:channel) { create(:channel) }

      it "returns http forbidden" do
        get :show, params: {id: channel.id}

        expect(response).to have_http_status(:forbidden)
      end
    end

  end

  describe "DELETE #destroy" do
    context "when user is a team member" do

      context "when user is the channel owner" do
        let(:team) { create(:team) { |team| team.users << current_user } }
        let(:channel) { create(:channel, team: team, user: current_user) }

        it "return http sucess" do
          delete :destroy, params: {id: channel.id }
          expect(response).to have_http_status(:success)
        end
      end

      context "when user is the team owner" do
        let(:channel_ower) { create(:user) }
        let(:team) do
          create(:team, user: current_user) do |team|
            team.users << channel_ower
          end
        end
        let(:channel) { create(:channel, team: team, user: channel_ower) }

        it "returns https sucess" do
          delete :destroy, params: {id: channel.id}
          expect(response).to have_http_status(:success)
        end
      end

      context "when user is not the owner of eihter the team or the channel" do
        let(:team) { create(:team) { |team| team.users << current_user } }
        let(:channel) { create(:channel, team: team) }

        it "returns http forbidden" do
          delete :destroy, params: {id: channel.id}
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "when user is not a team member" do
        let(:team) { create(:team) }
        let(:channel) { create(:channel, team: team) }

        it "returns http forbidden" do
          delete :destroy, params: {id: channel.id}
          expect(response).to have_http_status(:forbidden)
        end
      end


    end
  end


end
