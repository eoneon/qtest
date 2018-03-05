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
    [MountType, ItemType, SignType, CertType]
  end

  #scopes
  def value_list(type)
    case
    when @item.mount_type && type == ItemType then filter_item_types(type)
    when @item.mount_type && type == DimType then filter_dim_types(type)
    #when @item.edition_type && type == EditionType then filter_edition_types(type)
    else type.all
    end
  end

  #scope
  def filter_item_types(type)
    if @item.mount_type
      type.public_send(@item.mount_type.item_filter + "_items")
    else
      type.all
    end
  end

  #scope
  def filter_dim_types(type)
    if @item.mount_type
      type.public_send(@item.mount_type.dim_filter + "_dims")
    else
      type.all
    end
  end

  #not a scope
  # def filter_edition_types(type)
  #   if @item.filter_edition_types
  #     type.public_send(@item.edition_type.edtion_filter + "_editions")
  #   else
  #     type.all
  #   end
  # end


  def properties_list(parent)
    parent.item_type && parent.item_type.art_type == "limited" ? [EditionType, DimType] : [DimType]
  end
end
