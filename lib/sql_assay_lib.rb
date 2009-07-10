class SqlAssayLib

@@alib = ApplicationLib.new
@@slib = SqlLib.new

#================ Insert=======================
def insert(aid, uname, pid, pwid, swid, aname, fname, log, adate, repli, adesc, prot, share)
   an_assay = Assay.new({:assay_id => aid, 
                         :user_id => uname, 
                         :plate_id => pid, 
                         :pathway_id => pwid, 
                         :software_id => swid, 
                         :name => aname, 
                         :filename => fname, 
                         :upload_log => log, 
                         :assay_date => adate, 
                         :assay_desc => adesc, 
                         :replicate => repli, 
                         :protocol => prot, 
                         :share => share})
   an_assay.save
end   

def insert_one_feature(afid, aid, name, val)
   an_feature = AssayFeature.new({:assay_feature_id => afid,
                                  :assay_id => aid,
                                  :name => name,
                                  :value => val})
   an_feature.save
end   

#================ delete =======================
def delete(aid)
   Assay.delete_all("assay_id = " + aid.to_s)
end   

def delete_feature(aid)
   AssayFeature.delete_all("assay_id = " + aid.to_s)
end   

#================ Update =======================
def update_field(aid, name, val)
   s =  name + "=" + val 
   w = "assay_id = " + aid.to_s
   Assay.update_all(s, w)
end

def update_log(aid, msg)
   update_field(aid, "upload_log", "'"+msg+"'")
end

def update_protocol(aid, protstr)
   update_field(aid, "protocol", "'"+protstr+"'")
end

def update_share(aid, share)
   update_field(aid, "share", share.to_s)
end

def update_plate(aid, plateid, replicate, pwid, adate, adesc, proto)
   s =     " plate_id = " + plateid.to_s + ","
   s = s + " pathway_id = " + pwid.to_s + ","
   s = s + " replicate = " + replicate.to_s + ","
   s = s + " assay_date = '" + adate  + "',"
   s = s + " assay_desc = '" + adesc  + "',"
   s = s + " protocol = '" + proto  + "'"
   w = "assay_id = " + aid.to_s
   Assay.update_all(s, w)
end



## =================== select base function ===================
def select(uid, aname, dbid, pid, pwid, desc, date, share)
   tstr = get_from_str()
   fstr = get_field_str()
   wstr = get_where_str()

   if (uid != "*")
      wstr = wstr + " and (user_id = '" + uid + "'"
      if (share == "1")
         wstr = wstr +  "or share=1)"
      else
         wstr = wstr + ")"
      end
   end
   
   if (aname != "*")
      wstr = wstr + " and assay.name = '" + aname + "'"
   end

   if (dbid != "*")
      wstr = wstr + " and biodatabase.biodatabase_id = " + dbid.to_s
   end

   if (pid != "*")
      wstr = wstr + " and plate.plate_id = " + pid.to_s
   end

   if (pwid != "*")
      wstr = wstr + " and pathway.pathway_id = " + pwid.to_s
   end
  
   if (desc != "*")
      wstr = wstr + " and assay.assay_desc = '" + desc.to_s + "'"
   end

   if (date != "*")
      wstr = wstr + " and assay.assay_date = '" + date.to_s + "'"
   end

   aarr = @@slib.sql_get_arr(tstr, fstr, wstr, "assay_name, replicate")
   aarr
end

def select_by_aidstr(str)
   aidarr = str.split("_")
   if (aidarr.length > 0)
      aidarrstr = @@alib.comb_arr_to_str(",", aidarr)
      tstr = get_from_str()
      fstr = get_field_str()
      wstr = get_where_str()
      wstr = wstr + " and assay.assay_id in (" + aidarrstr + ")"
      aarr = @@slib.sql_get_arr(tstr, fstr, wstr, "assay_name, replicate")
   else
      aarr = Array.new
   end
   aarr
end

## =================== select aid ===================
def list_aid()
   aarr = select("*", "*", "*", "*", "*", 0)
   len = aarr.length

   aidarr = Array.new
   for i in (0..len-1)
      aidarr[i] = aarr[i].assay_id
   end
   aidarr
end

