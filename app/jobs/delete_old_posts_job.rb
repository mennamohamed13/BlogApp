class DeleteOldPostsJob < ApplicationJob
  queue_as :default

  def perform
    Post.where('created_at <= ?', 24.hours.ago).destroy_all
  end
end
