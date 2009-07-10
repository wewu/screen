class SqlAssayresultLib
@@alib = ApplicationLib.new
@@slib = SqlLib.new

## ================ Select =======================
def list(aid)
   tables = "assay_result, element"
   fields = "concat(row, col) as well, value, bad_or_ctrl_elem_desc as bc_elem_desc, bad_or_ctrl_elem as bc_elem"
   wstr = " assay_id = " + aid.to_s + " and assay_result.element_id = element.element_id"
   ostr = "row, col"
   
   ararr = @@slib.sql_get_arr(tables, fields, wstr, ostr)
   ararr
end

def list_element(aid)
   tables = "assay_result, element"
   fields = "assay_result_id, row, col"
   wstr = " assay_id = " + aid.to_s + " and assay_result.element_id = element.element_id"
   ostr = "row, col"
   
   ararr = @@slib.sql_get_arr(tables, fields, wstr, ostr)
   ararr
end

def list_value(aid)
   ararr = list(aid)
   len = ararr.length
   
   arvalarr = Array.new
   for i in (0..len-1)
      if (ararr[i].bc_elem.to_i > 0)
         arvalarr[i] = "NA"
      else
         arvalarr[i] = ararr[i].value
      end      
   end
   arvalarr
end

def list_ctrl(aid, type)
   if (type == 23)
      typestr = " (bad_or_ctrl_elem = 2 or bad_or_ctrl_elem = 3)"
   else
      typestr = " bad_or_ctrl_elem = " + type.to_s
   end
   
   tables = "assay_result, element"
   fields = "concat(row, col) as well, value"
   wstr = " assay_id = " + aid.to_s + " and assay_result.element_id = element.element_id and "
   wstr = wstr + typestr
   ostr = "row, col"

   arctrlarr = @@slib.sql_get_arr(tables, fields, wstr, ostr)
   arctrlarr
end

def list_ctrl_value(aid, type)
   ararr = list_ctrl(aid, type)
   len = ararr.length
   
   ctrlvalarr = Array.new
   for i in (0..len-1)
      ctrlvalarr[i] = ararr[i].value
   end
   ctrlvalarr
end

def list_posctrl_value(aid)
   ctrlvalarr = list_ctrl_value(aid, 2)
   ctrlvalarr
end

def list_negctrl_value(aid)
   ctrlvalarr = list_ctrl_value(aid, 3)
   ctrlvalarr
end

def list_ctrl_elem(aid, type)
   ararr = list_ctrl(aid, type)
   len = ararr.length
   
   ctrlelemarr = Array.new
   for i in (0..len-1)
      ctrlelemarr[i] = ararr[i].well
   end
   ctrlelemarr
end

def list_posctrl_elem(aid)
   ctrlelemarr = list_ctrl_elem(aid, 2)
   ctrlelemarr
end

def list_negctrl_elem(aid)
   ctrlelemarr = list_ctrl_elem(aid, 3)
   ctrlelemarr
end

def list_bad_elem(aid)
   badelemarr = list_ctrl_elem(aid, 1)
   badelemarr
end

## ===================== insert ================================
def insert(arid, aid, eid, val, sig, ftime, mtime, bcdesc, bc)
   an_assay_result = AssayResult.new({:assay_result_id => arid,
                                      :assay_id => aid,
                                      :element_id => eid,
                                      :value => val,
                                      :signal => sig,
                                      :flash_time => ftime,
                                      :measure_time => mtime,
                                      :bad_or_ctrl_elem_desc => bcdesc,
                                      :bad_or_ctrl_elem => bc })
   an_assay_result.save

   # s = "insert into assay_result values ("
   # s = s + arid.to_s + "," 
   # s = s + aid.to_s + "," 
   # s = s + eid.to_s + ","   
   # s = s + val.to_s + ","
   # s = s + "'" + sig.to_s + "',"
   # s = s + "'" + mtime.to_s + "',"
   # s = s + "'" + ftime.to_s + "',"
   # s = s + "'" + bcdesc.to_s + "',"
   # s = s + bc.to_s + ")" 
   # @@slib.exec(s)
end

## ===================== delete ================================
def delete(aid)
   AssayResult.delete_all("assay_id = " + aid.to_s)

   #s = "delete from assay_result where assay_id = " + aid.to_s
   #@@slib.exec(s)
end

## ===================== update ================================
def update_bc(aid, eid, bc_desc, bc)
   if (@@alib.is_nil(bc_desc))
      bc_desc = ""
   end
   
   s =  " bad_or_ctrl_elem_desc = '" + bc_desc + "',"
   s = s + " bad_or_ctrl_elem = " + bc.to_s 
   w = " assay_id = " + aid.to_s + " and element_id = " + eid.to_s
   AssayResult.update_all(s, w)
end

def update_element(plate_id, elemarr)
   len = elemarr.length
   for i in (0..len-1)
      w = "plate_id = " + plate_id.to_s 
      w = w + " and row = '" + elemarr[i].row + "'"
      w = w + " and col = " + elemarr[i].col.to_s
      new_elemid = @@slib.sql_get_1num("element", "element_id", w)
      
      s = "element_id = " + new_elemid.to_s
      w = "assay_result_id = " + elemarr[i].assay_result_id.to_s
      AssayResult.update_all(s, w)
   end
end

end