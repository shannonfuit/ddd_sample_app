class AddStateToIamUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :iam_users, :state, :string
    add_column :iam_users, :company_uuid, :string

    create_table :customer_companies do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.string :name

      t.timestamps
    end
  end
end
