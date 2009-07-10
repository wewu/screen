class RLib

@@alib = ApplicationLib.new
@@salib = SqlAssayLib.new
@@sarlib = SqlAssayresultLib.new
@@rows = 16
@@cols = 24


## ===================== run prog function ================================

def run_r(uname, func, cutoff, aidarr, subgrp_arr)
   lpath = @@alib.get_localpath(uname, "r")
   
   for aid in aidarr
      hmap_list(aid, lpath, "hmap_list_" + aid.to_s + ".txt")   
      hmap_data(aid, lpath, "hmap_data_" + aid.to_s + ".txt")   
      hmap_conf(aid, lpath, "hmap_conf_" + aid.to_s + ".txt")
      hmap_log(aid,  lpath, "hmap_log_notuse_" + aid.to_s + ".txt")
      hmap_desc(aid, lpath, "hmap_desc_notuse_" + aid.to_s + ".txt")
   end
   
   aidarr_str = Array.new
   i = 0
   subgrplen = subgrp_arr.length
   allgrp_aidarr = Array.new
   t = 0
   for j in 1..40
      s = 0
      onegrp_aidarr = Array.new
      for k in 0..(subgrplen-1)
         if (subgrp_arr[k].to_i == j)
            onegrp_aidarr[s] = aidarr[k]
            s = s + 1
            allgrp_aidarr[t] = aidarr[k]
            t = t + 1
         end
      end

      if (onegrp_aidarr.length > 0)
         aidarr_str[i] = "'" + @@alib.comb_arr_to_str("_", onegrp_aidarr) + "'"
         i = i + 1
      end
   end
   aidarr_str[i] = "'" + @@alib.comb_arr_to_str("_", allgrp_aidarr) + "'"

   #anamearr = @@salib.select_distinct_aname_arr(aidarr)
   #for aname in anamearr
   #   aidarr_by_aname = @@salib.select_aid_arr_by_aidarr_and_aname(aidarr, aname)
   #   aidarr_str[i] = "'" + @@alib.comb_arr_to_str("_", aidarr_by_aname) + "'"
   #   i = i + 1
   #end

   aidvec_str = @@alib.comb_arr_to_str(",", aidarr_str)
   if ((func == "POC") || (func == "negatives"))
      pgname = hmap_prog(func, cutoff, lpath, 0, aidvec_str)
   else
      pgname = hmap_prog(func, cutoff, lpath, 2, aidvec_str)
   end
   
   outname = func + ".out"
   @@alib.qsub(lpath, pgname, outname, aidarr.length)
   lpath + outname
end


## ===================== hmap function ================================
def hmap_list(aid, lpath, fname)
   s = "Filename\tPlate\tReplicate" + "\n"
   s = s + "hmap_data_" + aid.to_s + ".txt" + "\t" + "1" + "\t" + "1" + "\n"
   @@alib.write_file(lpath, fname, s)
end

def hmap_data(aid, lpath, fname)
   s = ""
   ararr = @@sarlib.list(aid)
   for ar in ararr
      s = s + "\t" + ar.well + "\t" + ar.value.to_s + "\n"
   end
   @@alib.write_file(lpath, fname, s)
end

def hmap_conf(aid, lpath, fname)
   ararr = @@sarlib.list(aid)
   s = "Batch\tWell\tContent\n"
   for ar in ararr
      if (ar.bc_elem == "1")
         content = "bad"
      elsif (ar.bc_elem == "2")
         content = "pos"
      elsif (ar.bc_elem == "3")
         content = "neg"
      else
         content = "sample"
      end
      s = s + "1" + "\t" + ar.well + "\t" + content + "\n"
   end
   @@alib.write_file(lpath, fname, s)
end

def hmap_log(aid, lpath, fname)
   s = "Filename\tWell\tFlag\tComment\n"
   @@alib.write_file(lpath, fname, s)
end

def hmap_desc(aid, lpath, fname)
   @@alib.write_file(lpath, fname, " ")
end

def hmap_prog(func, cutoff, path,  prec, aidarr_str)
   s = ""
   s = s + "cutoff = " + cutoff.to_s + " \n"
   s = s + "func = \"" + func + "\" \n"
   s = s + "path = \"" + path + "\" \n"
   s = s + "precision = " + prec.to_s + " \n"
   s = s + "aid_vec=c(" + aidarr_str + ")" + "\n"
   #s = s + "isserver =" + isserver.to_s + " \n"
   
   dir = File.dirname(__FILE__) + "/"
   arrcode = @@alib.read_file(dir, "r_template.R")
   str = @@alib.comb_arr_to_str(" \n ", arrcode)
   s = s + str + "\n"

   pgname = func + ".r"
   @@alib.write_file(path, pgname, s)
   pgname
end


## ===================== read function ================================
def get_avg_idxarr(arrdata)
   len = arrdata.length
   j = 0
   k = 0
   idxarr = Array.new
   for i in 0..(len-1)
      reg = /## Assay Id = (.*)/
      match1 = reg.match(arrdata[i])
      if (match1)
         j = j + 1

         aid = match1[1]
         reg = /avg(.*)/
         match2 = reg.match(aid)
         if (match2)
            idxarr[k] = j
            k = k + 1
         end
      end
   end
   idxarr
