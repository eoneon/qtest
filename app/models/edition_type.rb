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
    when category_names.count == 3 then "numbered out of"
    when category_names.count == 2 then "numbered qty"
    when category_names == ["edition"] then "from an edition"
    when category_names == ["unnumbered"] then "not numbered"
    end
  end

  def rule_names
    dropdown.gsub(/ /, "_")
  end

  def rule_set
    #refactor Hash rules
    [
      ["numbered",
        [[:insert_join, :d, [:idx_range_between_split, :d, h = {"edition" => ["properties", "number"]}], "/"] ] #rule
      ],
      ["from_an_edition",
        [[:insert_pat_at_idx, :d, [:idx_before_pat, :d, h = {"edition" => ["properties", "edition"]}], " from "]], #rule[0]
        [[:insert_pat_at_idx, :d, [:idx_before_pat, :d, h = {"edition" => ["properties", "edition"]}], [ :article, h = {"edition" => ["properties", "edition"]}]]], #rule[1]
        [[:insert_pat_at_idx, :d, [:idx_after_pat, :d, h = {"edition" => ["properties", "edition"]}], " edition "]] #rule[2]
      ],
      ["numbered_out_of",
        [[:insert_pat_at_idx, :d, [:idx_after_pat, :d, h = {"edition" => ["properties", "numbered"]}], " out of "]] #rule
      ]
    ]
  end
end
