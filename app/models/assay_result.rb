class AssayResult < ActiveRecord::Base
  set_table_name "assay_result"

  belongs_to :assay, 
             :class_name => "Assay",
             :foreign_key => "assay_id"
  belongs_to :element,             
             :class_name => "Element",
             :foreign_key => "element_id"
  belongs_to :element96,
             :class_name => "Element96",
             :foreign_key => "element96_id"
end