end

def read_out_one(arrdata, n)
   len = arrdata.length
   done = false
   j = 0
   sn = -1
   en = -2
   for i in 0..(len-1)
      if (done == false)
         reg = /## Assay Id = (.*)/
         if (reg.match(arrdata[i]))
            j = j + 1

            if (j==n.to_i)
               sn = i
            elsif (sn >= 0)
               en = i-1
               done = true
            end
         end
      end
   end
   
   if ((sn >= 0) && (en < 0))   
      en = len -1
   end

   arr = Array.new         
   for i in sn..en
      arr[i-sn] = arrdata[i]
   end
   arr  
end

## ===================== get function ================================
def get_aid(arrdatan)
   reg = /## Assay Id = (\S+)/
   aid = @@alib.search_pattern_in_array(reg, arrdatan)
   if (aid.length == 0)
      aid = -1
   end   
   aid
end

def get_aidarr(aidarr_str)
    aidarr = (aidarr_str.to_s).split(/\_/)
    if (aidarr[0] == "avg")
       aidarr2 = @@alib.arr_del(0, aidarr)
    else
       aidarr2 = aidarr
    end
    aidarr2
end

def get_aname_rid_pname(aidarr_str)
    aidarr = get_aidarr(aidarr_str)
    aid = aidarr[0]
    anm = @@salib.select_aname(aid)
    if (aidarr.length > 1)
       ridarr = @@salib.select_ridarr(aidarr)
       ridarr_str = @@alib.comb_arr_to_str(", ", ridarr)
       rid_str = "Average over replicates " + ridarr_str

       pnamearr = @@salib.select_pnamearr(aidarr)
       pnamearr_str = @@alib.comb_arr_to_str(", ", pnamearr)
       pname_str = "Average over plates " + pnamearr_str
    else
       rid_str = @@salib.select_rid(aid)
       pname_str = @@salib.select_pname(aid)
    end
    
    arr = Array.new
    arr[0] = aid
    arr[1] = anm
    arr[2] = rid_str
    arr[3] = pname_str
    arr
end

def get_idxarr(aidarr_str, i)
    aidarr = get_aidarr(aidarr_str) 
    len = aidarr.length
    idxarr = Array.new
    for j in (0..len-1)
       idxarr[j] = i - len + j
    end
    idxarr
end

def get_error(arrdatan)
   reg = /#_# error = (.*)/
   errmsg  = @@alib.search_pattern_in_array(reg, arrdatan)
   errmsg
end

def get_score_table(arrdatan)
   scorearr = Array.new
   reg = /(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)/
   n = 0
   for i in 0..(arrdatan.length - 1)
      matched = reg.match(arrdatan[i])
      if (matched)
         for j in 1..@@cols
             scorearr[n + j-1] = matched[j]
         end
         n = n + @@cols
      end
   end
   scorearr
end

def get_bscore_overall(arrdatan)
   reg = /overall\=(\S+)$/
   overall = @@alib.search_pattern_in_array(reg, arrdatan)
   overall
end

def get_roweff(scorearr)
   roweff = Array.new
   for i in (0..(@@rows-1))  
      roweff[i] = 0 
   end

   for i in (0..(@@rows-1))  
      for j in (0..(@@cols-1))  
         n = i*@@cols + j 
         if (!(scorearr[n] == "NA"))
            roweff[i] = ((roweff[i] + scorearr[n].to_f)*100).round.to_f/100
         end
      end
   end
   for i in (0..(@@rows-1))  
      roweff[i] = (roweff[i]/@@cols).round
   end
   roweff
end

def get_coleff(scorearr)
   coleff = Array.new
   for j in (0..(@@cols-1))  
      coleff[j] = 0 
   end

   for i in (0..(@@rows-1))  
      for j in (0..(@@cols-1))  
         n = i*@@cols + j 
         if (!(scorearr[n] == "NA"))
            coleff[j] = ((coleff[j] + scorearr[n].to_f)*100).round.to_f/100
         end
      end
   end

   for j in (0..(@@cols-1))  
      coleff[j] = (coleff[j]/@@rows).round
   end
   coleff
end

def get_pic(func, type, aid)
   func + "_" + type + "_" + aid.to_s[0,50] + ".jpg"
end

def get_pdf(uname, func, type, aid)
   lpath = @@alib.get_localpath(uname, "r")
   lpath + func + "_" + type + "_" + aid.to_s[0,50] + ".pdf"
end

## ===================== small function ================================
def get_aidridarr(aidarr)
   i = 0
   aidridarr = Array.new
   for aid in aidarr
      rid = @@salib.select_replicate(aid)

      aidridarr[i] = aid.to_s + "_" + rid.to_s
      i = i + 1
   end
   aidridarr

def get_rout_fname(uname, func)
   lpath = @@alib.get_localpath(uname, "r")
   outname = func + ".out"
   lpath + outname
end

end



end
