class CreateFlags < ActiveRecord::Migration[5.1]
  def change
    create_table :flags do |t|
      t.integer :flag
      
      t.timestamps
    end
  end
end
