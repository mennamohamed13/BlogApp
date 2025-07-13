require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let!(:user) { User.create(name: "Poster", email: "poster@example.com", password: "password") }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "POST /posts" do
    it "creates a post with valid params" do
      post "/posts", params: { title: "My Post", body: "Content", tags: "test" }, headers: headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['title']).to eq("My Post")
    end

    it "returns error with missing fields" do
      post "/posts", params: { title: "" }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns unauthorized without token" do
      post "/posts", params: { title: "No Token", body: "Body", tags: "tag" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /posts" do
    it "returns posts" do
      Post.create(title: "Sample", body: "Body", tags: "tag", author: user)

      get "/posts", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
    end
  end

  describe "PUT /posts/:id" do
    let!(:post_record) { Post.create(title: "Old", body: "Body", tags: "tag", author: user) }

    it "updates the post" do
      put "/posts/#{post_record.id}", params: { title: "Updated" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['title']).to eq("Updated")
    end

    it "returns error when updating with invalid data" do
      put "/posts/#{post_record.id}", params: { title: "" }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns error when updating another user's post" do
      other_user = User.create(name: "Other", email: "other@example.com", password: "password")
      other_post = Post.create(title: "Other Post", body: "Other Body", tags: "tag", author: other_user)

      put "/posts/#{other_post.id}", params: { title: "Hacked" }, headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /posts/:id" do
    let!(:post_record) { Post.create(title: "To delete", body: "Body", tags: "tag", author: user) }

    it "deletes the post" do
      delete "/posts/#{post_record.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it "returns not found when deleting non-existent post" do
      delete "/posts/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
