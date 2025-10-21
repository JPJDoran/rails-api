class FlushApiLogsJob < ApplicationJob
  queue_as :default

  # Retry automatically on StandardError up to 5 times, with 10-second intervals
  retry_on StandardError, wait: 10.seconds, attempts: 5

  BATCH_SIZE = 1000 # Chunk size for batch inserts to keep things manageable
  BUFFER_MINUTES = 1 # Do not flush the current minute to avoid racing
  LOCK_EXPIRY = 60 # Lock expiration time in seconds (prevents deadlocks)

  def perform  
    # The latest time to use for flushing
    cutoff_time = (Time.now - BUFFER_MINUTES.minutes).strftime('%Y%m%d%H%M')

    # Fetch all Redis keys for API usage logs
    keys = REDIS.keys("api_usage:*").sort

    keys.each do |key|
      # Skip any keys after the cutoff time
      next if key.split(":").last > cutoff_time

      lock_key = "lock:#{key}"

      # Try to acquire lock with 60-second expiry (NX = set if not exists)
      # Helps prevent duplication of inserts in concurrent environments
      locked = REDIS.set(lock_key, 1, nx: true, ex: LOCK_EXPIRY)

      # Skip this key if another worker holds the lock
      next unless locked

      begin
        # Chunked list of entries
        entries = REDIS.lrange(key, 0, BATCH_SIZE - 1)

        # If its empty we've processed them all, so exit
        next if entries.empty?

        # Format logs for insert
        rows = entries.map do |entry_json|
          entry = JSON.parse(entry_json)
          {
            api_key: entry["api_key"],
            path: entry["path"],
            method: entry["method"],
            ip: entry["ip"],
            timestamp: entry["timestamp"],
            created_at: Time.now,
            updated_at: Time.now
          }
        end

        # Insert batch into DB inside a transaction for safety
        LogApiRequest.transaction do
          LogApiRequest.insert_all(rows)
        end

        # Trim only the entries we processed
        REDIS.ltrim(key, entries.size, -1)
      rescue => e
        Rails.logger.error("Failed to flush logs for #{key}: #{e.message}")
        # Re-raise to retry with Sidekiq
        raise e
      ensure
        # Always release redis lock
        REDIS.del(lock_key)
      end
    end
  end
end