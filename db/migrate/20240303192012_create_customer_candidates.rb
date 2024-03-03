class CreateCustomerCandidates < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_candidates do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
