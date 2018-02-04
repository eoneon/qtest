class CreateDimTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :dim_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
