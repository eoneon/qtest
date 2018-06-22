class AddDisclaimertypeRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :disclaimer_type, index: true
  end
end
