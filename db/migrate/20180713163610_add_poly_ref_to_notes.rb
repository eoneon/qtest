class AddPolyRefToNotes < ActiveRecord::Migration[5.1]
  def change
    add_reference :notes, :noteable, polymorphic: true, index: true
  end
end
