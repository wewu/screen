class Pathway < ActiveRecord::Base
  set_table_name "pathway"
  set_primary_key "pathway_id" 
  has_many    :assay,
              :class_name => "Assay",
              :foreign_key => "pathway_id"
end
