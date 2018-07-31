require 'active_support/concern'

module Punctuation
  extend ActiveSupport::Concern

  def cert_period(h, ver)
    ! [cert_type.body_credential_hsh[:p], cert_type.body_credential_hsh[:n]].include?(h[:v])
  end

  def sign_period(h, ver)
    ver != "body" && ver_types("tag").exclude?(fk_to_type("cert")) || ver == "body"
  end

  def edition_comma(h, ver)
    from_edition? && ver_types("tag").include?("sign")
  end

  def edition_period(h, ver)
    ver != "body" && ! intersection?(ver_types("tag"), "any?", ["sign", "cert"]) || ver == "body" && ! ver_types("tag").include?("sign")
  end

  def item_comma(h, ver)
    ! from_edition? && intersection?(ver_types("tag"), "any?", ["edition", "sign"])
  end

  def item_period(h, ver)
    ver != "body" && ! intersection?(ver_types("tag"), "any?", ["edition", "sign", "cert"]) || ver == "body" && ! intersection?(ver_types("tag"), "any?", ["edition", "sign"]) || ver == "body" && artist_id == 7707
  end

  def punct_type(h, typ, ver)
    if public_send(typ + "_period", h, ver)
      h[:v] << "."
    elsif respond_to?(typ + "_comma") && public_send(typ + "_comma", h, ver)
      h[:v] << ","
    end
  end
end
