# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default, :test)
# require 'rails_autoscale_agent'
require_relative './support/env_helpers'
require_relative './support/config_helpers'

module Rails
  def self.logger
    @logger ||= ::Logger.new('log/test.log')
  end

  def self.version
    '5.0.fake'
  end
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  # https://github.com/collectiveidea/delayed_job_active_record/blob/master/lib/generators/delayed_job/templates/migration.rb#L3
  create_table :delayed_jobs do |table|
    table.integer :priority, default: 0, null: false # Allows some jobs to jump to the front of the queue
    table.integer :attempts, default: 0, null: false # Provides for retries, but still fail eventually.
    table.text :handler,                 null: false # YAML-encoded string of the object that will do work
    table.text :last_error                           # reason for last failure (See Note below)
    table.datetime :run_at                           # When to run. Could be Time.zone.now for immediately, or sometime in the future.
    table.datetime :locked_at                        # Set when a client is working on this object
    table.datetime :failed_at                        # Set when all retries have failed (actually, by default, the record is deleted instead)
    table.string :locked_by                          # Who is working on this object (if locked)
    table.string :queue                              # The name of the queue this job is in
    table.timestamps null: true
  end

  create_table "que_jobs" do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", null: false
    t.integer "error_count", default: 0, null: false
    t.text "queue", default: "default", null: false
    t.datetime "finished_at"
    t.datetime "expired_at"
  end
end

RSpec.configure do |c|
  c.before(:example) { Singleton.__init__(RailsAutoscaleAgent::Config) if Object.const_defined?('RailsAutoscaleAgent::Config') }
end
