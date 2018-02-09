class ItemTypesController < ApplicationController
  def index
    @item_types = ItemType.all
  end

  def show
    @item_type = ItemType.find(params[:id])
  end

  def new
    @item_type = ItemType.new(category_id: params[:category_id])
  end

  def edit
    @item_type = ItemType.find(params[:id])
  end

  def create
    @item_type = ItemType.new(item_type_params)

    if @item_type.save
      flash[:notice] = "ItemType was saved successfully."
      redirect_to @item_type
    else
      flash.now[:alert] = "Error creating ItemType. Please try again."
      render :edit
    end
  end

  def update
    @item_type = ItemType.find(params[:id])
    @item_type.assign_attributes(item_type_params)

    if @item_type.save
      flash[:notice] = "item_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated item_type. Please try again."
      render :edit
    end
  end

  def destroy
    @item_type = ItemType.find(params[:id])

    if @item_type.destroy
      flash[:notice] = "\"#{@item_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the item_type."
      render :show
    end
  end

  private

  def item_type_params
    params.require(:item_type).permit!
  end
end
