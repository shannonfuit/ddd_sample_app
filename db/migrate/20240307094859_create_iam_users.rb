class CreateIamUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :iam_users do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.string :role
      t.string :email
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :job_fulfillment_users do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.string :role
      t.timestamps
    end
  end
end