def select_aid_by_userid(uid)
   aarr = select(uid, "*", "*", "*", "*", 0)
   len = aarr.length

   aidarr = Array.new
   for i in (0..len-1)
      aidarr[i] = aarr[i].assay_id
   end
   aidarr
end


def select_aid_by_filter(uid, aname, dname, pwname, desc, date, share)
   if (dname != "*")
      dbid = @@slib.sql_get_1num("biodatabase", "biodatabase_id", "name = '" + dname + "'")
   else
      dbid = "*"
   end
   if (pwname != "*")
      pwid = @@slib.sql_get_1num("pathway", "pathway_id", "name = '" + pwname + "'")
   else
      pwid = "*"
   end

   plateid = "*"
   aarr = select(uid, aname, dbid, plateid, pwid, desc, date, share)
   len = aarr.length

   aidarr = Array.new
   for i in (0..len-1)
      aidarr[i] = aarr[i].assay_id
   end
   aidarr
end

def select_aid_arr_by_aidarr_and_aname(aidarr, aname)
   aidstr = @@alib.comb_arr_to_str(",", aidarr)
   wstr = "name = '" + aname.to_s + "' and assay_id in (" + aidstr + ")"
   
   aidarr = @@slib.sql_get_nstr_order("assay", "assay_id", wstr, "replicate")
   aidarr
end


## ===================== select other fields =========================
def select_aname(aid)
   aname = @@slib.sql_get_1str("assay", "name", "assay_id = " + aid.to_s)
   aname  
end

def select_distinct_aname_arr(aidarr)
   wstr = ""
   i = 0
   for aid in aidarr
      if (i==0)
          wstr =  wstr + aid.to_s
          i = 1
      else
          wstr =  wstr + "," + aid.to_s
      end
   end
   anamearr = @@slib.sql_get_nstr("assay", "distinct name", "assay_id in (" + wstr + ")")
   anamearr
end

def select_rid(aid)
   repid = @@slib.sql_get_1num("assay", "replicate", "assay_id = " + aid.to_s)
   repid  
end

def select_ridarr(aidarr)
   aidstr = @@alib.comb_arr_to_str(",", aidarr)
   ridarr = @@slib.sql_get_nnum("assay", "replicate", "assay_id in (" + aidstr + ")")
   ridarr
end

def select_pname(aid)
   tstr = "assay, plate"
   fstr = "plate.name"
   wstr = "assay.plate_id = plate.plate.id and assay_id = " + aid.to_s
   ostr = "plate.name"
   
   pname = @@slib.sql_get_1str(tstr, fstr, wstr, ostr)
   pname
end

def select_pnamearr(aidarr)
   aidstr = @@alib.comb_arr_to_str(",", aidarr)
   tstr = "assay, plate"
   fstr = "plate.name"
   wstr = "assay.plate_id = plate.plate_id and assay_id in (" + aidstr + ")"
   ostr = "plate.name"
   
   pnamearr = @@slib.sql_get_nstr_order(tstr, fstr, wstr, ostr)
   pnamearr
end

def list()
   aarr = select("*", "*", "*", "*", "*")
end

## ===================== small functions =======================
def get_from_str
   tables = "assay, plate, pathway, biodatabase"
   tables
end

def get_field_str
   fields = Array.new
   fields[0] = "assay.assay_id as assay_id"
   fields[1] = "assay.user_id as user_id"
   fields[2] = "plate.name as plate_name"
   fields[3] = "pathway.name as pathway_name"
   fields[4] = "biodatabase.name as biodatabase_name"
   fields[5] = "assay.name as assay_name"
   fields[6] = "assay.assay_date"
   fields[7] = "assay.replicate as replicate"
   fields[8] = "assay.assay_desc"
   fields[9] = "assay.protocol"
   fields[10]= "assay.share"
   fstr = @@alib.comb_arr_to_str(",", fields)
   fstr
end

def get_where_str
   where = Array.new
   where[0] = "assay.pathway_id = pathway.pathway_id"
   where[1] = "assay.plate_id = plate.plate_id"
   where[2] = "plate.biodatabase_id = biodatabase.biodatabase_id"
   wstr = @@alib.comb_arr_to_str(" and ", where)
   wstr
end

end