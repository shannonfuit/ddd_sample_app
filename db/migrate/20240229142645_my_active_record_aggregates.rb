# frozen_string_literal: true

class MyActiveRecordAggregates < ActiveRecord::Migration[7.1]
  def change
    create_table :my_active_record_aggregates do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.integer :amount_of_items
      t.timestamps
    end
  end
end
