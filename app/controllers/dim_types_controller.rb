class DimTypesController < ApplicationController
  def index
    @dim_types = DimType.all
  end

  def show
    @dim_type = DimType.find(params[:id])
  end

  def new
    @dim_type = DimType.new(category_id: params[:category_id])
  end

  def edit
    @dim_type = DimType.find(params[:id])
  end

  def create
    @dim_type = DimType.new(dim_type_params)

    if @dim_type.save
      flash[:notice] = "DimType was saved successfully."
      redirect_to @dim_type
    else
      flash.now[:alert] = "Error creating DimType. Please try again."
      render :edit
    end
  end

  def update
    @dim_type = DimType.find(params[:id])
    @dim_type.assign_attributes(dim_type_params)

    if @dim_type.save
      flash[:notice] = "dim_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated dim_type. Please try again."
      render :edit
    end
  end

  def destroy
    @dim_type = DimType.find(params[:id])

    if @dim_type.destroy
      flash[:notice] = "\"#{@dim_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the dim_type."
      render :show
    end
  end

  private

  def dim_type_params
    params.require(:dim_type).permit!
  end
end
