class Biodatabase < ActiveRecord::Base
  set_table_name "biodatabase"
  set_primary_key "biodatabase_id" 
  
  has_many :bioentry, 
           :class_name => "Bioentry"
  has_many :plate,
           :class_name => "Plate"
end
