class CreateEditionTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :edition_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
