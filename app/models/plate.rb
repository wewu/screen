class Plate < ActiveRecord::Base
  set_table_name "plate"
  set_primary_key "plate_id" 
  belongs_to  :biodatabase,
              :class_name => "Biodatabase",
              :foreign_key => "biodatabase_id"
  has_many    :element, 
              :class_name => "Element"
  has_many    :assay,
              :class_name => "Assay",
              :foreign_key => "plate_id"
end
