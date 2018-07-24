require 'active_support/concern'

module Proom
  extend ActiveSupport::Concern

  def abbrv_description(build, i)
    sub_list.each do |sub_arr|
      return build.squish if build.squish.size <= i
      build = build.gsub(sub_arr[0], sub_arr[-1]).squish
    end
    build
  end

  def sub_list
    [
      [" List", ""], ["Limited Edition", "Ltd Ed "],
      ["Certificate of Authenticity", "Certificate"], ["Certificate", "Cert"],
      ["Letter of Authenticity", "LOA"],
      [" with ", " w/"], [" and ", " & "], [" Numbered ", " No. "],
      ["Hand Embellished", "Embellished"], ["Artist Embellished", "Embellished"],
      ["Gold Leaf", "GoldLeaf"], ["Silver Leaf", "SilverLeaf"],
      ["Hand Drawn Remarque", "Remarque"]
    ]
  end
end
