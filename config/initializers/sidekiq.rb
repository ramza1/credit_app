require 'sidekiq'
Redis.new(db: 2)
Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'poploda', :url => 'redis://127.0.0.1:6379/2' }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'poploda', :url => 'redis://127.0.0.1:6379/2' }
end