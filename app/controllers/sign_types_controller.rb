class SignTypesController < ApplicationController
  def index
    @sign_types = SignType.all
  end

  def show
    @sign_type = SignType.find(params[:id])
  end

  def new
    @sign_type = SignType.new(category_id: params[:category_id])
  end

  def edit
    @sign_type = SignType.find(params[:id])
  end

  def create
    @sign_type = SignType.new(sign_type_params)

    if @sign_type.save
      flash[:notice] = "SignType was saved successfully."
      redirect_to @sign_type
    else
      flash.now[:alert] = "Error creating SignType. Please try again."
      render :edit
    end
  end

  def update
    @sign_type = SignType.find(params[:id])
    @sign_type.assign_attributes(sign_type_params)

    if @sign_type.save
      flash[:notice] = "sign_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated sign_type. Please try again."
      render :edit
    end
  end

  def destroy
    @sign_type = SignType.find(params[:id])

    if @sign_type.destroy
      flash[:notice] = "\"#{@sign_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the sign_type."
      render :show
    end
  end

  private

  def sign_type_params
    params.require(:sign_type).permit!
  end
end
