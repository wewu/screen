class Assay < ActiveRecord::Base
  set_table_name "assay"
    
  has_many    :assay_result, 
              :class_name => "AssayResult"
  belongs_to  :plate,
              :class_name => "Plate",
              :foreign_key => "plate_id"
  belongs_to  :software,
              :class_name => "Software",
              :foreign_key => "software_id"
end

