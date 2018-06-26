class InvoicesController < ApplicationController
  def index
    @invoices = Invoice.all.order(invoice: 'desc')
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      flash[:notice] = "Invoice was saved successfully."
      redirect_to @invoice
    else
      flash.now[:alert] = "Error creating invoice. Please try again."
      render :new
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.assign_attributes(invoice_params)

    if @invoice.save
      flash[:notice] = "Invoice was updated successfully."
      redirect_to @invoice
    else
      flash.now[:alert] = "Error updated invoice. Please try again."
      render :edit
    end
  end

  def destroy
    @invoice = Invoice.find(params[:id])

    if @invoice.destroy
      flash[:notice] = "\"#{@invoice.invoice}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the invoice."
      render :show
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit!
  end
end
