require 'delayed_job'
require 'English'
require 'delayed_cron_job/cronline'
require 'delayed_cron_job/plugin'
require 'delayed_cron_job/version'
require 'delayed_cron_job/backend/updatable_cron'

begin
  require 'delayed_job_active_record'
rescue LoadError; end

begin
  require 'delayed_job_mongoid'
rescue LoadError; end

module DelayedCronJob
end

if defined?(Delayed::Backend::ActiveRecord)
  Delayed::Backend::ActiveRecord::Job.send(:include, DelayedCronJob::Backend::UpdatableCron)
end

Delayed::Worker.plugins << DelayedCronJob::Plugin

if defined?(::ActiveJob)
  require 'delayed_cron_job/active_job/enqueuing'
  require 'delayed_cron_job/active_job/queue_adapter'

  ActiveJob::Base.send(:include, DelayedCronJob::ActiveJob::Enqueuing)
  if ActiveJob::QueueAdapters::DelayedJobAdapter.respond_to?(:enqueue)
    ActiveJob::QueueAdapters::DelayedJobAdapter.extend(DelayedCronJob::ActiveJob::QueueAdapter)
  else
    ActiveJob::QueueAdapters::DelayedJobAdapter.send(:include, DelayedCronJob::ActiveJob::QueueAdapter)
  end

end