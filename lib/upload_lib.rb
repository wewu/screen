class UploadLib

@@alib = ApplicationLib.new
@@slib = SqlLib.new
@@salib= SqlAssayLib.new
@@sarlib= SqlAssayresultLib.new


## =========== load functions ======================

def load_data(path, arr_assayfield)
   fname = arr_assayfield[1]
   arrdata = @@alib.read_file(path, fname)
   
   arrfealine = Array.new
   n = 0
   aid = 0
   oldaid = 0
   plateid = 0
   
   for ln in arrdata
      if (ln.length > 0)
         valarr = Array.new   
         (feaname, valarr) = ln.split(/\:/)
         feaname.strip!
         feaname.downcase!

         if (feaname.eql?("load time"))    #start a new plate
            if (aid > 0)
               @@alib.write_log("Plate " + plateid.to_s + " is successfully uploaded.") 
            elsif (plateid > 0)
               @@alib.write_log_error("Plate " + plateid.to_s)
            end

            arrfealine = Array.new
            n = 0
            aid = 0
            oldaid = 0
            plateid = 0
         
         else
            arr_resultfield = match_data_line(ln)   # num, well, val, sig, mtime, ftime
            num = arr_resultfield[0]

            if (num == 0)   ## feature line
               arrfealine[n] = ln
               n = n + 1
            elsif (num == 4)
               (num, well, val, sig, mtime, ftime) = arr_resultfield
               arr_resfield_2 = Array.new
               row = well
               for i in (1..24)
                  arr_resfield_2[1] = row + i.to_s   #well
                  arr_resfield_2[2] = arr_resultfield[i+1]  #val
                  (aid, isskip) = insert_one_assay(aid, arr_assayfield, arr_resfield_2)
               end

               if ((aid > 0) && (aid != oldaid))
                  plateid = insert_feature(aid, arrfealine)
                  oldaid = aid
               end
            end
         end
      end
   end  
   if (aid > 0)
      @@alib.write_log("Plate " + plateid.to_s + " is successfully uploaded.") 
   elsif (plateid > 0)
      @@alib.write_log_error("Plate " + plateid.to_s)
   end
   
end

def load_single(path, arr_assayfield)
   skiplines = ""
   j = 0
   aid = 0
   fname = arr_assayfield[1]
   arrdata = @@alib.read_file(path, fname)

   for ln in arrdata
      isskip = true
      arr_resultfield = match_data_line(ln)   # num, well, val, sig, mtime, ftime
      (num, well, val, sig, mtime, ftime) = arr_resultfield

      if ((num==1) || (num==2) || (num==3))
         (aid, isskip) = insert_one_assay(aid, arr_assayfield, arr_resultfield)
                
      elsif (num==4)
         arr_resfield_2 = Array.new
         row = well
         for i in (1..24)
            arr_resfield_2[1] = row + i.to_s   #well
            arr_resfield_2[2] = arr_resultfield[i+1]  #val
            
            (aid, isskip) = insert_one_assay(aid, arr_assayfield, arr_resfield_2)
         end
      end
     
      if (isskip)
         skiplines = skiplines + j.to_s + ","
      end  
      j = j+1
      
   end  

   ## write log     
   if (aid > 0)   
      msg = ""
      if (skiplines.length > 0)
         msg = "Skipped lines "+ skiplines.chop!
         @@salib.update_log(aid, msg)
      end     
      @@alib.write_log(fname + " is successfully uploaded.") # + msg)
   else
      @@alib.write_log_error(fname)
   end
end



## =========== insert functions ======================
def prepare_insert_assay(pwid, adate)
   aid  = @@slib.sql_get_1num("assay", "max(assay_id)", "")
   if (aid == 0)
      aid = 1
   else
      aid = aid + 1
   end

   if (@@alib.is_nil(adate))
      adate = @@alib.get_today_date()
   end
   
   arr = @@alib.new_arr3(aid, pwid, adate)
   arr
end


def prepare_insert_assay_result(pid, well)   
   arid = @@slib.sql_get_1num("assay_result", "max(assay_result_id)+1", "")
   if (arid < 0)
      arid = 1
   end

   row = well[0,1]
   col = well[1,3]
   eid = @@slib.sql_get_1num("element", "element_id", "plate_id=" + pid.to_s + " and row='" + row + "' and col=" + col.to_s)
   
   arr = @@alib.new_arr2(arid, eid)
   arr
end


