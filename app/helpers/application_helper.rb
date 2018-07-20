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

  def type_list
    [ArtistType, MountType, ItemType, SignType, CertType]
  end

  def value_list(type)
    case
    when type == ItemType then ItemType.sorted_item_types
    when type == ArtistType then ArtistType.last_name
    else
      type.all
    end
  end

  def properties_list(parent)
    parent.item_type && parent.item_type.art_type == "limited" ? [EditionType, DimType, DisclaimerType] : [DimType, DisclaimerType]
  end
end
