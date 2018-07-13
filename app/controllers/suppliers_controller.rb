class SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.all.order(name: 'asc')
  end

  def show
    @supplier = Supplier.find(params[:id])
  end

  def new
    @supplier = Supplier.new
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      flash[:notice] = "Supplier was saved successfully."
      redirect_to @supplier
    else
      flash.now[:alert] = "Error creating Supplier. Please try again."
      render :edit
    end
  end

  def update
    @supplier = Supplier.find(params[:id])
    @supplier.assign_attributes(supplier_params)

    if @supplier.save
      flash[:notice] = "supplier was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated supplier. Please try again."
      render :edit
    end
  end

  def destroy
    @supplier = Supplier.find(params[:id])

    if @supplier.destroy
      flash[:notice] = "\"#{@supplier.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the supplier."
      render :show
    end
  end

  private

  def supplier_params
    params.require(:supplier).permit!
  end
end
