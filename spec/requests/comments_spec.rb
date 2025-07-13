require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let!(:user) { User.create(name: "Commenter", email: "commenter@example.com", password: "password") }
  let!(:post_record) { Post.create(title: "Post", body: "Body", tags: "tag", author: user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "POST /posts/:post_id/comments" do
    it "creates a comment" do
      post "/posts/#{post_record.id}/comments", params: { body: "Nice post" }, headers: headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['body']).to eq("Nice post")
    end

    it "returns unauthorized without token" do
      post "/posts/#{post_record.id}/comments", params: { body: "No token" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /posts/:post_id/comments/:id" do
    let!(:comment) { Comment.create(body: "Original", post: post_record, user: user) }

    it "updates the comment" do
      put "/posts/#{post_record.id}/comments/#{comment.id}", params: { body: "Updated" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['body']).to eq("Updated")
    end

    it "returns error when updating another user's comment" do
      other_user = User.create(name: "Other", email: "other@example.com", password: "password")
      other_comment = Comment.create(body: "Other comment", post: post_record, user: other_user)
      other_token = JsonWebToken.encode(user_id: other_user.id)
      other_headers = { "Authorization" => "Bearer #{other_token}" }

      put "/posts/#{post_record.id}/comments/#{comment.id}", params: { body: "Hacked" }, headers: other_headers
      expect(response).to have_http_status(:forbidden).or have_http_status(:unauthorized)
    end
  end

  describe "DELETE /posts/:post_id/comments/:id" do
    let!(:comment) { Comment.create(body: "Will delete", post: post_record, user: user) }

    it "deletes the comment" do
      delete "/posts/#{post_record.id}/comments/#{comment.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it "returns not found when deleting non-existent comment" do
      delete "/posts/#{post_record.id}/comments/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
