class Items::NotesController < NotesController
  before_action :set_notetable

  private

  def set_notetable
    @notetable = Item.find(params[:item_id])
    @view = @notetable
  end
end
