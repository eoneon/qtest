class CreateDisclaimerTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :disclaimer_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
