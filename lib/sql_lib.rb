class SqlLib

@@alib = ApplicationLib.new


## ===================== select function ================================

def sql_get_arr(tables, fields, wclause, orderclause)
   str = " select " + fields + " from " + tables 
   if (wclause.length > 0)
      str = str + " where " + wclause
   end
   if (orderclause.length > 0)
      str = str + " order by " + orderclause
   end
   arr = run(str)
   arr
end

def sql_get_1field(tables, field, wclause)
   arr = sql_get_arr(tables, field + " as myfield ", wclause, "myfield")
end

def sql_get_1field_order(tables, field, wclause, order)
   arr = sql_get_arr(tables, field + " as myfield ", wclause, order)
end

def sql_get_1rec(tables, field, wclause)
   arr = sql_get_1field(tables, field, wclause)

   if (arr.length>0)
      retitem = arr[0].myfield
   else
      retitem = -1
   end
   retitem
end

def sql_get_1num(tables, field, wclause)
   retitem = sql_get_1rec(tables, field, wclause)
   retitem.to_i
end

def sql_get_1str(tables, field, wclause)
   retitem = sql_get_1rec(tables, field, wclause)
   retitem.to_s
end

def sql_get_nnum(tables, field, wclause)
   arr = sql_get_1field(tables, field, wclause)

   arrret = Array.new
   j = 0
   for a in arr
     arrret[j] = a.myfield.to_i
     j = j + 1
   end
   arrret
end

def sql_get_nnum_order(tables, field, wclause, ostr)
   arr = sql_get_1field_order(tables, field, wclause, ostr)

   arrret = Array.new
   j = 0
   for a in arr
     arrret[j] = a.myfield.to_i
     j = j + 1
   end
   arrret
end

def sql_get_nstr(tables, field, wclause)
   arr = sql_get_1field(tables, field, wclause)

   arrret = Array.new
   j = 0
   for a in arr
     arrret[j] = a.myfield.to_s
     j = j + 1
   end
   arrret
end

def sql_get_nstr_order(tables, field, wclause, ostr)
   arr = sql_get_1field_order(tables, field, wclause, ostr)

   arrret = Array.new
   j = 0

   for a in arr
     arrret[j] = a.myfield.to_s
     j = j + 1
   end
   arrret
end


## ===================== select for db and plate fields ================================
def sql_get_db_plate_name_arr
   fields = Array.new
   tables = "biodatabase, plate"
   fields[0] = "biodatabase.biodatabase_id as did"
   fields[1] = "biodatabase.name as dname"
   fields[2] = "plate_id as pid"
   fields[3] = "plate.name as pname "
   fstr = @@alib.comb_arr_to_str(",", fields)
   wstr = "biodatabase.biodatabase_id = plate.biodatabase_id"
   ostr = "plate.description, plate.name"

   platenamearr = sql_get_arr(tables, fstr, wstr, ostr)
   platenamearr
end    

def sql_get_pid_by_dname_and_pname(dname, pname)
   tables = "biodatabase, plate "
   wstr = "  biodatabase.biodatabase_id = plate.biodatabase_id"
   wstr = wstr + " and plate.name = '"+ pname + "'"
   wstr = wstr + " and biodatabase.name = '"+ dname + "'"
   pid = sql_get_1num(tables, "plate_id", wstr)
   pid
end

def sql_get_pnamearr_by_dname(dname)
   tables = "biodatabase, plate "
   wstr = "  biodatabase.biodatabase_id = plate.biodatabase_id"
   wstr = wstr + " and biodatabase.name = '"+ dname + "'"
   pnamearr = sql_get_nstr_order(tables, "plate.name", wstr, "plate.name")
   pnamearr
end

def sql_get_eid(pid, row, col)
   wstr = "plate_id = " + pid.to_s  
   wstr = wstr + " and col = " + col.to_s  
   wstr = wstr + " and row = '"  + row + "'"
   eid = sql_get_1num("element", "element_id", wstr)
   eid
end


