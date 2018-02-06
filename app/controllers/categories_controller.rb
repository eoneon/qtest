class CategoriesController < ApplicationController
  def index
    @categories = category_type.all
  end

  def show
    @category = category_type.find(params[:id])
  end

  def new
    @category = category_type.new #(sub_category_ids: params[:sub_category_ids])
  end

  def edit
    @category = category_type.find(params[:id])
  end

  def create
    @category = category_type.new(category_params)

    if @category.save
      flash[:notice] = "category_type was saved successfully."
      redirect_to @category
    else
      flash.now[:alert] = "Error creating category_type. Please try again."
      render :edit
    end
  end

  def update
    @category = category_type.find(params[:id])
    @category.assign_attributes(category_params)

    if @category.save
      flash[:notice] = "category was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated category. Please try again."
      render :edit
    end
  end

  def import
    category_type.import(params[:file])
    redirect_to categorys_path, notice: 'category_type imported.'
  end

  def destroy
    @category = category_type.find(params[:id])

    if @category.destroy
      flash[:notice] = "\"#{@category.name}\" was deleted successfully"
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the category."
      render :show
    end
  end

  private

  def category_types
    ["Artkind", "Medium", "Substrate", "Remarque", "Embellish", "Exclusive", "Leafing"]
  end

  def category_type
    if params[:type].in? category_types
      params[:type].constantize
    elsif ["Category"]
      Category
    end
  end

  def category_params
    params.require(:category).permit!
  end
end
