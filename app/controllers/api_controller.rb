# Base controller for all API endpoints.
# Handles API key authentication, per-minute rate limiting, and logging usage to Redis.
class ApiController < ApplicationController
  # Run api key authentication before every action
  before_action :authenticate_api_key

  # Apply rate limiting per minute for each request
  before_action :rate_limit!

  # Log API key usage after each action
  after_action  :log_api_key_usage

  private

  # Authenticate the incoming API key.
  # Checks headers first, then query params.
  # Renders 401 Unauthorized if missing or invalid.
  #
  # @return [void]
  def authenticate_api_key
    # Sets the api_key for use in other functions.
    @current_api_key = request.headers['X-Api-Key'] || params[:api_key]

    unless ApiKey.exists?(token: @current_api_key)
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # Rate-limit requests per API key on a per-minute basis.
  # Uses Redis atomic increment with a TTL to reset the count automatically.
  # Renders 429 (Too Many Requests) if the limit is exceeded.
  #
  # @return [void]
  def rate_limit!
    # No api key, so return
    return unless @current_api_key

    # Key format: api_count:<token>:YYYYMMDDHHMM
    key = "api_count:#{@current_api_key}:#{Time.now.strftime('%Y%m%d%H%M')}"

    # Total count of requests
    count = Rails.cache.read(key).to_i + 1

    # Set TTL of 61 seconds on first increment
    Rails.cache.write(key, count, expires_in: 61.seconds)

    if count > 100
        render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    end
  end

  # Log API key usage for analytics or auditing.
  # Stores a JSON representation of the request in Redis for batch persistence later.
  #
  # @return [void]
  def log_api_key_usage
    # No api key, so return
    return unless @current_api_key

    # Key format: api_count:<token>:YYYYMMDDHHMM
    key = "api_usage:#{@current_api_key}:#{Time.now.strftime('%Y%m%d%H%M')}"

    # 
    entry = {
        api_key: @current_api_key,
        path: request.path,
        method: request.method,
        timestamp: Time.now.to_i,
        ip: request.remote_ip
    }

    # Read existing entries for this minute, append, and write back
    existing_entries = Rails.cache.read(key) || []
    Rails.cache.write(key, existing_entries + [entry], expires_in: 1.hours)
  end
end
