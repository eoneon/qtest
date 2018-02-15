class CertTypesController < ApplicationController
  def index
    @cert_types = CertType.all
  end

  def show
    @cert_type = CertType.find(params[:id])
  end

  def new
    @cert_type = CertType.new(category_id: params[:category_id])
  end

  def edit
    @cert_type = CertType.find(params[:id])
  end

  def create
    @cert_type = CertType.new(cert_type_params)

    if @cert_type.save
      flash[:notice] = "CertType was saved successfully."
      redirect_to @cert_type
    else
      flash.now[:alert] = "Error creating CertType. Please try again."
      render :edit
    end
  end

  def update
    @cert_type = CertType.find(params[:id])
    @cert_type.assign_attributes(cert_type_params)

    if @cert_type.save
      flash[:notice] = "cert_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated cert_type. Please try again."
      render :edit
    end
  end

  def destroy
    @cert_type = CertType.find(params[:id])

    if @cert_type.destroy
      flash[:notice] = "\"#{@cert_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the cert_type."
      render :show
    end
  end

  private

  def cert_type_params
    params.require(:cert_type).permit!
  end
end
