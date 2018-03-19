class EditionType < ApplicationRecord
  belongs_to :category
  has_many :items

  def category_names
    category.name.split("_")
  end

  def required_fields
    category_names.count == 1 ? category_names : category_names - ["edition"]
  end

  def dropdown
    case
    when category_names.count == 4 then "numbered"
    #when category_names.count == 3 then "numbered from edition size"
    when category_names.count == 3 then "numbered out of"
    when category_names.count == 2 then "numbered qty"
    when category_names == ["edition"] then "from an edition"
    when category_names == ["unnumbered"] then "not numbered"
    end
  end

  def edition_rules
    [
      ["numbered",
        [:split_pos, "number", "/"]
      ],
      ["from an edition",
        [:before_pos, h = {"edition" => ["properties", "edition"]}, "from "],
        [:before_pos, h = {"edition" => ["properties", "edition"]}, [ :article, h = {"edition" => ["properties", "edition"] }]]
        #[:after_pos, "edition"," edition"]
      ],
      ["numbered_out_of",
        [:after_pos, "number", " edition"]
      ]
    ]
  end
end
