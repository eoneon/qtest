require 'active_support/concern'

module Sign
  extend ActiveSupport::Concern

  def format_legacy_series(v)
    "This piece is " + v + " and comes from the Andy Warhol Legacy Series"
  end

  def build_sign(h, typ, ver)
    h[:v] = ver == "body" && artist_id == 7707 ? format_legacy_series(h[:v]) : h[:v]
  end
end
