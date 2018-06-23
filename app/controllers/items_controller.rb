class ItemsController < ApplicationController
  def index
    @items = Item.all
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    #@invoice = Invoice.find(params[:invoice_id])
    @item = Item.new(artist_type_id: params[:artist_type_id], mount_type_id: params[:mount_type_id], item_type_id: params[:item_type_id], edition_type_id: params[:edition_type_id], sign_type_id: params[:sign_type_id], cert_type_id: params[:cert_type_id], dim_type_id: params[:dim_type_id], disclaimer_type_id: params[:disclaimer_type_id])
  end

  def create
    #@invoice = Invoice.find(params[:invoice_id])
    #@item = @invoice.items.build(item_params)
    #@new_item = Item.new
    @item = Item.new(item_params)
    if @item.save
      flash[:notice] = "Item was saved successfully."
    else
      flash.now[:alert] = "Error creating item. Please try again."
      # render :edit
    end
    render :edit
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    @item.assign_attributes(item_params)

    if @item.save
      flash[:notice] = "Item was updated successfully."
    else
      flash.now[:alert] = "Error updated item. Please try again."
    end
    #redirect_to edit_invoice_item_path(@item.invoice, @item)
    render :edit
  end

  def destroy
    @item = Item.find(params[:id])

    if @item.destroy
      flash[:notice] = "Item was deleted successfully."
    else
      flash.now[:alert] = "There was an error deleting the item."
    end
    redirect_to action: :index
  end

  private

  def item_params
    params.require(:item).permit!
  end
end