def insert_one_assay(aid, arra, arr_assayres)
   #0-$guname, 1-fname, 2-aname, 3-repli, 4-plateid, 
   #5-desc, 6-date, 7-prot, 8-pathway, 9-swid
   
   uname= arra[0]
   fname= arra[1]
   aname= arra[2]
   repli= arra[3]
   pid  = arra[4]
   adesc = arra[5]
   date = arra[6]
   prot = arra[7]
   pwid = arra[8]
   swid = arra[9]
   log  = ""
   share = 0

   if (aid == 0)
      (aid, pwid, adate) = prepare_insert_assay(pwid, date)
      @@salib.insert(aid, uname, pid, pwid, swid, aname, fname, log, adate, repli, adesc, prot, share)
      
      ## post check
      aid2 = @@slib.sql_get_1num("assay", "max(assay_id)", "")
      if (aid2 != aid )
         puts "Insert assay fail\n"
         aid = -1
      end
   end
   
   isskip = true
   well = arr_assayres[1]
   if (aid > 0)
      (arid, eid) = prepare_insert_assay_result(pid, well)
      if (eid > 0)
         @@sarlib.insert(arid, aid, eid, arr_assayres[2], arr_assayres[3], arr_assayres[4], arr_assayres[5], "",0)
         isskip = false
      end
   end

   isskip = false
   arr = @@alib.new_arr2(aid, isskip)
   arr
end


def insert_feature(aid, arrfealine)
   plateid = 0
   
   for fealine in arrfealine
      valarr = Array.new   
      (name, valarr) = fealine.split(/\:/)
      val = @@alib.comb_arr_to_str(":", valarr)
      name.strip!
      name.gsub!(/\s+/, "_")
      name.downcase!
      val.strip!
      
      if (name == "plate_id")
         plateid = val
      end
      
      afid = @@slib.sql_get_1num("assay_feature", "max(assay_feature_id)+1", "")
      @@salib.insert_one_feature(afid, aid, name, val)
      
      ## post check
      afid2 = @@slib.sql_get_1num("assay_feature", "max(assay_feature_id)", "")
      if (afid2 != afid )
         puts "insert feature line: " + fealine + " fail."
      end
   end
   plateid
end

## =============== check function ====================
def parse_fname(fname)
   (fnfront, ename) = fname.split(/\./)
   arr = fnfront.split(/\_/)
   arr[arr.length] = ename
   arr
end

def check_filename_format(arrfname)   
   succ = true
   for fname in arrfname
      (aname, repli, dname, pname, desc, adate, ename) = parse_fname(fname)

      dnamearr = @@slib.sql_get_nstr("biodatabase", "name", "")
      pnamearr = @@slib.sql_get_nstr("plate", "name", "")
     
      enamesucc= (ename.casecmp("txt")==0)
      dnameidx = @@alib.search_array_str_item(dname, dnamearr)
      pnameidx = @@alib.search_array_str_item(pname, pnamearr)
      dtsucc   = @@alib.check_date_format(adate)
     
      if (!enamesucc)
         @@alib.write_log_error(fname + ": extension name")
         succ = false
      elsif (dnameidx < 0)
         @@alib.write_log_error(fname + ": libname")
         succ = false
      elsif (pnameidx < 0)
         @@alib.write_log_error(fname + ": platename")
         succ = false
      elsif (!dtsucc)
         @@alib.write_log_error(fname + ": date")
         succ = false
      end
   end
   succ
end

def match_data_line(ln)
   arrret = Array.new
   reg1 = /\S+\t\t(\S+)\t(\d+)\t(\d+)\t(\d+\.?\d+?)\t(\S\S\:\S\S\:\S\S\.\d\d\d)/
   reg2 = /\S+\t\d+\t\t\S+\t(\S+)\t.*\t\d+\t\d+\t\d+\t.*\t(\S\S\:\S\S\:\S\S\.\d\d\d)\t(\d+)\t(\d+\.?\d+?)\t(\d+)/
   reg3 = /\S+\t\t(\S+)\t(\d+)\t(\d+)\t\d+/
   #       1   2   3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   
   reg4 = /(\S)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)/
   reg5 = /\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)/
   reg6 = /(\S)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)\t(\d+\.\d+)/

   match1 = reg1.match(ln)
   match2 = reg2.match(ln)
   match3 = reg3.match(ln)
   match4 = reg4.match(ln)
   match5 = reg5.match(ln)
   match6 = reg6.match(ln)
   
   if (match1)         # well, val, sig, mtime, ftime
      arrret[0] = 1
      arrret[1] = match1[1]   
      arrret[2] = match1[2]
      arrret[3] = match1[3]
      arrret[4] = match1[4]
      arrret[5] = match1[5]
   elsif (match2)       # well, mtime, sig, ftime, val
      arrret[0] = 2
      arrret[1] = match2[1]  
      arrret[2] = match2[5]
      arrret[3] = match2[3]
      arrret[4] = match2[2]
      arrret[5] = match2[4]
   elsif (match3)       # well, val, sig
      arrret[0] = 3
      arrret[1] = match3[1]  
      arrret[2] = match3[2]
      arrret[3] = match3[3]
      arrret[4] = ""
      arrret[5] = ""
   elsif (match4)        # row, val1..val24
      arrret[0] = 4
      for i in (1..25)
         arrret[i] = match4[i]  
      end
   elsif (match5)        # the label line
      arrret[0] = -1
   elsif (match6)        # row, val1..val24
      arrret[0] = 4
      for i in (1..25)
         arrret[i] = match6[i]  
      end
   else                  # feature line
      arrret[0] = 0
   end
   arrret
end

end  #class end
