class ItemsController < ApplicationController
  def index
    @items = Item.all.order(:sku)
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    @invoice = Invoice.find(params[:invoice_id])
    @item = Item.new(artist_type_id: params[:artist_type_id], mount_type_id: params[:mount_type_id], item_type_id: params[:item_type_id], edition_type_id: params[:edition_type_id], sign_type_id: params[:sign_type_id], cert_type_id: params[:cert_type_id], dim_type_id: params[:dim_type_id], disclaimer_type_id: params[:disclaimer_type_id])
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    @item = @invoice.items.build(item_params)

    if @item.save
      flash[:notice] = "Item was saved successfully."
      render :edit
    else
      flash.now[:alert] = "Error creating item. Please try again."
      render :new
    end
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

    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    @item = Item.find(params[:id])

    if @item.destroy
      flash[:notice] = "Item was deleted successfully."
      redirect_to @item.invoice
    else
      flash.now[:alert] = "There was an error deleting the item."
      render :show
    end
  end

  def create_skus
    @item = Item.find(params[:id])
    if sku_set
      build_skus
      #@first_item = Item.where(sku: build_skus.first)
      flash[:notice] = "Skus successfully created."
      render :edit
    else
      redirect_to @item
      flash[:alert] = "Invalid sku range."
    end
  end

  def export
    @items = Item.where(invoice_id: params[:invoice_id])
    @invoice = @items.first.invoice

    respond_to do |format|
      format.html
      format.csv { send_data @items.to_csv(['sku', 'artist', 'artist_id', 'title', 'retail', 'tagline', 'property_room', 'description', 'art_type', 'art_category', 'material', 'medium', 'width', 'height', 'frame_width', 'frame_height', 'depth', 'weight', 'framed', 'gallery_wrapped', 'stretched', 'embellished', 'disclaimer']), filename: "#{@invoice.invoice} #{@invoice.name}.csv" }
      format.xls { send_data @items.to_csv(['sku', 'artist', 'artistid', 'title', 'tagline', 'retail', 'property_room', 'description', 'width', 'height', 'frame_width', 'frame_height'], col_sep: "\t") }
    end
  end

  private

  def to_range(sku_value)
    sku_range = (sku_value[0..5].to_i..sku_value[6..-1].to_i)
    sku_range.map {|i| i}
  end

  def valid_range(sku_value)
    sku_value[0..5].to_i <= sku_value[6..-1].to_i
  end

  def validate_skus(sku_value)
    case
    when sku_value.length == 6 then sku_value.to_i
    when sku_value.length == 12 && valid_range(sku_value) then to_range(sku_value)
    end
  end

  def extract_digits(sku_value)
    sku_value.gsub(/\D/, "")
  end

  def sku_set
    sku_arr = []
    params[:skus].split(",").each do |sku_value|
      v = extract_digits(sku_value)
      if validate_skus(v).blank?
        return false
      else
        sku_arr << validate_skus(v)
      end
    end
    sku_arr.flatten.uniq.sort
  end

  def build_skus
    sku_set.each do |new_sku|
      new_item = @item.dup
      #new_item.update(sku: new_sku, title: "untitled", invoice_id: @item.invoice_id)
      new_item.update(sku: new_sku, invoice_id: @item.invoice_id)
    end

  end

  def item_params
    params.require(:item).permit!
  end
end
