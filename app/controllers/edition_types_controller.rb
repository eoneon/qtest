class EditionTypesController < ApplicationController
  def index
    @edition_types = EditionType.all
  end

  def show
    @edition_type = EditionType.find(params[:id])
  end

  def new
    @edition_type = EditionType.new(category_id: params[:category_id])
  end

  def edit
    @edition_type = EditionType.find(params[:id])
  end

  def create
    @edition_type = EditionType.new(edition_type_params)

    if @edition_type.save
      flash[:notice] = "EditionType was saved successfully."
      redirect_to @edition_type
    else
      flash.now[:alert] = "Error creating EditionType. Please try again."
      render :edit
    end
  end

  def update
    @edition_type = EditionType.find(params[:id])
    @edition_type.assign_attributes(edition_type_params)

    if @edition_type.save
      flash[:notice] = "edition_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated edition_type. Please try again."
      render :edit
    end
  end

  def destroy
    @edition_type = EditionType.find(params[:id])

    if @edition_type.destroy
      flash[:notice] = "\"#{@edition_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the edition_type."
      render :show
    end
  end

  private

  def edition_type_params
    params.require(:edition_type).permit!
  end
end
