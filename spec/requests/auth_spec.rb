require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /signup" do
    it "creates a user with valid params" do
      # post "/signup", params: { name: "Test", email: "test@example.com", password: "password" }
      post "/signup", params: { name: "Test", email: "unique_#{SecureRandom.hex(4)}@example.com", password: "password" }

      puts JSON.parse(response.body)['errors']
      expect(response).to have_http_status(:created)

      
    end

    it "returns error with missing params" do
      post "/signup", params: { name: "" }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns error when email already taken" do
      User.create(name: "Test", email: "test@example.com", password: "password")
      post "/signup", params: { name: "New", email: "test@example.com", password: "password" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /login" do
    let!(:user) { User.create(name: "Login", email: "login@example.com", password: "password") }

    it "logs in with correct credentials" do
      post "/login", params: { email: "login@example.com", password: "password" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key("token")
    end

    it "returns error with invalid credentials" do
      post "/login", params: { email: "login@example.com", password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns error with missing params" do
      post "/login", params: { email: "login@example.com" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
