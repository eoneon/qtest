class DisclaimerTypesController < ApplicationController
  def index
    @disclaimer_types = DisclaimerType.all
  end

  def show
    @disclaimer_type = DisclaimerType.find(params[:id])
  end

  def new
    @disclaimer_type = DisclaimerType.new(category_id: params[:category_id])
  end

  def edit
    @disclaimer_type = DisclaimerType.find(params[:id])
  end

  def create
    @disclaimer_type = DisclaimerType.new(disclaimer_type_params)

    if @disclaimer_type.save
      flash[:notice] = "DisclaimerType was saved successfully."
      redirect_to @disclaimer_type
    else
      flash.now[:alert] = "Error creating DisclaimerType. Please try again."
      render :edit
    end
  end

  def update
    @disclaimer_type = DisclaimerType.find(params[:id])
    @disclaimer_type.assign_attributes(disclaimer_type_params)

    if @disclaimer_type.save
      flash[:notice] = "disclaimer_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated disclaimer_type. Please try again."
      render :edit
    end
  end

  def destroy
    @disclaimer_type = DisclaimerType.find(params[:id])

    if @disclaimer_type.destroy
      flash[:notice] = "\"#{@disclaimer_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the disclaimer_type."
      render :show
    end
  end

  private

  def disclaimer_type_params
    params.require(:disclaimer_type).permit!
  end
end
