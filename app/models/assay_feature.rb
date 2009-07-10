class AssayFeature < ActiveRecord::Base
  set_table_name "assay_feature"

  belongs_to :assay, 
             :class_name => "Assay",
             :foreign_key => "assay_id"
end
