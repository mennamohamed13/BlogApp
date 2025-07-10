require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:6379/0' }

  # Load cron jobs only on the server side
  Sidekiq::Cron::Job.load_from_hash({
    'delete_old_posts_job' => {
      'cron' => '0 * * * *', # every hour
      'class' => 'DeleteOldPostsJob'
    }
  })
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379/0' }
end
