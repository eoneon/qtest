class EditionType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def required_fields
    category_names.count == 1 ? category_names : category_names - ["edition"]
  end

  def edition
    case category.name
    when "edition_numbered_number_size" then ["numbered", h = {v: "edition numbered number/size"}]
    when "edition_numbered_size" then ["numbered out of", h = {v: "edition numbered out of size"}]
    when "edition_numbered" then ["numbered qty", h = {v: "edition_numbered"}]
    when "edition" then ["from an edition", h = {pos: "after", pat: "from", v: "from edition edition"}]
    when "unnumbered" then ["not numbered", h = {v: "This piece is not numbered."}]
    end
  end

  def dropdown
    edition[0]
  end

  def typ_ver_args(ver)
    edition[-1] if edition
  end

  def stub
    edition[-1]
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
