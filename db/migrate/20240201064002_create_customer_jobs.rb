# frozen_string_literal: true

class CreateCustomerJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_jobs do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.string :status, null: false
      t.integer :spots
      t.datetime :shift_starts_on, index: true
      t.datetime :shift_ends_on, index: true
      t.decimal :wage_per_hour, precision: 8, scale: 2
      t.jsonb :work_location
      t.jsonb :vacancy
      t.jsonb :applications, default: []
      t.timestamps

      t.index [:uuid, :shift_starts_on, :status]
    end
  end
end
