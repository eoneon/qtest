class CategoriesController < ApplicationController
  def index
    @categories = Category.order(:kind)
  end

  def show
    @category = Category.find(params[:id])
  end

  def new
    @category = Category.new
  end

  def edit
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      flash[:notice] = "Category was saved successfully."
      redirect_to @category
    else
      flash.now[:alert] = "Error creating Category. Please try again."
      render :edit
    end
  end

  def update
    @category = Category.find(params[:id])
    @category.assign_attributes(category_params)

    if @category.save
      flash[:notice] = "category was updated successfully."
    else
      flash.now[:alert] = "Error updated category. Please try again."
    end
    redirect_to edit_category_path #category
  end

  def import
    Category.import(params[:file])
    redirect_to categories_path, notice: 'Category imported.'
  end

  def destroy
    @category = Category.find(params[:id])

    if @category.destroy
      flash[:notice] = "\"#{@category.name}\" was deleted successfully"
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the category."
      render :show
    end
  end

  private

  def category_params
    params.require(:category).permit!
  end
end
