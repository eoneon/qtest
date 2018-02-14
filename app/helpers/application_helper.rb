module ApplicationHelper
  def link_to_add_fields(name, f, association, parent)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("#{parent}/" + association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def relation_to_class(relation)
    relation.klass.to_s.underscore.to_sym
  end

  def class_to_string(class_name)
    class_name.class.to_s.underscore
  end

  def obj_to_s(type)
    type.to_s.underscore
  end

  def obj_to_fk(type)
    type.to_s.underscore + "_id"
  end

  def value_list(parent, type)
    type.all
  end

  def type_list(parent)
    case
    when parent.item_type.art_type == "limited" then [EditionType]
    when parent.item_type.art_type == "original" then []
    end
  end
end
