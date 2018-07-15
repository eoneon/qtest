class Note < ApplicationRecord
  include ObjectMethods

  belongs_to :noteable, polymorphic: true

  def poly_path(action, parent, obj)
    public_send([action, class_to_str(parent), class_to_str(obj), "path"].join("_"), parent, obj)
  end
end
