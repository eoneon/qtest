require 'active_support/concern'

module ObjectMethods
  extend ActiveSupport::Concern

  #eg: "Hello" -> String -> "String" -> "string" *unused utility meth
  def class_to_str(obj)
    obj.class.to_s.downcase
  end

  #eg: "dim_type_id" -> :dim_type
  def fk_to_meth(fk)
    public_send(fk.remove("_id"))
  end

  #eg: "dim" -> :dim_type
  def type_to_meth(type)
    public_send(type + "_type")
  end

  #eg: "dim_type_id" -> "dim"
  def fk_to_type(fk)
    fk[-8..-1] == "_type_id" ? fk.remove("_type_id") : fk.remove("_id")
  end
end
