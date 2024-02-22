class CreateAnimals < ActiveRecord::Migration[7.1]
  def change
    create_table :animals do |t|
      t.string :uuid
      t.string :registered_by
      t.timestamps
    end
  end
end
