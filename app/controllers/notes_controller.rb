class NotesController < ApplicationController
  def new
    @note = Note.new
  end

  def create
    @note = @noteable.notes.build(note_params)

    if @note.save
      flash[:notice] = "Address was successfully saved."
      redirect_to @noteable
    else
      flash[:alert] = "There was an error saving address."
      render :new
    end
  end

  def update
    @note = Note.find(params[:id])
    @note.assign_attributes(note_params)

    if @note.save
      flash[:notice] = "Address was successfully saved."
      redirect_to @noteable
    else
      flash[:alert] = "There was an error saving address."
      render :edit
    end
  end

  def destroy
    @note = @noteable.notes.find(params[:id])
    if @note.destroy
      flash[:notice] = "Note was deleted successfully."
    else
      flash[:alert] = "Note couldn't be deleted. Try again."
    end
  end

  private

  def note_params
    params.require(:note).permit!
  end
end
