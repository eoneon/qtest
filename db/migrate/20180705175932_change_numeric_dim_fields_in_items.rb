class ChangeNumericDimFieldsInItems < ActiveRecord::Migration[5.1]
  def change
    def up
      change_table :items do |t|
        t.change :frame_width, :string
        t.change :frame_height, :string
      end
    end

    def down
      change_table :items do |t|
        t.change :frame_width, :integer
        t.change :frame_height, :integer
      end
    end
  end
end
