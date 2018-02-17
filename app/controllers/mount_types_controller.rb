class MountTypesController < ApplicationController
  def index
    @mount_types = MountType.all
  end

  def show
    @mount_type = MountType.find(params[:id])
  end

  def new
    @mount_type = MountType.new(category_id: params[:category_id])
  end

  def edit
    @mount_type = MountType.find(params[:id])
  end

  def create
    @mount_type = MountType.new(mount_type_params)

    if @mount_type.save
      flash[:notice] = "MountType was saved successfully."
      redirect_to @mount_type
    else
      flash.now[:alert] = "Error creating MountType. Please try again."
      render :edit
    end
  end

  def update
    @mount_type = MountType.find(params[:id])
    @mount_type.assign_attributes(mount_type_params)

    if @mount_type.save
      flash[:notice] = "mount_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated mount_type. Please try again."
      render :edit
    end
  end

  def destroy
    @mount_type = MountType.find(params[:id])

    if @mount_type.destroy
      flash[:notice] = "\"#{@mount_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the mount_type."
      render :show
    end
  end

  private

  def mount_type_params
    params.require(:mount_type).permit!
  end
end
