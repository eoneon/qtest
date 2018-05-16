class ArtistTypesController < ApplicationController
  def index
    @artist_types = ArtistType.all
  end

  def show
    @artist_type = ArtistType.find(params[:id])
  end

  def new
    @artist_type = ArtistType.new(category_id: params[:category_id])
  end

  def edit
    @artist_type = ArtistType.find(params[:id])
  end

  def create
    @artist_type = ArtistType.new(artist_type_params)

    if @artist_type.save
      flash[:notice] = "ArtistType was saved successfully."
      redirect_to @artist_type
    else
      flash.now[:alert] = "Error creating ArtistType. Please try again."
      render :edit
    end
  end

  def update
    @artist_type = ArtistType.find(params[:id])
    @artist_type.assign_attributes(artist_type_params)

    if @artist_type.save
      flash[:notice] = "artist_type was updated successfully."
      render :edit
    else
      flash.now[:alert] = "Error updated artist_type. Please try again."
      render :edit
    end
  end

  def destroy
    @artist_type = ArtistType.find(params[:id])

    if @artist_type.destroy
      flash[:notice] = "\"#{@artist_type.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the artist_type."
      render :show
    end
  end

  private

  def artist_type_params
    params.require(:artist_type).permit!
  end
end
