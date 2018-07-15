class NotesController < ApplicationController
  before_action :load_noteable

  def new
    @note = Note.new
  end

  def index
    @notes = @noteable.notes
  end

  def create
    @note = @noteable.notes.new(note_params)
    @new_note = Note.new

    if @note.save
      flash[:notice] = "Note was successfully saved."
      #redirect_to @noteable
    else
      flash[:alert] = "There was an error saving Note."
      #render :new
    end

    respond_to do |format|
      format.html
      format.js
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

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def note_params
    params.require(:note).permit!
  end

  def load_noteable
    resource, id = request.path.split('/')[1, 2]
    @noteable = resource.singularize.classify.constantize.find(id)
  end
end
