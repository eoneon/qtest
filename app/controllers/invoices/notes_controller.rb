class Invoices::NotesController < NotesController
  before_action :set_notetable

  private

  def set_notetable
    @notetable = Invoice.find(params[:invoice_id])
    @view = @notetable
  end
end
