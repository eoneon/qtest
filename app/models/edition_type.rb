class EditionType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  # def category_names
  #   category.name.split("_")
  # end

  def required_fields
    category_names.count == 1 ? category_names : category_names - ["edition"]
  end

  def context
    case
    when category.name == "edition_numbered_number_size" then ["numbered", "edition numbered number/size"]
    when category.name == "edition_numbered_size" then ["numbered out of", "edition numbered out of size"]
    when category.name == "edition_numbered" then ["numbered qty", "edition_numbered"]
    when category.name == "edition" then ["from an edition", "from an edition edition"]
    when category.name == "unnumbered" then ["not numbered", "This piece is not numbered."]
    end
  end

  def dropdown
    context[0]
  end

  def stub
    context[-1]
  end

  #kill
  def rule_names
    dropdown.gsub(/ /, "_")
  end

  #kill
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
