class FlagsController < ApplicationController
  def index
    @flags = Flag.all
  end

  def show
    @flag = Flag.find(params[:id])
  end

  def new
    @flag = Flag.new
  end

  def create
    @flag = Flag.new(flag_params)

    if @flag.save
      flash[:notice] = "Flag was saved successfully."
      render :edit
    else
      flash.now[:alert] = "Error creating Flag. Please try again."
      render :new
    end
  end

  def update
    @flag = Flag.find(params[:id])
    @flag.assign_attributes(flag_params)

    if @flag.save
      flash[:notice] = "Flag was saved successfully."
    else
      flash.now[:alert] = "Error creating Flag. Please try again."
    end
    render :edit
  end

  def destroy
    @flag = Flag.find(params[:id])

    if @flag.destroy
      flash[:notice] = "\"#{@flag.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the flag."
      render :show
    end
  end

  private

  def flag_params
    params.require(:flag).permit!
  end
end
