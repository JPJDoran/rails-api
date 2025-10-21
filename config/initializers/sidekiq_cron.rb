require 'sidekiq/cron/job'

schedule = {
  'flush_api_logs_every_5_minutes' => {
    'class' => 'FlushApiLogsJob',
    'cron'  => '*/5 * * * *', # every 5 minutes
    'queue' => 'default'
  }
}

Sidekiq::Cron::Job.load_from_hash(schedule)