## =====================  annotation function ================================
def sql_select_annotation(aid)
   sn = srand.to_s
   snum = sn[0,5]
       
   T0.delete_all() #"rand_num = " + snum.to_s)
   T1.delete_all() #"rand_num = " + snum.to_s)
   T2.delete_all() #"rand_num = " + snum.to_s)
   T3.delete_all() #"rand_num = " + snum.to_s)

   s =     " select assay_id, row, col, assay.plate_id, bioentry_id as be_id, sample_id "
   s = s + "   from assay, element "
   s = s + "  where assay.plate_id = element.plate_id"
   s = s + "    and assay.assay_id = " + aid.to_s
   arr0 = run(s)
   len0 = arr0.length
   for i in (0..len0-1)   
      an_t0 = T0.new({:rand_num => snum,
                      :assay_id => arr0[i].assay_id, 
                      :row      => arr0[i].row,
                      :col      => arr0[i].col,
                      :plate_id => arr0[i].plate_id,
                      :be_id    => arr0[i].be_id,
                      :sample_id=> arr0[i].sample_id})
      an_t0.save
   end
   
   s =     " select t0.*, biodatabase.name as db_name "
   s = s + "   from t0, plate, biodatabase"
   s = s + "  where t0.plate_id = plate.plate_id"
   s = s + "    and plate.biodatabase_id = biodatabase.biodatabase_id"
   s = s + "    and rand_num = " + snum.to_s
   arr1 = run(s)
   len1 = arr1.length
   for i in (0..len1-1)   
      an_t1 = T1.new({:rand_num => arr1[i].rand_num,
                      :assay_id => arr1[i].assay_id, 
                      :row      => arr1[i].row,
                      :col      => arr1[i].col,
                      :plate_id => arr1[i].plate_id,
                      :be_id    => arr1[i].be_id,
                      :sample_id=> arr1[i].sample_id,
                      :db_name  => arr1[i].db_name})
      an_t1.save
   end
   
   s =     " select t1.*, name as be_name, accession, identifier "
   s = s + "   from t1 left join bioentry"  
   s = s + "     on t1.be_id = bioentry.bioentry_id "
   s = s + "    and rand_num = " + snum.to_s
   arr2 = run(s)
   len2 = arr2.length
   for i in (0..len2-1)   
      an_t2 = T2.new({:rand_num => arr2[i].rand_num,
                      :assay_id => arr2[i].assay_id, 
                      :row      => arr2[i].row,
                      :col      => arr2[i].col,
                      :plate_id => arr2[i].plate_id,
                      :be_id    => arr2[i].be_id,
                      :sample_id=> arr2[i].sample_id,
                      :db_name  => arr2[i].db_name,
                      :be_name  => arr2[i].be_name,
                      :accession=> arr2[i].accession,
                      :identifier=>arr2[i].identifier
                      })
      an_t2.save
   end

   s =     " select t2.*, name as fea_name, value as fea_value "
   s = s + "   from t2 left join bioentry_feature "
   s = s + "     on be_id = bioentry_id" 
   s = s + "    and rand_num = " + snum.to_s
   arr3 = run(s)
   len3 = arr3.length
   for i in (0..len3-1)   
      an_t3 = T3.new({:rand_num => arr3[i].rand_num,
                      :assay_id => arr3[i].assay_id, 
                      :row      => arr3[i].row,
                      :col      => arr3[i].col,
                      :plate_id => arr3[i].plate_id,
                      :be_id    => arr3[i].be_id,
                      :sample_id=> arr3[i].sample_id,
                      :db_name  => arr3[i].db_name,
                      :be_name  => arr3[i].be_name,
                      :accession=> arr3[i].accession,
                      :identifier=>arr3[i].identifier,
                      :fea_name => arr3[i].fea_name,
                      :fea_value=> arr3[i].fea_value
                      })
      an_t3.save
   end

   s =     " select t3.*, seq as sequence "
   s = s + "   from t3 left join biosequence "
   s = s + "     on be_id = bioentry_id" 
   s = s + "    and rand_num = " + snum.to_s
   s = s + "  order by row, col, be_name "
   arr4 = run(s)

   T0.delete_all() #"rand_num = " + snum.to_s)
   T1.delete_all() #"rand_num = " + snum.to_s)
   T2.delete_all() #"rand_num = " + snum.to_s)
   T3.delete_all() #"rand_num = " + snum.to_s)
   arr4
end


## ===================== small sql function ================================

def run(str)
   arr = Assay.find_by_sql(str)
   #sql_msg(str)
   arr
end

def sql_msg(str)
   puts "\n" + str + "\n"
end


end
